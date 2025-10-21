//
//  GUIAbstraction.swift
//  DirectorStudio
//
//  MODULE: GUIAbstraction
//  VERSION: 1.0.0
//  PURPOSE: GUI abstraction layer for future SwiftUI integration
//

import Foundation

// MARK: - GUI Models

public struct GUIProject {
    public let id: UUID
    public let name: String
    public let description: String
    public let createdAt: Date
    public let updatedAt: Date
    public let segmentCount: Int
    public let hasVideo: Bool
    
    public init(
        id: UUID,
        name: String,
        description: String,
        createdAt: Date,
        updatedAt: Date,
        segmentCount: Int,
        hasVideo: Bool
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.segmentCount = segmentCount
        self.hasVideo = hasVideo
    }
    
    public init(from project: Project, segmentCount: Int = 0, hasVideo: Bool = false) {
        self.id = project.id
        self.name = project.name
        self.description = project.description
        self.createdAt = project.createdAt
        self.updatedAt = project.updatedAt
        self.segmentCount = segmentCount
        self.hasVideo = hasVideo
    }
}

public struct GUISegment: Codable {
    public let id: UUID
    public let index: Int
    public let duration: Int
    public let content: String
    public let characters: [String]
    public let setting: String
    public let action: String
    public let continuityNotes: String
    public let hasCinematicTags: Bool
    
    public init(
        id: UUID,
        index: Int,
        duration: Int,
        content: String,
        characters: [String],
        setting: String,
        action: String,
        continuityNotes: String,
        hasCinematicTags: Bool
    ) {
        self.id = id
        self.index = index
        self.duration = duration
        self.content = content
        self.characters = characters
        self.setting = setting
        self.action = action
        self.continuityNotes = continuityNotes
        self.hasCinematicTags = hasCinematicTags
    }
    
    public init(from segment: PromptSegment) {
        self.id = segment.id
        self.index = segment.index
        self.duration = segment.duration
        self.content = segment.content
        self.characters = segment.characters
        self.setting = segment.setting
        self.action = segment.action
        self.continuityNotes = segment.continuityNotes
        self.hasCinematicTags = segment.cinematicTags != nil
    }
}

public struct GUIVideo {
    public let url: URL
    public let duration: TimeInterval
    public let quality: VideoQuality
    public let format: VideoFormat
    public let fileSize: Int64
    
    public init(
        url: URL,
        duration: TimeInterval,
        quality: VideoQuality,
        format: VideoFormat,
        fileSize: Int64
    ) {
        self.url = url
        self.duration = duration
        self.quality = quality
        self.format = format
        self.fileSize = fileSize
    }
}

// MARK: - GUI Abstraction Protocol

public protocol GUIAbstractionProtocol {
    // Project Management
    func getProjects() async throws -> [GUIProject]
    func createProject(name: String, description: String) async throws -> GUIProject
    func loadProject(id: UUID) async throws -> GUIProject
    func saveProject() async throws -> GUIProject
    func deleteProject(id: UUID) async throws -> Bool
    
    // Segment Management
    func getSegments() async throws -> [GUISegment]
    func addSegment(_ content: String) async throws -> GUISegment
    func updateSegment(id: UUID, content: String) async throws -> GUISegment
    func deleteSegment(id: UUID) async throws -> Bool
    
    // Story Processing
    func segmentStory(story: String) async throws -> [GUISegment]
    func rewordSegment(id: UUID, style: RewordingStyle) async throws -> GUISegment
    func analyzeStory(story: String) async throws -> StoryAnalysis
    func enrichSegmentsWithTaxonomy() async throws -> [GUISegment]
    func validateContinuity() async throws -> [ContinuityIssue]
    
    // Video Generation
    func generateVideo(quality: VideoQuality, format: VideoFormat, style: VideoStyle) async throws -> GUIVideo
    func applyVideoEffects(videoURL: URL, effects: [VideoEffect]) async throws -> GUIVideo
    
    // Credits Management
    func getCreditsBalance() async throws -> Int
    func purchaseCredits(amount: Int) async throws -> Int
    
    // Settings
    func getUserSettings() async throws -> UserSettings
    func saveUserSettings(_ settings: UserSettings) async throws -> UserSettings
    
    // Status
    var isProcessing: Bool { get }
    var currentOperation: String { get }
    var progress: Double { get }
    
    // Events
    func addEventListener<T>(for eventType: T.Type, handler: @escaping (T) -> Void)
    func removeEventListeners<T>(for eventType: T.Type)
}

// MARK: - GUI Abstraction Implementation

public class GUIAbstraction: GUIAbstractionProtocol {
    private let core = DirectorStudioCore.shared
    
    public init() {}
    
    // MARK: - Project Management
    
    public func getProjects() async throws -> [GUIProject] {
        let projects = try core.persistenceManager.getAllProjects()
        
        if #available(iOS 15.0, *) {
            return try await withThrowingTaskGroup(of: GUIProject.self) { group in
                for project in projects {
                    group.addTask {
                        let segments = try self.core.persistenceManager.getSegments(projectId: project.id)
                        let hasVideo = try self.core.persistenceManager.getVideoMetadata(projectId: project.id) != nil
                        
                        return GUIProject(
                            from: project,
                            segmentCount: segments.count,
                            hasVideo: hasVideo
                        )
                    }
                }
                
                var guiProjects: [GUIProject] = []
                for try await project in group {
                    guiProjects.append(project)
                }
                
                return guiProjects.sorted(by: { $0.updatedAt > $1.updatedAt })
            }
        } else {
            // Fallback for iOS < 15.0 - sequential processing
            var guiProjects: [GUIProject] = []
            for project in projects {
                let segments = try core.persistenceManager.getSegments(projectId: project.id)
                let hasVideo = try core.persistenceManager.getVideoMetadata(projectId: project.id) != nil
                
                let guiProject = GUIProject(
                    from: project,
                    segmentCount: segments.count,
                    hasVideo: hasVideo
                )
                guiProjects.append(guiProject)
            }
            return guiProjects.sorted(by: { $0.updatedAt > $1.updatedAt })
        }
    }
    
    public func createProject(name: String, description: String) async throws -> GUIProject {
        let project = try core.createProject(name: name, description: description)
        return GUIProject(from: project)
    }
    
    public func loadProject(id: UUID) async throws -> GUIProject {
        let project = try core.loadProject(id: id)
        let segments = core.currentSegments
        let hasVideo = try core.persistenceManager.getVideoMetadata(projectId: project.id) != nil
        
        return GUIProject(
            from: project,
            segmentCount: segments.count,
            hasVideo: hasVideo
        )
    }
    
    public func saveProject() async throws -> GUIProject {
        try core.saveProject()
        
        guard let project = core.currentProject else {
            throw CoreError.noActiveProject
        }
        
        return GUIProject(
            from: project,
            segmentCount: core.currentSegments.count,
            hasVideo: try core.persistenceManager.getVideoMetadata(projectId: project.id) != nil
        )
    }
    
    public func deleteProject(id: UUID) async throws -> Bool {
        return try core.persistenceManager.deleteProject(id: id)
    }
    
    // MARK: - Segment Management
    
    public func getSegments() async throws -> [GUISegment] {
        return core.currentSegments.map { GUISegment(from: $0) }
    }
    
    public func addSegment(_ content: String) async throws -> GUISegment {
        let segment = PromptSegment(
            index: core.currentSegments.count + 1,
            duration: 5, // Default duration
            content: content,
            characters: [],
            setting: "",
            action: "",
            continuityNotes: "",
            location: "",
            props: [],
            tone: ""
        )
        
        try core.addSegment(segment)
        return GUISegment(from: segment)
    }
    
    public func updateSegment(id: UUID, content: String) async throws -> GUISegment {
        guard let index = core.currentSegments.firstIndex(where: { $0.id == id }) else {
            throw CoreError.segmentNotFound(id: id)
        }
        
        var segment = core.currentSegments[index]
        segment.content = content
        
        try core.updateSegment(segment)
        return GUISegment(from: segment)
    }
    
    public func deleteSegment(id: UUID) async throws -> Bool {
        try core.deleteSegment(id: id)
        return true
    }
    
    // MARK: - Story Processing
    
    public func segmentStory(story: String) async throws -> [GUISegment] {
        let segments = try await core.segmentStory(story: story)
        return segments.map { GUISegment(from: $0) }
    }
    
    public func rewordSegment(id: UUID, style: RewordingStyle) async throws -> GUISegment {
        let segment = try await core.rewordSegment(segmentId: id, style: style)
        return GUISegment(from: segment)
    }
    
    public func analyzeStory(story: String) async throws -> StoryAnalysis {
        return try await core.analyzeStory(story: story)
    }
    
    public func enrichSegmentsWithTaxonomy() async throws -> [GUISegment] {
        let segments = try await core.enrichSegmentsWithTaxonomy()
        return segments.map { GUISegment(from: $0) }
    }
    
    public func validateContinuity() async throws -> [ContinuityIssue] {
        let result = try await core.validateContinuity()
        return result.issues
    }
    
    // MARK: - Video Generation
    
    public func generateVideo(
        quality: VideoQuality = .high,
        format: VideoFormat = .mp4,
        style: VideoStyle = .cinematic
    ) async throws -> GUIVideo {
        let result = try await core.generateVideo(quality: quality, format: format, style: style)
        
        return GUIVideo(
            url: result.videoURL,
            duration: result.duration,
            quality: result.quality,
            format: result.format,
            fileSize: result.fileSize
        )
    }
    
    public func applyVideoEffects(videoURL: URL, effects: [VideoEffect]) async throws -> GUIVideo {
        let result = try await core.applyVideoEffects(videoURL: videoURL, effects: effects)
        
        return GUIVideo(
            url: result.processedVideoURL,
            duration: result.metadata.processedDuration,
            quality: result.quality,
            format: .mp4, // Assuming mp4 format
            fileSize: result.fileSize
        )
    }
    
    // MARK: - Credits Management
    
    public func getCreditsBalance() async throws -> Int {
        return core.monetizationManager.currentCredits
    }
    
    public func purchaseCredits(amount: Int) async throws -> Int {
        let products = try await core.monetizationManager.getAvailableProducts()
        
        guard let creditProduct = products.first(where: { $0.type == .credits && $0.credits == amount }) else {
            throw MonetizationError.productNotAvailable
        }
        
        let result = try await core.monetizationManager.purchaseProduct(creditProduct.id)
        
        guard result.success else {
            if let error = result.error {
                throw MonetizationError.purchaseFailed(error.rawValue)
            } else {
                throw MonetizationError.purchaseFailed("Unknown error")
            }
        }
        
        return core.monetizationManager.currentCredits
    }
    
    // MARK: - Settings
    
    public func getUserSettings() async throws -> UserSettings {
        return try core.persistenceManager.getUserSettings()
    }
    
    public func saveUserSettings(_ settings: UserSettings) async throws -> UserSettings {
        return try core.persistenceManager.saveUserSettings(settings)
    }
    
    // MARK: - Status
    
    public var isProcessing: Bool {
        return core.isProcessing
    }
    
    public var currentOperation: String {
        return core.currentOperation
    }
    
    public var progress: Double {
        return core.progress
    }
    
    // MARK: - Events
    
    public func addEventListener<T>(for eventType: T.Type, handler: @escaping (T) -> Void) {
        core.addEventListener(for: eventType, handler: handler)
    }
    
    public func removeEventListeners<T>(for eventType: T.Type) {
        core.removeEventListeners(for: eventType)
    }
}
