import Foundation

// MARK: - Prompt Segment Model
public struct PromptSegment: Codable, Identifiable, Sendable {
    // BugScan: character DNA noop touch for analysis
    public let id = UUID()
    public let index: Int
    public let duration: Int // Target duration in seconds
    public var content: String
    public let characters: [String]
    public let setting: String
    public let action: String
    public let continuityNotes: String
    public var cinematicTags: CinematicTaxonomy?
    
    // New properties for continuity engine
    public let location: String
    public let props: [String]
    public let tone: String
    
    public init(index: Int, duration: Int, content: String, characters: [String], setting: String, action: String, continuityNotes: String, location: String, props: [String], tone: String) {
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
    }
    
    enum CodingKeys: String, CodingKey {
        case index, duration, content, characters, setting, action
        case continuityNotes = "continuity_notes"
        case location, props, tone
    }
    
    // Convert to SceneModel for continuity validation
    func toSceneModel() -> SceneModel {
        return SceneModel(
            id: index,
            location: location,
            characters: characters,
            props: props,
            prompt: content,
            tone: tone
        )
    }
}

// MARK: - Segment Pacing Enum
public enum SegmentPacing: String, Sendable, Codable {
    case fast = "Fast"
    case moderate = "Moderate"
    case slow = "Slow"
    case building = "Building"
}

// MARK: - Transition Type Enum (moved to ContinuityModule.swift for richer functionality)

// MARK: - Supporting Types (referenced by PromptSegment)
public struct CinematicTaxonomy: Codable, Sendable {
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
    
    enum CodingKeys: String, CodingKey {
        case shotType = "shot_type"
        case cameraAngle = "camera_angle"
        case framing
        case lighting
        case colorPalette = "color_palette"
        case lensType = "lens_type"
        case cameraMovement = "camera_movement"
        case emotionalTone = "emotional_tone"
        case visualStyle = "visual_style"
        case actionCues = "action_cues"
    }
}

public struct SceneModel: Codable, Identifiable, Equatable, Sendable {
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

public struct Project: Codable, Identifiable, Equatable, Sendable {
    public var id: UUID
    public var name: String
    public var description: String
    public let createdAt: Date
    public var lastModified: Date
    public var status: ProjectStatus
    
    public init(
        id: UUID = UUID(),
        name: String,
        description: String,
        createdAt: Date = Date(),
        lastModified: Date = Date(),
        status: ProjectStatus = .draft
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.createdAt = createdAt
        self.lastModified = lastModified
        self.status = status
    }
}

public enum ProjectStatus: String, Codable, Sendable {
    case draft
    case inProgress = "in_progress"
    case completed
    case archived
}

public enum ProjectSortOrder: String, CaseIterable, Identifiable {
    case nameAscending = "Name (A-Z)"
    case nameDescending = "Name (Z-A)"
    case dateAscending = "Date (Oldest First)"
    case dateDescending = "Date (Newest First)"

    public var id: String { self.rawValue }

    public var sortFunction: (Project, Project) -> Bool {
        switch self {
        case .nameAscending:
            return { $0.name < $1.name }
        case .nameDescending:
            return { $0.name > $1.name }
        case .dateAscending:
            return { $0.lastModified < $1.lastModified }
        case .dateDescending:
            return { $0.lastModified > $1.lastModified }
        }
    }
}

// MARK: - Pipeline Configuration Models

public struct ModuleSettings {
    // Module toggles
    public var segmentationEnabled: Bool = true
    public var storyAnalysisEnabled: Bool = true
    public var rewordingEnabled: Bool = false
    public var taxonomyEnabled: Bool = true
    public var continuityEnabled: Bool = true
    
    // Advanced settings
    public var targetDuration: Double = 120.0
    public var videoQuality: VideoQuality = .high
    public var processingMode: ProcessingMode = .balanced
    
    public init() {}
}

public enum VideoQuality: String, CaseIterable, Sendable, Codable {
    case low
    case medium
    case high
    case ultra
}

public enum ProcessingMode: String, CaseIterable, Sendable {
    case fast = "Fast"
    case balanced = "Balanced"
    case quality = "Quality"
}
