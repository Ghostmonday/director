//
//  DirectorStudioCore.swift
//  DirectorStudio
//
//  MODULE: DirectorStudioCore
//  VERSION: 1.0.0
//  PURPOSE: Core integration and orchestration system
//

import Foundation

// MARK: - Director Studio Core

public class DirectorStudioCore {
    // MARK: - Singleton Instance
    
    public static let shared = DirectorStudioCore()
    
    // MARK: - Core Modules
    
    public let segmentationModule: SegmentationModule
    public let rewordingModule: RewordingModule
    public let storyAnalysisModule: StoryAnalysisModule
    public let taxonomyModule: CinematicTaxonomyModule
    public let continuityModule: ContinuityModule
    public let videoGenerationModule: VideoGenerationModule
    public let videoAssemblyModule: VideoAssemblyModule
    public let videoEffectsModule: VideoEffectsModule
    
    // MARK: - Core Services
    
    public let persistenceManager: PersistenceManagerProtocol
    public let monetizationManager: MonetizationManagerProtocol
    public let aiService: AIServiceProtocol
    
    // MARK: - Core State
    
    public private(set) var currentProject: Project?
    public private(set) var currentSegments: [PromptSegment] = []
    public private(set) var isProcessing: Bool = false
    public private(set) var currentOperation: String = ""
    public private(set) var progress: Double = 0.0
    
    // MARK: - Event System
    
    private var eventHandlers: [String: [(Any) -> Void]] = [:]
    
    // MARK: - Initialization
    
    private init() {
        // Initialize AI service
        self.aiService = MockAIService()
        
        // Initialize modules
        self.segmentationModule = SegmentationModule()
        self.rewordingModule = RewordingModule(aiService: aiService)
        self.storyAnalysisModule = StoryAnalysisModule()
        self.taxonomyModule = CinematicTaxonomyModule()
        self.continuityModule = ContinuityModule()
        self.videoGenerationModule = VideoGenerationModule(aiService: aiService)
        self.videoAssemblyModule = VideoAssemblyModule()
        self.videoEffectsModule = VideoEffectsModule()
        
        // Initialize services
        do {
            self.persistenceManager = try FilePersistenceManager()
            self.monetizationManager = MockMonetizationManager(persistenceManager: persistenceManager)
        } catch {
            fatalError("Failed to initialize core services: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Project Management
    
    public func createProject(name: String, description: String = "") throws -> Project {
        let project = Project(
            name: name,
            description: description
        )
        
        return try persistenceManager.saveProject(project)
    }
    
    public func loadProject(id: UUID) throws -> Project {
        guard let project = try persistenceManager.getProject(id: id) else {
            throw CoreError.projectNotFound(id: id)
        }
        
        self.currentProject = project
        
        // Load segments
        self.currentSegments = try persistenceManager.getSegments(projectId: id)
        
        return project
    }
    
    public func saveProject() throws {
        guard let project = currentProject else {
            throw CoreError.noActiveProject
        }
        
        // Update project
        var updatedProject = project
        updatedProject.updatedAt = Date()
        
        // Save project
        self.currentProject = try persistenceManager.saveProject(updatedProject)
        
        // Save segments
        try persistenceManager.saveSegments(currentSegments, projectId: updatedProject.id)
    }
    
    public func closeProject() {
        self.currentProject = nil
        self.currentSegments = []
    }
    
    // MARK: - Segment Management
    
    public func addSegment(_ segment: PromptSegment) throws {
        guard let project = currentProject else {
            throw CoreError.noActiveProject
        }
        
        currentSegments.append(segment)
        
        // Save segments
        try persistenceManager.saveSegments(currentSegments, projectId: project.id)
    }
    
    public func updateSegment(_ segment: PromptSegment) throws {
        guard let project = currentProject else {
            throw CoreError.noActiveProject
        }
        
        guard let index = currentSegments.firstIndex(where: { $0.id == segment.id }) else {
            throw CoreError.segmentNotFound(id: segment.id)
        }
        
        currentSegments[index] = segment
        
        // Save segments
        try persistenceManager.saveSegments(currentSegments, projectId: project.id)
    }
    
    public func deleteSegment(id: UUID) throws {
        guard let project = currentProject else {
            throw CoreError.noActiveProject
        }
        
        guard let index = currentSegments.firstIndex(where: { $0.id == id }) else {
            throw CoreError.segmentNotFound(id: id)
        }
        
        currentSegments.remove(at: index)
        
        // Save segments
        try persistenceManager.saveSegments(currentSegments, projectId: project.id)
    }
    
    // MARK: - Pipeline Execution
    
    public func segmentStory(story: String) async throws -> [PromptSegment] {
        guard let project = currentProject else {
            throw CoreError.noActiveProject
        }
        
        // Check credits
        let requiredCredits = 5
        guard await canUseCredits(requiredCredits) else {
            throw CoreError.insufficientCredits(required: requiredCredits)
        }
        
        // Start processing
        updateProcessingState(true, operation: "Segmenting story")
        
        do {
            // Create input
            let input = SegmentationInput(story: story)
            
            // Execute module
            let result = try await executeWithTimeout(module: segmentationModule, input: input)
            
            // Update segments
            currentSegments = result.segments
            
            // Save segments
            try persistenceManager.saveSegments(currentSegments, projectId: project.id)
            
            // Use credits
            try await monetizationManager.useCredits(requiredCredits)
            
            // End processing
            updateProcessingState(false)
            
            return currentSegments
            
        } catch {
            // End processing
            updateProcessingState(false)
            
            // Re-throw error
            throw error
        }
    }
    
    public func rewordSegment(segmentId: UUID, style: RewordingStyle) async throws -> PromptSegment {
        guard let project = currentProject else {
            throw CoreError.noActiveProject
        }
        
        guard let index = currentSegments.firstIndex(where: { $0.id == segmentId }) else {
            throw CoreError.segmentNotFound(id: segmentId)
        }
        
        // Check credits
        let requiredCredits = 2
        guard await canUseCredits(requiredCredits) else {
            throw CoreError.insufficientCredits(required: requiredCredits)
        }
        
        // Start processing
        updateProcessingState(true, operation: "Rewording segment")
        
        do {
            // Create input
            let input = RewordingInput(
                text: currentSegments[index].content,
                type: style
            )
            
            // Execute module
            let result = try await executeWithTimeout(module: rewordingModule, input: input)
            
            // Update segment
            var updatedSegment = currentSegments[index]
            updatedSegment.content = result.rewordedText
            currentSegments[index] = updatedSegment
            
            // Save segments
            try persistenceManager.saveSegments(currentSegments, projectId: project.id)
            
            // Use credits
            try await monetizationManager.useCredits(requiredCredits)
            
            // End processing
            updateProcessingState(false)
            
            return updatedSegment
            
        } catch {
            // End processing
            updateProcessingState(false)
            
            // Re-throw error
            throw error
        }
    }
    
    public func analyzeStory(story: String) async throws -> StoryAnalysis {
        // Check credits
        let requiredCredits = 3
        guard await canUseCredits(requiredCredits) else {
            throw CoreError.insufficientCredits(required: requiredCredits)
        }
        
        // Start processing
        updateProcessingState(true, operation: "Analyzing story")
        
        do {
            // Create input
            let input = StoryAnalysisInput(story: story)
            
            // Execute module
            let result = try await executeWithTimeout(module: storyAnalysisModule, input: input)
            
            // Use credits
            try await monetizationManager.useCredits(requiredCredits)
            
            // End processing
            updateProcessingState(false)
            
            return result.analysis
            
        } catch {
            // End processing
            updateProcessingState(false)
            
            // Re-throw error
            throw error
        }
    }
    
    public func enrichSegmentsWithTaxonomy() async throws -> [PromptSegment] {
        guard let project = currentProject else {
            throw CoreError.noActiveProject
        }
        
        guard !currentSegments.isEmpty else {
            throw CoreError.noSegmentsAvailable
        }
        
        // Check credits
        let requiredCredits = 4
        guard await canUseCredits(requiredCredits) else {
            throw CoreError.insufficientCredits(required: requiredCredits)
        }
        
        // Start processing
        updateProcessingState(true, operation: "Enriching segments with taxonomy")
        
        do {
            // Create input
            let input = CinematicTaxonomyInput(segments: currentSegments)
            
            // Execute module
            let result = try await executeWithTimeout(module: taxonomyModule, input: input)
            
            // Update segments
            currentSegments = result.enrichedSegments
            
            // Save segments
            try persistenceManager.saveSegments(currentSegments, projectId: project.id)
            
            // Use credits
            try await monetizationManager.useCredits(requiredCredits)
            
            // End processing
            updateProcessingState(false)
            
            return currentSegments
            
        } catch {
            // End processing
            updateProcessingState(false)
            
            // Re-throw error
            throw error
        }
    }
    
    public func validateContinuity() async throws -> ContinuityOutput {
        guard let project = currentProject else {
            throw CoreError.noActiveProject
        }
        
        guard !currentSegments.isEmpty else {
            throw CoreError.noSegmentsAvailable
        }
        
        // Check credits
        let requiredCredits = 2
        guard await canUseCredits(requiredCredits) else {
            throw CoreError.insufficientCredits(required: requiredCredits)
        }
        
        // Start processing
        updateProcessingState(true, operation: "Validating continuity")
        
        do {
            // Create input
            let input = ContinuityInput(segments: currentSegments)
            
            // Execute module
            let result = try await executeWithTimeout(module: continuityModule, input: input)
            
            // Use credits
            try await monetizationManager.useCredits(requiredCredits)
            
            // End processing
            updateProcessingState(false)
            
            return result
            
        } catch {
            // End processing
            updateProcessingState(false)
            
            // Re-throw error
            throw error
        }
    }
    
    public func generateVideo(
        quality: VideoQuality = .high,
        format: VideoFormat = .mp4,
        style: VideoStyle = .cinematic
    ) async throws -> VideoGenerationOutput {
        guard let project = currentProject else {
            throw CoreError.noActiveProject
        }
        
        guard !currentSegments.isEmpty else {
            throw CoreError.noSegmentsAvailable
        }
        
        // Check credits
        let requiredCredits = 10 * currentSegments.count
        guard await canUseCredits(requiredCredits) else {
            throw CoreError.insufficientCredits(required: requiredCredits)
        }
        
        // Start processing
        updateProcessingState(true, operation: "Generating video")
        
        do {
            // Create input
            let input = VideoGenerationInput(
                segments: currentSegments,
                projectName: project.name,
                outputFormat: format,
                quality: quality,
                style: style
            )
            
            // Execute module
            let result = try await executeWithTimeout(module: videoGenerationModule, input: input, timeout: 60)
            
            // Use credits
            try await monetizationManager.useCredits(requiredCredits)
            
            // End processing
            updateProcessingState(false)
            
            return result
            
        } catch {
            // End processing
            updateProcessingState(false)
            
            // Re-throw error
            throw error
        }
    }
    
    public func applyVideoEffects(
        videoURL: URL,
        effects: [VideoEffect],
        quality: VideoQuality = .high,
        format: VideoFormat = .mp4
    ) async throws -> VideoEffectsOutput {
        // Check credits
        let requiredCredits = 5 * effects.count
        guard await canUseCredits(requiredCredits) else {
            throw CoreError.insufficientCredits(required: requiredCredits)
        }
        
        // Start processing
        updateProcessingState(true, operation: "Applying video effects")
        
        do {
            // Create input
            let input = VideoEffectsInput(
                videoURL: videoURL,
                effects: effects,
                quality: quality,
                outputFormat: format
            )
            
            // Execute module
            let result = try await executeWithTimeout(module: videoEffectsModule, input: input, timeout: 30)
            
            // Use credits
            try await monetizationManager.useCredits(requiredCredits)
            
            // End processing
            updateProcessingState(false)
            
            return result
            
        } catch {
            // End processing
            updateProcessingState(false)
            
            // Re-throw error
            throw error
        }
    }
    
    // MARK: - Helper Methods
    
    private func executeWithTimeout<M: PipelineModule>(
        module: M,
        input: M.Input,
        timeout: TimeInterval = 15
    ) async throws -> M.Output {
        return try await withThrowingTaskGroup(of: M.Output.self) { group in
            // Add timeout task
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                throw CoreError.operationTimeout(module: String(describing: M.self), timeout: timeout)
            }
            
            // Add execution task
            group.addTask {
                let context = PipelineContext()
                let result = await module.execute(input: input, context: context)
                
                switch result {
                case .success(let output):
                    return output
                case .failure(let error):
                    throw CoreError.moduleError(module: String(describing: M.self), error: error)
                }
            }
            
            // Return the first completed task (success or failure)
            let result = try await group.next()!
            
            // Cancel remaining tasks
            group.cancelAll()
            
            return result
        }
    }
    
    private func updateProcessingState(_ isProcessing: Bool, operation: String = "") {
        self.isProcessing = isProcessing
        self.currentOperation = operation
        self.progress = isProcessing ? 0.0 : 1.0
        
        // Emit event
        emitEvent(ProcessingStateChangedEvent(
            isProcessing: isProcessing,
            operation: operation,
            progress: progress
        ))
    }
    
    private func updateProgress(_ progress: Double) {
        self.progress = progress
        
        // Emit event
        emitEvent(ProgressUpdatedEvent(progress: progress))
    }
    
    private func canUseCredits(_ amount: Int) async -> Bool {
        return await monetizationManager.canAfford(amount)
    }
    
    // MARK: - Event System
    
    public func addEventListener<T>(for eventType: T.Type, handler: @escaping (T) -> Void) {
        let key = String(describing: eventType)
        
        if eventHandlers[key] == nil {
            eventHandlers[key] = []
        }
        
        eventHandlers[key]?.append { event in
            if let typedEvent = event as? T {
                handler(typedEvent)
            }
        }
    }
    
    public func removeEventListeners<T>(for eventType: T.Type) {
        let key = String(describing: eventType)
        eventHandlers[key] = nil
    }
    
    private func emitEvent<T>(_ event: T) {
        let key = String(describing: type(of: event))
        
        eventHandlers[key]?.forEach { handler in
            handler(event)
        }
    }
}

// MARK: - Event Types

public struct ProcessingStateChangedEvent {
    public let isProcessing: Bool
    public let operation: String
    public let progress: Double
}

public struct ProgressUpdatedEvent {
    public let progress: Double
}

public struct ProjectLoadedEvent {
    public let project: Project
}

public struct SegmentsUpdatedEvent {
    public let segments: [PromptSegment]
}

public struct CreditsChangedEvent {
    public let credits: Int
}

// MARK: - Error Types

public enum CoreError: Error, LocalizedError {
    case noActiveProject
    case projectNotFound(id: UUID)
    case segmentNotFound(id: UUID)
    case noSegmentsAvailable
    case insufficientCredits(required: Int)
    case operationTimeout(module: String, timeout: TimeInterval)
    case moduleError(module: String, error: PipelineError)
    case serviceUnavailable(service: String)
    case moduleDisabled(module: String)
    
    public var errorDescription: String? {
        switch self {
        case .noActiveProject:
            return "No active project"
        case .projectNotFound(let id):
            return "Project not found with ID: \(id)"
        case .segmentNotFound(let id):
            return "Segment not found with ID: \(id)"
        case .noSegmentsAvailable:
            return "No segments available"
        case .insufficientCredits(let required):
            return "Insufficient credits. Required: \(required)"
        case .operationTimeout(let module, let timeout):
            return "Operation timed out after \(timeout) seconds in module: \(module)"
        case .moduleError(let module, let error):
            return "Error in module \(module): \(error.localizedDescription)"
        case .serviceUnavailable(let service):
            return "Service unavailable: \(service)"
        case .moduleDisabled(let module):
            return "Module '\(module)' is disabled"
        }
    }
}
