//
//  DirectorStudioCoreCLI.swift
//  DirectorStudio
//
//  MODULE: DirectorStudioCoreCLI
//  VERSION: 1.0.0
//  PURPOSE: CLI-Compatible Core Foundation - Feature Agnostic Central Hub
//
//  THE CORE - CLI-Compatible Version
//  ALL modules, services, and features connect through here
//  This is your single source of truth for CLI operations
//

import Foundation

// MARK: - CLI-Compatible Core Protocol

public protocol DirectorStudioCoreProtocol {
    // MARK: - Core State Management
    var currentProject: Project? { get }
    var pipelineState: PipelineState { get }
    var credits: Int { get }
    var isProcessing: Bool { get }
    var currentModule: String { get }
    var progress: Double { get }
    
    // MARK: - Module Management
    func registerModule(_ module: any ModuleProtocol)
    func getModule<T: ModuleProtocol>(id: String) -> T?
    func getAllModules() -> [any ModuleProtocol]
    
    // MARK: - Execution
    func executeModule<T: ModuleProtocol>(_ module: T, input: T.Input) async throws -> T.Output
    func executePipeline(input: String) async throws -> PipelineResult
    
    // MARK: - State Updates
    func updateProject(_ project: Project?)
    func updatePipelineState(_ state: PipelineState)
    func updateCredits(_ credits: Int)
    func updateProcessing(_ isProcessing: Bool)
    func updateCurrentModule(_ module: String)
    func updateProgress(_ progress: Double)
    
    // MARK: - Event Handling
    func addEventListener<T>(for eventType: T.Type, handler: @escaping (T) -> Void)
    func emitEvent<T>(_ event: T)
    
    // MARK: - Health Check
    func healthCheck() async -> [String: Bool]
}

// MARK: - CLI-Compatible Core Implementation

public final class DirectorStudioCoreCLI: DirectorStudioCoreProtocol {
    
    // MARK: - Core State (Non-Published)
    
    public private(set) var currentProject: Project?
    public private(set) var pipelineState: PipelineState = .idle
    public private(set) var credits: Int = 0
    public private(set) var isProcessing: Bool = false
    public private(set) var currentModule: String = ""
    public private(set) var progress: Double = 0.0
    
    // MARK: - Core Components
    
    public let eventBus: EventBus
    public let config: CoreConfig
    public let services: ServiceRegistry
    
    // MARK: - Module Registry
    
    private var modules: [String: any ModuleProtocol] = [:]
    
    // MARK: - Initialization
    
    public init() {
        self.eventBus = EventBus()
        self.config = CoreConfig()
        self.services = ServiceRegistry()
        
        setupEventListeners()
        registerDefaultServices()
    }
    
    // MARK: - State Updates
    
    public func updateProject(_ project: Project?) {
        self.currentProject = project
        emitEvent(ProjectUpdatedEvent(project: project))
    }
    
    public func updatePipelineState(_ state: PipelineState) {
        self.pipelineState = state
        emitEvent(PipelineStateUpdatedEvent(state: state))
    }
    
    public func updateCredits(_ credits: Int) {
        self.credits = credits
        emitEvent(CreditsUpdatedEvent(credits: credits))
    }
    
    public func updateProcessing(_ isProcessing: Bool) {
        self.isProcessing = isProcessing
        emitEvent(ProcessingUpdatedEvent(isProcessing: isProcessing))
    }
    
    public func updateCurrentModule(_ module: String) {
        self.currentModule = module
        emitEvent(CurrentModuleUpdatedEvent(module: module))
    }
    
    public func updateProgress(_ progress: Double) {
        self.progress = progress
        emitEvent(ProgressUpdatedEvent(progress: progress))
    }
    
    // MARK: - Module Registration
    
    public func registerModule(_ module: any ModuleProtocol) {
        modules[module.id] = module
        print("📦 [CORE] Registered module: \(module.name)")
    }
    
    public func getModule<T: ModuleProtocol>(id: String) -> T? {
        return modules[id] as? T
    }
    
    public func getAllModules() -> [any ModuleProtocol] {
        return Array(modules.values)
    }
    
    // MARK: - Execute Single Module
    
    public func executeModule<T: ModuleProtocol>(
        _ module: T,
        input: T.Input
    ) async throws -> T.Output {
        guard module.isEnabled else {
            throw CoreError.moduleDisabled(module: module.id)
        }
        
        updateCurrentModule(module.name)
        updateProgress(0.0)
        
        do {
            let output = try await module.execute(input: input)
            updateProgress(1.0)
            emitEvent(ModuleExecutedEvent(moduleId: module.id, success: true))
            return output
        } catch {
            emitEvent(ModuleExecutedEvent(moduleId: module.id, success: false))
            throw error
        }
    }
    
    // MARK: - Execute Full Pipeline
    
    public func executePipeline(input: String) async throws -> PipelineResult {
        updatePipelineState(.running)
        updateProcessing(true)
        updateProgress(0.0)
        
        var results: [String: Any] = [:]
        let totalSteps = 5 // Rewording, Analysis, Segmentation, Taxonomy, Continuity
        var currentStep = 0
        
        do {
            // Step 1: Rewording
            currentStep += 1
            updateProgress(Double(currentStep) / Double(totalSteps))
            if let rewordModule: RewordingModule = getModule(id: "rewording") {
                let rewordInput = RewordingInput(text: input, type: .cinematicMood)
                let rewordOutput = try await executeModule(rewordModule, input: rewordInput)
                results["rewording"] = rewordOutput
            }
            
            // Step 2: Story Analysis
            currentStep += 1
            updateProgress(Double(currentStep) / Double(totalSteps))
            if let analysisModule: StoryAnalysisModule = getModule(id: "storyanalysis") {
                let analysisInput = StoryAnalysisInput(story: input)
                let analysisOutput = try await executeModule(analysisModule, input: analysisInput)
                results["analysis"] = analysisOutput
            }
            
            // Step 3: Segmentation
            currentStep += 1
            updateProgress(Double(currentStep) / Double(totalSteps))
            if let segmentModule: SegmentationModule = getModule(id: "segmentation") {
                let segmentInput = SegmentationInput(story: input, maxDuration: 60)
                let segmentOutput = try await executeModule(segmentModule, input: segmentInput)
                results["segmentation"] = segmentOutput
            }
            
            // Step 4: Taxonomy
            currentStep += 1
            updateProgress(Double(currentStep) / Double(totalSteps))
            if let taxonomyModule: CinematicTaxonomyModule = getModule(id: "taxonomy") {
                let taxonomyInput = CinematicTaxonomyInput(segments: []) // Will be populated from segmentation
                let taxonomyOutput = try await executeModule(taxonomyModule, input: taxonomyInput)
                results["taxonomy"] = taxonomyOutput
            }
            
            // Step 5: Continuity
            currentStep += 1
            updateProgress(Double(currentStep) / Double(totalSteps))
            if let continuityModule: ContinuityModule = getModule(id: "continuity") {
                let continuityInput = ContinuityInput(segments: []) // Will be populated from taxonomy
                let continuityOutput = try await executeModule(continuityModule, input: continuityInput)
                results["continuity"] = continuityOutput
            }
            
            updatePipelineState(.completed)
            updateProcessing(false)
            updateProgress(1.0)
            
            return PipelineResult(
                success: true,
                results: results,
                executionTime: Date().timeIntervalSince1970
            )
            
        } catch {
            updatePipelineState(.failed)
            updateProcessing(false)
            throw error
        }
    }
    
    // MARK: - Event Handling
    
    public func addEventListener<T>(for eventType: T.Type, handler: @escaping (T) -> Void) {
        eventBus.addEventListener(for: eventType, handler: handler)
    }
    
    public func emitEvent<T>(_ event: T) {
        eventBus.emit(event)
    }
    
    // MARK: - Health Check
    
    public func healthCheck() async -> [String: Bool] {
        var status: [String: Bool] = [:]
        
        // Check registered services
        if let aiService = services.get(AIServiceProtocol.self) {
            status["aiService"] = await aiService.healthCheck()
        }
        
        // Check registered modules
        for (id, module) in modules {
            status["module_\(id)"] = module.isEnabled
        }
        
        // Check core components
        status["eventBus"] = eventBus.isHealthy
        status["services"] = services.isHealthy
        status["config"] = config.isHealthy
        
        return status
    }
    
    // MARK: - Private Setup
    
    private func setupEventListeners() {
        // Setup core event listeners
        addEventListener(for: ModuleExecutedEvent.self) { event in
            print("📦 [CORE] Module \(event.moduleId) executed: \(event.success ? "SUCCESS" : "FAILED")")
        }
    }
    
    private func registerDefaultServices() {
        // Register default services
        services.register(MockAIServiceImpl(), as: AIServiceProtocol.self)
    }
}

// MARK: - Supporting Types

public struct PipelineResult {
    public let success: Bool
    public let results: [String: Any]
    public let executionTime: TimeInterval
}

public enum PipelineState {
    case idle
    case running
    case completed
    case failed
}

// CoreError moved to DirectorStudioCore.swift to avoid duplication

// MARK: - Event Types

public struct ProjectUpdatedEvent {
    public let project: Project?
}

public struct PipelineStateUpdatedEvent {
    public let state: PipelineState
}

public struct CreditsUpdatedEvent {
    public let credits: Int
}

public struct ProcessingUpdatedEvent {
    public let isProcessing: Bool
}

public struct CurrentModuleUpdatedEvent {
    public let module: String
}

// ProgressUpdatedEvent moved to DirectorStudioCore.swift to avoid duplication

public struct ModuleExecutedEvent {
    public let moduleId: String
    public let success: Bool
}
