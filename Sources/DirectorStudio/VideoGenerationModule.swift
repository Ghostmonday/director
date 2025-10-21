//
//  VideoGenerationModule.swift
//  DirectorStudio
//
//  MODULE: VideoGenerationModule
//  VERSION: 1.0.0
//  PURPOSE: AI-powered video generation and assembly pipeline
//

import Foundation
import AVFoundation

// MARK: - Video Generation Input/Output Types

public enum VideoGenerationError: Error, LocalizedError {
    case generationFailed(String)
    case invalidInput(String)
    case apiError(String)
    
    public var errorDescription: String? {
        switch self {
        case .generationFailed(let message):
            return "Video generation failed: \(message)"
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        case .apiError(let message):
            return "API error: \(message)"
        }
    }
}

public struct VideoGenerationInput: Sendable, Codable {
    public let segments: [PromptSegment]
    public let projectName: String
    public let outputFormat: VideoFormat
    public let quality: VideoQuality
    public let duration: TimeInterval
    public let style: VideoStyle
    
    public init(
        segments: [PromptSegment],
        projectName: String,
        outputFormat: VideoFormat = .mp4,
        quality: VideoQuality = .high,
        duration: TimeInterval = 4.0,
        style: VideoStyle = .cinematic
    ) {
        self.segments = segments
        self.projectName = projectName
        self.outputFormat = outputFormat
        self.quality = quality
        self.duration = duration
        self.style = style
    }
}

public struct VideoGenerationOutput: Sendable, Codable {
    public typealias VideoMetadataType = GenerationVideoMetadata
    public let videoURL: URL
    public let duration: TimeInterval
    public let fileSize: Int64
    public let quality: VideoQuality
    public let format: VideoFormat
    public let metadata: VideoMetadataType
    public let processingTime: TimeInterval
    
    public init(
        videoURL: URL,
        duration: TimeInterval,
        fileSize: Int64,
        quality: VideoQuality,
        format: VideoFormat,
        metadata: VideoMetadataType,
        processingTime: TimeInterval
    ) {
        self.videoURL = videoURL
        self.duration = duration
        self.fileSize = fileSize
        self.quality = quality
        self.format = format
        self.metadata = metadata
        self.processingTime = processingTime
    }
}

// MARK: - Supporting Types

public enum VideoFormat: String, Sendable, Codable, CaseIterable {
    case mp4 = "mp4"
    case mov = "mov"
    case avi = "avi"
    case webm = "webm"
    
    public var fileExtension: String {
        return rawValue
    }
}

public enum VideoQuality: String, Sendable, Codable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case ultra = "ultra"
    
    public var resolution: CGSize {
        switch self {
        case .low: return CGSize(width: 640, height: 480)
        case .medium: return CGSize(width: 1280, height: 720)
        case .high: return CGSize(width: 1920, height: 1080)
        case .ultra: return CGSize(width: 3840, height: 2160)
        }
    }
    
    public var bitrate: Int {
        switch self {
        case .low: return 500_000
        case .medium: return 2_000_000
        case .high: return 8_000_000
        case .ultra: return 25_000_000
        }
    }
}

public enum VideoStyle: String, Sendable, Codable, CaseIterable {
    case cinematic = "cinematic"
    case documentary = "documentary"
    case animated = "animated"
    case artistic = "artistic"
    case commercial = "commercial"
}

public struct GenerationVideoMetadata: Sendable, Codable {
    public let title: String
    public let description: String
    public let tags: [String]
    public let creationDate: Date
    public let creator: String
    public let version: String
    
    public init(
        title: String,
        description: String,
        tags: [String] = [],
        creationDate: Date = Date(),
        creator: String = "DirectorStudio",
        version: String = "1.0.0"
    ) {
        self.title = title
        self.description = description
        self.tags = tags
        self.creationDate = creationDate
        self.creator = creator
        self.version = version
    }
}

// MARK: - Video Generation Module

@available(iOS 15.0, *)
public final class VideoGenerationModule: PipelineModule, @unchecked Sendable {
    public typealias Input = VideoGenerationInput
    public typealias Output = VideoGenerationOutput
    
    public let id = "videogeneration"
    public let name = "Video Generation"
    public let version = "1.0.0"
    public var isEnabled = true
    
    private let aiService: AIServiceProtocol
    
    public func validate(input: VideoGenerationInput) -> Bool {
        return !input.segments.isEmpty && input.duration > 0
    }
    private let fileManager = FileManager.default
    
    public init(aiService: AIServiceProtocol = MockAIService()) {
        self.aiService = aiService
    }
    
    // MARK: - PipelineModule Implementation
    
    public func execute(input: VideoGenerationInput, context: PipelineContext) async -> Result<VideoGenerationOutput, PipelineError> {
        let startTime = Date()
        
        do {
            Telemetry.shared.logEvent("video_generation_started", properties: [
                "project_name": input.projectName,
                "segment_count": input.segments.count,
                "style": input.style.rawValue,
                "quality": input.quality.rawValue
            ])
            
            // Phase 1: Generate video clips for each segment
            let videoClips = try await generateVideoClips(for: input.segments, style: input.style, quality: input.quality)
            
            // Phase 2: Assemble clips into final video
            let assembledVideo = try await assembleVideo(clips: videoClips, input: input)
            
            // Phase 3: Apply post-processing effects
            let finalVideo = try await applyPostProcessing(to: assembledVideo, style: input.style)
            
            // Phase 4: Generate metadata
            let metadata = GenerationVideoMetadata(
                title: input.projectName,
                description: "AI-generated video from \(input.segments.count) story segments",
                tags: input.segments.compactMap { $0.cinematicTags != nil ? [$0.cinematicTags!.visualStyle] : [] }.flatMap { $0 }
            )
            
            let processingTime = Date().timeIntervalSince(startTime)
            let fileSize = try getFileSize(url: finalVideo)
            
            let output = VideoGenerationOutput(
                videoURL: finalVideo,
                duration: input.duration,
                fileSize: fileSize,
                quality: input.quality,
                format: input.outputFormat,
                metadata: metadata,
                processingTime: processingTime
            )
            
            Telemetry.shared.logEvent("video_generation_completed", properties: [
                "processing_time": processingTime,
                "output_path": finalVideo.path,
                "file_size": fileSize
            ])
            
            return .success(output)
            
        } catch {
            Telemetry.shared.logEvent("video_generation_failed", properties: ["error": error.localizedDescription])
            return .failure(.executionFailed(error.localizedDescription))
        }
    }
    
    // MARK: - Video Generation Methods
    
    private func generateVideoClips(for segments: [PromptSegment], style: VideoStyle, quality: VideoQuality) async throws -> [URL] {
        var clips: [URL] = []
        
        for (index, segment) in segments.enumerated() {
            Telemetry.shared.logEvent("video_clip_generation", properties: [
                "clip_index": index + 1,
                "total_clips": segments.count,
                "content_preview": String(segment.content.prefix(50))
            ])
            
            // Generate AI prompt for video creation
            let videoPrompt = createVideoPrompt(from: segment, style: style)
            
            // Simulate video generation (in real implementation, this would call video generation AI)
            let clipURL = try await generateVideoClip(
                prompt: videoPrompt,
                duration: TimeInterval(segment.duration),
                quality: quality,
                index: index
            )
            
            clips.append(clipURL)
        }
        
        return clips
    }
    
    @available(iOS 15.0, *)
    private func generateVideoClip(prompt: String, duration: TimeInterval, quality: VideoQuality, index: Int) async throws -> URL {
        // 🎥 REAL VIDEO GENERATION using Pollo API
        Telemetry.shared.logEvent("pollo_api_video_generation_started", properties: [
            "clip_index": index,
            "duration": duration,
            "quality": quality.rawValue,
            "prompt_length": prompt.count
        ])
        
        let result = await PolloAPIService.shared.generateVideo(
            prompt: prompt,
            style: quality.rawValue, // Use quality as style hint
            duration: Int(duration)
        )
        
        switch result.status {
        case .success:
            guard let videoURL = result.videoURL else {
                throw VideoGenerationError.generationFailed("Pollo API returned no video URL")
            }
            
            Telemetry.shared.logEvent("pollo_api_video_generation_success", properties: [
                "clip_index": index,
                "file_path": videoURL.lastPathComponent,
                "file_size": (try? FileManager.default.attributesOfItem(atPath: videoURL.path)[.size] as? Int) ?? 0
            ])
            
            return videoURL
            
        case .failed:
            let errorMsg = result.errorMessage ?? "Unknown Pollo API error"
            Telemetry.shared.logEvent("pollo_api_video_generation_failed", properties: [
                "clip_index": index,
                "error": errorMsg
            ])
            throw VideoGenerationError.generationFailed("Pollo API: \(errorMsg)")
            
        case .processing:
            throw VideoGenerationError.generationFailed("Pollo API: Video still processing")
        }
    }
    
    private func createVideoPrompt(from segment: PromptSegment, style: VideoStyle) -> String {
        var prompt = "Create a \(style.rawValue) video: "
        prompt += segment.content
        
        if !segment.characters.isEmpty {
            prompt += " Characters: \(segment.characters.joined(separator: ", "))"
        }
        
        if !segment.setting.isEmpty {
            prompt += " Setting: \(segment.setting)"
        }
        
        if !segment.action.isEmpty {
            prompt += " Action: \(segment.action)"
        }
        
        if let tags = segment.cinematicTags {
            prompt += " Cinematic style: \(tags.visualStyle)"
        }
        
        return prompt
    }
    
    private func assembleVideo(clips: [URL], input: VideoGenerationInput) async throws -> URL {
        Telemetry.shared.logEvent("video_assembly_started", properties: ["clip_count": clips.count])
        
        // Create output URL
        let outputDir = fileManager.temporaryDirectory.appendingPathComponent("DirectorStudio")
        try fileManager.createDirectory(at: outputDir, withIntermediateDirectories: true)
        
        let outputURL = outputDir.appendingPathComponent("\(input.projectName).\(input.outputFormat.fileExtension)")
        
        // Simulate video assembly (in real implementation, this would use AVFoundation or FFmpeg)
        try await assembleVideoClips(clips: clips, outputURL: outputURL, quality: input.quality)
        
        return outputURL
    }
    
    @available(iOS 15.0, *)
    private func assembleVideoClips(clips: [URL], outputURL: URL, quality: VideoQuality) async throws {
        // Simulate assembly delay
        if #available(iOS 15.0, *) {
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        } else {
            // Fallback for iOS < 15.0
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        }
        
        // Create assembled video file (placeholder)
        try createPlaceholderVideoFile(at: outputURL, duration: 4.0, quality: quality)
    }
    
    @available(iOS 15.0, *)
    private func applyPostProcessing(to videoURL: URL, style: VideoStyle) async throws -> URL {
        Telemetry.shared.logEvent("post_processing_started", properties: ["style": style.rawValue])
        
        // Simulate post-processing delay
        if #available(iOS 15.0, *) {
            try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        } else {
            // Fallback for iOS < 15.0
            try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        }
        
        // In real implementation, this would apply actual video effects
        return videoURL
    }
    
    // MARK: - Helper Methods
    
    private func createPlaceholderVideoFile(at url: URL, duration: TimeInterval, quality: VideoQuality) throws {
        // Create a minimal video file placeholder
        let placeholderData = Data("PLACEHOLDER_VIDEO_DATA".utf8)
        try placeholderData.write(to: url)
    }
    
    private func getFileSize(url: URL) throws -> Int64 {
        let attributes = try fileManager.attributesOfItem(atPath: url.path)
        return attributes[.size] as? Int64 ?? 0
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    // MARK: - ModuleProtocol Implementation
    
    public func execute(input: VideoGenerationInput) async throws -> VideoGenerationOutput {
        let result = await executePipelineModule(input: input, context: PipelineContext())
        switch result {
        case .success(let output):
            return output
        case .failure(let error):
            throw error
        }
    }
    
    private func executePipelineModule(input: VideoGenerationInput, context: PipelineContext) async -> Result<VideoGenerationOutput, PipelineError> {
        do {
            let output = try await execute(input: input)
            return .success(output)
        } catch {
            return .failure(.executionFailed(error.localizedDescription))
        }
    }
}
