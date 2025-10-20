import Foundation

// MARK: - Prompt Segment Model
public struct PromptSegment: Codable, Identifiable, Sendable {
    // BugScan: character DNA noop touch for analysis
    public let id = UUID()
    let index: Int
    let duration: Int // Target duration in seconds
    var content: String
    let characters: [String]
    let setting: String
    let action: String
    let continuityNotes: String
    var cinematicTags: CinematicTaxonomy?
    
    // New properties for continuity engine
    let location: String
    let props: [String]
    let tone: String
    
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

// MARK: - Transition Type Enum
public enum TransitionType: String, Sendable, Codable {
    case cut = "Cut"
    case fade = "Fade"
    case temporal = "Temporal"
    case spatial = "Spatial"
    case dialogue = "Dialogue"
    case hard = "Hard"
}

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
