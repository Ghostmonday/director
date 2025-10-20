# 🎬 Video Generation Pipeline - Complete Specification

**Date:** October 19, 2025  
**Status:** ⚠️ CRITICAL ADDITION  
**Purpose:** Prompt-to-Video Generation with Intelligent Clip Calculation

---

## 🎯 Overview

The Video Generation Pipeline analyzes finalized prompt segments from the reconstruction pipeline and automatically calculates how many individual video clips are required to create a full cinematic sequence.

---

## 📊 Pipeline Flow

```
User Story Input
    ↓
Segmentation Module (calculates clips needed)
    ↓
Story Analysis Module (enriches each segment)
    ↓
Taxonomy Module (adds cinematic metadata)
    ↓
Continuity Module (validates flow)
    ↓
Video Generation Module (creates clips via Pollo API)
    ↓
Assembly & Export Module (stitches into final film)
```

---

## 🔢 Clip Calculation Logic

### Automatic Calculation:
The system analyzes the finalized prompt segments and determines:
1. **Number of clips** = Number of PromptSegments
2. **Duration per clip** = User-defined (default: 4 seconds)
3. **Total video duration** = clips × duration
4. **Scene changes** = Detected by Segmentation Module
5. **Shot changes** = Detected by Taxonomy Module

### User Customization:
```swift
struct VideoGenerationConfig {
    var durationPerClip: TimeInterval = 4.0  // User adjustable: 2-20 seconds
    var totalClips: Int                      // Auto-calculated from segments
    var totalDuration: TimeInterval          // Auto-calculated: clips × duration
    var allowManualOverride: Bool = true     // User can adjust clip count
}
```

---

## 📦 Module Integration

### 1. Segmentation Module (EXISTING - NEEDS UPDATE)
**File:** `segmentation.swift`  
**Current:** Creates PromptSegments with duration  
**Needs:** Video clip count calculation

```swift
public struct SegmentationOutput {
    public let segments: [PromptSegment]
    public let totalSegments: Int              // ✅ Already has this
    public let averageDuration: TimeInterval   // ✅ Already has this
    
    // ADD:
    public let videoClipCount: Int             // Number of video clips needed
    public let recommendedClipDuration: TimeInterval  // Based on pacing
    public let totalVideoDuration: TimeInterval       // Total film length
}
```

**Update Required:**
```swift
// In SegmentationModule.execute():
let videoClipCount = segments.count
let recommendedClipDuration = calculateOptimalDuration(for: segments)
let totalVideoDuration = Double(videoClipCount) * recommendedClipDuration
```

---

### 2. Video Generation Module (NEW - MUST CREATE)
**File:** `VideoGenerationModule.swift`  
**Priority:** 🔴 CRITICAL  
**Purpose:** Generate individual video clips from prompt segments

```swift
// MARK: - Input
public struct VideoGenerationInput {
    public let segments: [PromptSegment]           // From Segmentation
    public let durationPerClip: TimeInterval       // User-defined (default: 4s)
    public let style: VideoStyle                   // Cinematic style
    public let resolution: VideoResolution         // 1080p, 4K, etc.
    
    public init(segments: [PromptSegment], 
                durationPerClip: TimeInterval = 4.0,
                style: VideoStyle = .cinematic,
                resolution: VideoResolution = .hd1080) {
        self.segments = segments
        self.durationPerClip = durationPerClip
        self.style = style
        self.resolution = resolution
    }
}

// MARK: - Output
public struct VideoGenerationOutput {
    public let clips: [VideoClip]
    public let totalClips: Int
    public let totalDuration: TimeInterval
    public let generationTime: TimeInterval
    public let failedClips: [FailedClip]
}

public struct VideoClip: Identifiable, Codable {
    public let id: UUID
    public let segmentID: UUID                     // Links to PromptSegment
    public let order: Int
    public let duration: TimeInterval
    public let videoURL: URL?                      // Generated video URL
    public let thumbnailURL: URL?                  // Preview thumbnail
    public let status: ClipStatus
    public let metadata: VideoMetadata
    
    public enum ClipStatus: String, Codable {
        case pending = "Pending"
        case generating = "Generating"
        case completed = "Completed"
        case failed = "Failed"
    }
}

public struct VideoMetadata: Codable {
    public let promptText: String
    public let shotType: String?
    public let cameraMovement: String?
    public let lighting: String?
    public let mood: String?
    public let generatedAt: Date
}

// MARK: - Module
@MainActor
public final class VideoGenerationModule: ModuleProtocol {
    public typealias Input = VideoGenerationInput
    public typealias Output = VideoGenerationOutput
    
    public let id = "video-generation"
    public let name = "Video Generation"
    public var isEnabled = true
    
    private let imageService: ImageGenerationService  // Uses Pollo API
    
    public init(imageService: ImageGenerationService) {
        self.imageService = imageService
    }
    
    public func validate(input: VideoGenerationInput) -> Bool {
        return !input.segments.isEmpty && 
               input.durationPerClip > 0 &&
               input.durationPerClip <= 20.0
    }
    
    public func execute(input: VideoGenerationInput) async throws -> VideoGenerationOutput {
        let startTime = Date()
        var clips: [VideoClip] = []
        var failedClips: [FailedClip] = []
        
        // Calculate total clips needed
        let totalClips = input.segments.count
        
        // Generate each video clip
        for (index, segment) in input.segments.enumerated() {
            do {
                // Build enhanced prompt with cinematic metadata
                let enhancedPrompt = buildEnhancedPrompt(
                    segment: segment,
                    style: input.style,
                    duration: input.durationPerClip
                )
                
                // Generate video via Pollo API
                let result = try await imageService.generateVideo(
                    prompt: enhancedPrompt,
                    duration: input.durationPerClip,
                    resolution: input.resolution
                )
                
                // Create VideoClip
                let clip = VideoClip(
                    id: UUID(),
                    segmentID: segment.id,
                    order: index,
                    duration: input.durationPerClip,
                    videoURL: result.videoURL,
                    thumbnailURL: result.thumbnailURL,
                    status: .completed,
                    metadata: VideoMetadata(
                        promptText: segment.text,
                        shotType: segment.metadata["shotType"],
                        cameraMovement: segment.metadata["cameraMovement"],
                        lighting: segment.metadata["lighting"],
                        mood: segment.metadata["mood"],
                        generatedAt: Date()
                    )
                )
                
                clips.append(clip)
                
            } catch {
                failedClips.append(FailedClip(
                    segmentID: segment.id,
                    order: index,
                    error: error.localizedDescription
                ))
            }
        }
        
        let totalDuration = Double(clips.count) * input.durationPerClip
        let generationTime = Date().timeIntervalSince(startTime)
        
        return VideoGenerationOutput(
            clips: clips,
            totalClips: totalClips,
            totalDuration: totalDuration,
            generationTime: generationTime,
            failedClips: failedClips
        )
    }
    
    private func buildEnhancedPrompt(segment: PromptSegment, 
                                    style: VideoStyle, 
                                    duration: TimeInterval) -> String {
        var prompt = segment.text
        
        // Add cinematic metadata from Taxonomy
        if let shotType = segment.metadata["shotType"] {
            prompt += ", \(shotType) shot"
        }
        if let cameraMovement = segment.metadata["cameraMovement"] {
            prompt += ", \(cameraMovement) camera movement"
        }
        if let lighting = segment.metadata["lighting"] {
            prompt += ", \(lighting) lighting"
        }
        if let mood = segment.metadata["mood"] {
            prompt += ", \(mood) mood"
        }
        
        // Add style and duration
        prompt += ", \(style.rawValue) style, \(Int(duration)) seconds"
        
        return prompt
    }
}

public enum VideoStyle: String, Codable {
    case cinematic = "cinematic"
    case documentary = "documentary"
    case dramatic = "dramatic"
    case action = "action"
    case artistic = "artistic"
}

public enum VideoResolution: String, Codable {
    case sd480 = "480p"
    case hd720 = "720p"
    case hd1080 = "1080p"
    case uhd4k = "4K"
}

public struct FailedClip: Codable {
    public let segmentID: UUID
    public let order: Int
    public let error: String
}
```

---

### 3. Assembly & Export Module (NEW - MUST CREATE)
**File:** `VideoAssemblyModule.swift`  
**Priority:** 🔴 CRITICAL  
**Purpose:** Stitch individual clips into final film

```swift
// MARK: - Input
public struct VideoAssemblyInput {
    public let clips: [VideoClip]                  // From Video Generation
    public let continuityReport: ContinuityReport  // From Continuity Module
    public let transitions: [TransitionType]       // Between clips
    public let exportFormat: ExportFormat
    
    public init(clips: [VideoClip],
                continuityReport: ContinuityReport,
                transitions: [TransitionType] = [],
                exportFormat: ExportFormat = .mp4) {
        self.clips = clips
        self.continuityReport = continuityReport
        self.transitions = transitions
        self.exportFormat = exportFormat
    }
}

// MARK: - Output
public struct VideoAssemblyOutput {
    public let finalVideoURL: URL
    public let totalDuration: TimeInterval
    public let clipCount: Int
    public let resolution: VideoResolution
    public let fileSize: Int64
    public let assemblyTime: TimeInterval
    public let continuityScore: Double             // From Continuity Module
}

// MARK: - Module
@MainActor
public final class VideoAssemblyModule: ModuleProtocol {
    public typealias Input = VideoAssemblyInput
    public typealias Output = VideoAssemblyOutput
    
    public let id = "video-assembly"
    public let name = "Video Assembly & Export"
    public var isEnabled = true
    
    public func validate(input: VideoAssemblyInput) -> Bool {
        return !input.clips.isEmpty &&
               input.clips.allSatisfy { $0.status == .completed }
    }
    
    public func execute(input: VideoAssemblyInput) async throws -> VideoAssemblyOutput {
        let startTime = Date()
        
        // Sort clips by order
        let sortedClips = input.clips.sorted { $0.order < $1.order }
        
        // Apply continuity fixes if needed
        let adjustedClips = applyContinuityFixes(
            clips: sortedClips,
            report: input.continuityReport
        )
        
        // Stitch clips together
        let finalVideoURL = try await stitchClips(
            clips: adjustedClips,
            transitions: input.transitions,
            format: input.exportFormat
        )
        
        // Calculate metrics
        let totalDuration = adjustedClips.reduce(0) { $0 + $1.duration }
        let fileSize = try getFileSize(url: finalVideoURL)
        let assemblyTime = Date().timeIntervalSince(startTime)
        
        return VideoAssemblyOutput(
            finalVideoURL: finalVideoURL,
            totalDuration: totalDuration,
            clipCount: adjustedClips.count,
            resolution: .hd1080,  // From clips
            fileSize: fileSize,
            assemblyTime: assemblyTime,
            continuityScore: input.continuityReport.overallScore
        )
    }
    
    private func applyContinuityFixes(clips: [VideoClip], 
                                     report: ContinuityReport) -> [VideoClip] {
        // Apply fixes based on continuity issues
        // e.g., adjust transitions, add bridging shots, etc.
        return clips
    }
    
    private func stitchClips(clips: [VideoClip],
                            transitions: [TransitionType],
                            format: ExportFormat) async throws -> URL {
        // Use AVFoundation to stitch clips
        // Apply transitions between clips
        // Export to final format
        // Return URL of final video
        return URL(fileURLWithPath: "/path/to/final/video.mp4")
    }
    
    private func getFileSize(url: URL) throws -> Int64 {
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        return attributes[.size] as? Int64 ?? 0
    }
}

public enum TransitionType: String, Codable {
    case cut = "Cut"
    case fade = "Fade"
    case dissolve = "Dissolve"
    case wipe = "Wipe"
}

public enum ExportFormat: String, Codable {
    case mp4 = "MP4"
    case mov = "MOV"
    case avi = "AVI"
}
```

---

### 4. Continuity Module (EXISTING - NEEDS UPDATE)
**File:** `continuity.swift`  
**Current:** Validates continuity across segments  
**Needs:** Video-specific continuity checks

```swift
// ADD to ContinuityModule:
public func validateVideoSequence(clips: [VideoClip]) -> VideoSequenceReport {
    // Check for:
    // - Visual continuity between clips
    // - Temporal consistency
    // - Character appearance consistency
    // - Location consistency
    // - Lighting/mood transitions
    
    return VideoSequenceReport(
        issues: detectVideoIssues(clips),
        recommendations: generateVideoRecommendations(clips),
        overallScore: calculateVideoScore(clips)
    )
}
```

---

## 🎛️ User Controls

### Video Generation Settings UI:
```swift
struct VideoGenerationSettingsView: View {
    @State var durationPerClip: TimeInterval = 4.0
    @State var totalClips: Int = 0  // Auto-calculated
    @State var style: VideoStyle = .cinematic
    @State var resolution: VideoResolution = .hd1080
    
    var body: some View {
        Form {
            Section("Clip Settings") {
                // Duration per clip slider (2-20 seconds)
                VStack {
                    Text("Duration per Clip: \(Int(durationPerClip))s")
                    Slider(value: $durationPerClip, in: 2...20, step: 1)
                }
                
                // Auto-calculated clip count
                HStack {
                    Text("Total Clips")
                    Spacer()
                    Text("\(totalClips)")
                        .foregroundColor(.secondary)
                }
                
                // Auto-calculated total duration
                HStack {
                    Text("Total Duration")
                    Spacer()
                    Text("\(Int(Double(totalClips) * durationPerClip))s")
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Style") {
                Picker("Video Style", selection: $style) {
                    ForEach(VideoStyle.allCases, id: \.self) { style in
                        Text(style.rawValue.capitalized)
                    }
                }
                
                Picker("Resolution", selection: $resolution) {
                    ForEach(VideoResolution.allCases, id: \.self) { res in
                        Text(res.rawValue)
                    }
                }
            }
            
            Section("Preview") {
                Text("Your story will be split into \(totalClips) video clips")
                Text("Each clip will be \(Int(durationPerClip)) seconds long")
                Text("Final film will be \(Int(Double(totalClips) * durationPerClip)) seconds")
            }
        }
    }
}
```

---

## 🔗 Pipeline Integration Points

### 1. Segmentation → Video Generation:
```swift
// After Segmentation Module:
let segmentationOutput = try await segmentationModule.execute(input: segmentationInput)

// Calculate video generation parameters:
let videoInput = VideoGenerationInput(
    segments: segmentationOutput.segments,
    durationPerClip: userSettings.durationPerClip,  // User-defined
    style: userSettings.videoStyle,
    resolution: userSettings.resolution
)

// Generate videos:
let videoOutput = try await videoGenerationModule.execute(input: videoInput)
```

### 2. Continuity → Assembly:
```swift
// After Continuity Module:
let continuityReport = try await continuityModule.execute(input: continuityInput)

// Assemble final video:
let assemblyInput = VideoAssemblyInput(
    clips: videoOutput.clips,
    continuityReport: continuityReport,
    transitions: userSettings.transitions,
    exportFormat: userSettings.exportFormat
)

let finalVideo = try await videoAssemblyModule.execute(input: assemblyInput)
```

---

## 📋 Cheetah Task Additions

### NEW Task 1.10: Update Segmentation for Video Calculation
**File:** `segmentation.swift`  
**Priority:** 🔴 CRITICAL  
**Estimated Time:** 1 hour

**Add to SegmentationOutput:**
- `videoClipCount: Int`
- `recommendedClipDuration: TimeInterval`
- `totalVideoDuration: TimeInterval`

**Validation:**
- [ ] Calculates clip count correctly
- [ ] Recommends optimal duration
- [ ] Calculates total video duration

---

### NEW Task 7.1: Create VideoGenerationModule
**File:** `VideoGenerationModule.swift`  
**Priority:** 🔴 CRITICAL  
**Estimated Time:** 4 hours

**Implementation:**
- [ ] Create VideoGenerationInput/Output
- [ ] Implement clip generation logic
- [ ] Integrate with Pollo API (ImageGenerationService)
- [ ] Handle failed clips gracefully
- [ ] Build enhanced prompts with cinematic metadata

**Validation:**
- [ ] Generates correct number of clips
- [ ] Respects user-defined duration
- [ ] Uses Pollo API correctly
- [ ] Handles errors gracefully

---

### NEW Task 7.2: Create VideoAssemblyModule
**File:** `VideoAssemblyModule.swift`  
**Priority:** 🔴 CRITICAL  
**Estimated Time:** 5 hours

**Implementation:**
- [ ] Create VideoAssemblyInput/Output
- [ ] Implement clip stitching with AVFoundation
- [ ] Apply transitions between clips
- [ ] Integrate continuity fixes
- [ ] Export to multiple formats

**Validation:**
- [ ] Stitches clips in correct order
- [ ] Applies transitions correctly
- [ ] Exports to valid format
- [ ] Final video plays correctly

---

### NEW Task 7.3: Build Video Generation UI
**File:** `VideoGenerationView.swift`  
**Priority:** 🔴 CRITICAL  
**Estimated Time:** 3 hours

**UI Requirements:**
- Duration per clip slider (2-20s)
- Auto-calculated clip count display
- Total duration display
- Style/resolution pickers
- Progress indicator during generation
- Preview of generated clips
- Export button

**Validation:**
- [ ] UI updates clip count automatically
- [ ] Duration slider works
- [ ] Shows generation progress
- [ ] Displays generated clips
- [ ] Export button works

---

## ✅ Confirmation Checklist

### Prompt-to-Video Process:
- [x] Analyzes finalized prompt segments
- [x] Calculates number of clips needed
- [x] Allows user-defined duration per clip
- [x] Determines clips based on scene/shot changes
- [x] Integrates with Segmentation Module
- [x] Integrates with Continuity Module
- [x] Integrates with Export/Assembly system
- [x] Assembles film coherently

### Module Coverage:
- [x] Segmentation: Calculates clip count
- [x] Video Generation: Creates individual clips
- [x] Continuity: Validates video sequence
- [x] Assembly: Stitches clips into final film
- [x] Export: Outputs in multiple formats

---

## 🚀 Summary

**The Video Generation Pipeline is now fully specified:**

1. ✅ **Segmentation Module** calculates how many clips needed
2. ✅ **Video Generation Module** creates each clip via Pollo API
3. ✅ **Continuity Module** validates video sequence
4. ✅ **Assembly Module** stitches clips into final film
5. ✅ **User controls** for duration, style, resolution
6. ✅ **Clear integration** between all modules

**This ensures the film is assembled coherently with full user control.**

---

**Status:** ✅ FULLY SPECIFIED - READY FOR IMPLEMENTATION

