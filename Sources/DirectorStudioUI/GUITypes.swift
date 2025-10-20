//
//  GUITypes.swift
//  DirectorStudioUI
//
//  Created by DirectorStudio on $(date)
//  Copyright © 2025 DirectorStudio. All rights reserved.
//

import Foundation
import SwiftUI

/// GUI-specific types for the UI layer

/// GUI Project representation
public struct GUIProject {
    public let id: UUID
    public let name: String
    public let description: String
    public let createdAt: Date
    public let lastModified: Date
    public let status: ProjectStatus
    public let segmentCount: Int
    public let hasVideo: Bool
    
    public init(
        id: UUID,
        name: String,
        description: String,
        createdAt: Date,
        lastModified: Date,
        status: ProjectStatus,
        segmentCount: Int,
        hasVideo: Bool
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.createdAt = createdAt
        self.lastModified = lastModified
        self.status = status
        self.segmentCount = segmentCount
        self.hasVideo = hasVideo
    }
}

/// GUI Segment representation
public struct GUISegment: Codable {
    public let id: UUID
    public let index: Int
    public let duration: Int
    public let content: String
    public let characters: [String]
    public let setting: String
    public let action: String
    public let continuityNotes: String
    
    public init(
        id: UUID,
        index: Int,
        duration: Int,
        content: String,
        characters: [String],
        setting: String,
        action: String,
        continuityNotes: String
    ) {
        self.id = id
        self.index = index
        self.duration = duration
        self.content = content
        self.characters = characters
        self.setting = setting
        self.action = action
        self.continuityNotes = continuityNotes
    }
}

/// GUI Story Analysis representation
public struct GUIStoryAnalysis {
    public let genre: String
    public let targetAudience: String
    public let estimatedDuration: Int
    public let complexityScore: Double
    public let narrativeArc: String
    public let emotionalCurve: String
    public let characterDevelopment: String
    public let themes: String
    
    public init(
        genre: String,
        targetAudience: String,
        estimatedDuration: Int,
        complexityScore: Double,
        narrativeArc: String,
        emotionalCurve: String,
        characterDevelopment: String,
        themes: String
    ) {
        self.genre = genre
        self.targetAudience = targetAudience
        self.estimatedDuration = estimatedDuration
        self.complexityScore = complexityScore
        self.narrativeArc = narrativeArc
        self.emotionalCurve = emotionalCurve
        self.characterDevelopment = characterDevelopment
        self.themes = themes
    }
}

/// GUI Video representation
public struct GUIVideo {
    public let id: UUID
    public let title: String
    public let description: String
    public let url: URL
    public let thumbnailURL: URL
    public let duration: Double
    public let fileSize: Int
    public let resolution: CGSize
    public let createdAt: Date
    public let tags: [String]
    
    public init(
        id: UUID,
        title: String,
        description: String,
        url: URL,
        thumbnailURL: URL,
        duration: Double,
        fileSize: Int,
        resolution: CGSize,
        createdAt: Date,
        tags: [String]
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.url = url
        self.thumbnailURL = thumbnailURL
        self.duration = duration
        self.fileSize = fileSize
        self.resolution = resolution
        self.createdAt = createdAt
        self.tags = tags
    }
}

/// Project Status enum
public enum ProjectStatus: String, CaseIterable {
    case draft = "Draft"
    case processing = "Processing"
    case complete = "Complete"
    case failed = "Failed"
}

/// Rewording Input for UI
public struct RewordingInput {
    public let text: String
    public let type: RewordingType
    
    public init(text: String, type: RewordingType) {
        self.text = text
        self.type = type
    }
}

/// Rewording Output for UI
public struct RewordingOutput {
    public let originalText: String
    public let rewordedText: String
    public let type: RewordingType
    public let processingTime: TimeInterval
    
    public init(originalText: String, rewordedText: String, type: RewordingType, processingTime: TimeInterval) {
        self.originalText = originalText
        self.rewordedText = rewordedText
        self.type = type
        self.processingTime = processingTime
    }
}
