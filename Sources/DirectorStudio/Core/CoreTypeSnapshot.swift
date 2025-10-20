//
//  CoreTypeSnapshot.swift
//  DirectorStudio
//
//  PREEMPTIVE HARDENING: Core Type Interface Freeze
//  This file contains frozen type definitions to prevent breaking changes
//  during automated execution. All core types are locked to prevent
//  interface drift that could cause runtime failures.
//

import Foundation

// MARK: - Frozen Core Type Definitions

/// Frozen snapshot of core types to prevent interface drift
/// Generated during preemptive hardening phase
public struct CoreTypeSnapshot {
    
    // MARK: - PromptSegment Interface (Frozen)
    @frozen
    public struct PromptSegmentInterface {
        public let id: UUID
        public let index: Int
        public let duration: Int
        public let content: String
        public let characters: [String]
        public let setting: String
        public let action: String
        public let continuityNotes: String
        public let cinematicTags: CinematicTaxonomy?
        public let location: String
        public let props: [String]
        public let tone: String
        
        public init(
            id: UUID = UUID(),
            index: Int,
            duration: Int,
            content: String,
            characters: [String],
            setting: String,
            action: String,
            continuityNotes: String,
            location: String,
            props: [String],
            tone: String,
            cinematicTags: CinematicTaxonomy? = nil
        ) {
            self.id = id
            self.index = index
            self.duration = duration
            self.content = content
            self.characters = characters
            self.setting = setting
            self.action = action
            self.continuityNotes = continuityNotes
            self.location = location
            self.props = props
            self.tone = tone
            self.cinematicTags = cinematicTags
        }
    }
    
    // MARK: - PipelineContext Interface (Frozen)
    @frozen
    public struct PipelineContextInterface {
        public let id: UUID
        public let timestamp: Date
        public let configuration: PipelineConfigurationInterface
        public let metadata: [String: String]
        
        public init(
            id: UUID = UUID(),
            timestamp: Date = Date(),
            configuration: PipelineConfigurationInterface,
            metadata: [String: String] = [:]
        ) {
            self.id = id
            self.timestamp = timestamp
            self.configuration = configuration
            self.metadata = metadata
        }
    }
    
    // MARK: - PipelineConfiguration Interface (Frozen)
    @frozen
    public struct PipelineConfigurationInterface {
        public let maxDuration: TimeInterval
        public let quality: String
        public let outputFormat: String
        
        public init(
            maxDuration: TimeInterval = 4.0,
            quality: String = "high",
            outputFormat: String = "mp4"
        ) {
            self.maxDuration = maxDuration
            self.quality = quality
            self.outputFormat = outputFormat
        }
    }
    
    // MARK: - AIService Interface (Frozen)
    public protocol AIServiceInterface {
        func generateText(prompt: String) async throws -> String
        func generateImage(prompt: String) async throws -> Data
        func analyzeContent(_ content: String) async throws -> ContentAnalysisInterface
    }
    
    // MARK: - ContentAnalysis Interface (Frozen)
    @frozen
    public struct ContentAnalysisInterface {
        public let sentiment: String
        public let topics: [String]
        public let confidence: Double
        
        public init(sentiment: String, topics: [String], confidence: Double) {
            self.sentiment = sentiment
            self.topics = topics
            self.confidence = confidence
        }
    }
    
    // MARK: - CinematicTaxonomy Interface (Frozen)
    @frozen
    public struct CinematicTaxonomyInterface {
        public let shotType: String
        public let cameraAngle: String
        public let framing: String
        public let lighting: String
        public let colorPalette: String
        public let lensType: String
        public let cameraMovement: String
        public let emotionalTone: String
        public let visualStyle: String
        public let actionCues: [String]
        
        public init(
            shotType: String,
            cameraAngle: String,
            framing: String,
            lighting: String,
            colorPalette: String,
            lensType: String,
            cameraMovement: String,
            emotionalTone: String,
            visualStyle: String,
            actionCues: [String]
        ) {
            self.shotType = shotType
            self.cameraAngle = cameraAngle
            self.framing = framing
            self.lighting = lighting
            self.colorPalette = colorPalette
            self.lensType = lensType
            self.cameraMovement = cameraMovement
            self.emotionalTone = emotionalTone
            self.visualStyle = visualStyle
            self.actionCues = actionCues
        }
    }
    
    // MARK: - SceneModel Interface (Frozen)
    @frozen
    public struct SceneModelInterface {
        public let id: Int
        public let location: String
        public let characters: [String]
        public let props: [String]
        public let prompt: String
        public let tone: String
        
        public init(
            id: Int,
            location: String,
            characters: [String],
            props: [String],
            prompt: String,
            tone: String
        ) {
            self.id = id
            self.location = location
            self.characters = characters
            self.props = props
            self.prompt = prompt
            self.tone = tone
        }
    }
}

// MARK: - Type Alias Wrappers for Runtime Verification

public typealias FrozenPromptSegment = CoreTypeSnapshot.PromptSegmentInterface
public typealias FrozenPipelineContext = CoreTypeSnapshot.PipelineContextInterface
public typealias FrozenPipelineConfiguration = CoreTypeSnapshot.PipelineConfigurationInterface
public typealias FrozenAIService = CoreTypeSnapshot.AIServiceInterface
public typealias FrozenContentAnalysis = CoreTypeSnapshot.ContentAnalysisInterface
public typealias FrozenCinematicTaxonomy = CoreTypeSnapshot.CinematicTaxonomyInterface
public typealias FrozenSceneModel = CoreTypeSnapshot.SceneModelInterface

// MARK: - Interface Verification Protocol

public protocol CoreTypeVerifiable {
    func verifyInterfaceCompatibility() throws
}

// MARK: - Snapshot Version and Timestamp

public struct SnapshotMetadata {
    public static let version = "1.0.0"
    public static let createdAt = "2025-01-27T00:00:00Z"
    public static let frozenTypes = [
        "PromptSegment",
        "PipelineContext", 
        "PipelineConfiguration",
        "AIService",
        "ContentAnalysis",
        "CinematicTaxonomy",
        "SceneModel"
    ]
}
