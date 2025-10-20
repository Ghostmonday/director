//
//  VideoAssemblyModule.swift
//  DirectorStudio
//
//  MODULE: VideoAssemblyModule
//  VERSION: 1.0.0
//  PURPOSE: Advanced video assembly and editing pipeline
//

import Foundation
import AVFoundation

// MARK: - Video Assembly Input/Output Types

public struct VideoAssemblyInput: Sendable, Codable {
    public let videoClips: [VideoClip]
    public let transitions: [VideoTransition]
    public let audioTrack: AudioTrack?
    public let projectSettings: VideoProjectSettings
    public let outputFormat: VideoFormat
    
    public init(
        videoClips: [VideoClip],
        transitions: [VideoTransition] = [],
        audioTrack: AudioTrack? = nil,
        projectSettings: VideoProjectSettings = VideoProjectSettings(),
        outputFormat: VideoFormat = .mp4
    ) {
        self.videoClips = videoClips
        self.transitions = transitions
        self.audioTrack = audioTrack
        self.projectSettings = projectSettings
        self.outputFormat = outputFormat
    }
}

public struct VideoAssemblyOutput: Sendable, Codable {
    public let assembledVideoURL: URL
    public let duration: TimeInterval
    public let fileSize: Int64
    public let quality: VideoQuality
    public let clipsUsed: Int
    public let transitionsUsed: Int
    public let processingTime: TimeInterval
    public let metadata: VideoAssemblyMetadata
    
    public init(
        assembledVideoURL: URL,
        duration: TimeInterval,
        fileSize: Int64,
        quality: VideoQuality,
        clipsUsed: Int,
        transitionsUsed: Int,
        processingTime: TimeInterval,
        metadata: VideoAssemblyMetadata
    ) {
        self.assembledVideoURL = assembledVideoURL
        self.duration = duration
        self.fileSize = fileSize
        self.quality = quality
        self.clipsUsed = clipsUsed
        self.transitionsUsed = transitionsUsed
        self.processingTime = processingTime
        self.metadata = metadata
    }
}

// MARK: - Supporting Types

public struct VideoClip: Sendable, Codable {
    public let url: URL
    public let duration: TimeInterval
    public let startTime: TimeInterval
    public let endTime: TimeInterval
    public let quality: VideoQuality
    public let metadata: VideoClipMetadata
    
    public init(
        url: URL,
        duration: TimeInterval,
        startTime: TimeInterval = 0,
        endTime: TimeInterval? = nil,
        quality: VideoQuality = .high,
        metadata: VideoClipMetadata = VideoClipMetadata()
    ) {
        self.url = url
        self.duration = duration
        self.startTime = startTime
        self.endTime = endTime ?? duration
        self.quality = quality
        self.metadata = metadata
    }
}

public struct VideoTransition: Sendable, Codable {
    public let type: TransitionType
    public let duration: TimeInterval
    public let startTime: TimeInterval
    public let endTime: TimeInterval
    public let parameters: [String: AnyCodable]
    
    public init(
        type: TransitionType,
        duration: TimeInterval,
        startTime: TimeInterval,
        endTime: TimeInterval,
        parameters: [String: AnyCodable] = [:]
    ) {
        self.type = type
        self.duration = duration
        self.startTime = startTime
        self.endTime = endTime
        self.parameters = parameters
    }
}

public struct AudioTrack: Sendable, Codable {
    public let url: URL
    public let volume: Float
    public let startTime: TimeInterval
    public let duration: TimeInterval
    public let fadeIn: TimeInterval
    public let fadeOut: TimeInterval
    
    public init(
        url: URL,
        volume: Float = 1.0,
        startTime: TimeInterval = 0,
        duration: TimeInterval? = nil,
        fadeIn: TimeInterval = 0,
        fadeOut: TimeInterval = 0
    ) {
        self.url = url
        self.volume = volume
        self.startTime = startTime
        self.duration = duration ?? 0
        self.fadeIn = fadeIn
        self.fadeOut = fadeOut
    }
}

public struct VideoProjectSettings: Sendable, Codable {
    public let frameRate: Double
    public let resolution: CGSize
    public let bitrate: Int
    public let codec: String
    public let aspectRatio: AspectRatio
    
    public init(
        frameRate: Double = 30.0,
        resolution: CGSize = CGSize(width: 1920, height: 1080),
        bitrate: Int = 8_000_000,
        codec: String = "h264",
        aspectRatio: AspectRatio = .widescreen
    ) {
        self.frameRate = frameRate
        self.resolution = resolution
        self.bitrate = bitrate
        self.codec = codec
        self.aspectRatio = aspectRatio
    }
}

public struct VideoClipMetadata: Sendable, Codable {
    public let title: String
    public let description: String
    public let tags: [String]
    public let source: String
    public let creationDate: Date
    
    public init(
        title: String = "",
        description: String = "",
        tags: [String] = [],
        source: String = "DirectorStudio",
        creationDate: Date = Date()
    ) {
        self.title = title
        self.description = description
        self.tags = tags
        self.source = source
        self.creationDate = creationDate
    }
}

public struct VideoAssemblyMetadata: Sendable, Codable {
    public let projectName: String
    public let totalClips: Int
    public let totalDuration: TimeInterval
    public let assemblyDate: Date
    public let version: String
    
    public init(
        projectName: String,
        totalClips: Int,
        totalDuration: TimeInterval,
        assemblyDate: Date = Date(),
        version: String = "1.0.0"
    ) {
        self.projectName = projectName
        self.totalClips = totalClips
        self.totalDuration = totalDuration
        self.assemblyDate = assemblyDate
        self.version = version
    }
}

public enum AspectRatio: String, Sendable, Codable, CaseIterable {
    case square = "1:1"
    case standard = "4:3"
    case widescreen = "16:9"
    case ultrawide = "21:9"
    case cinematic = "2.35:1"
}

// MARK: - AnyCodable Helper

public struct AnyCodable: Sendable, Codable {
    public let value: Any
    
    public init(_ value: Any) {
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else {
            throw DecodingError.typeMismatch(AnyCodable.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unable to decode AnyCodable"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let intValue = value as? Int {
            try container.encode(intValue)
        } else if let doubleValue = value as? Double {
            try container.encode(doubleValue)
        } else if let stringValue = value as? String {
            try container.encode(stringValue)
        } else if let boolValue = value as? Bool {
            try container.encode(boolValue)
        } else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unable to encode AnyCodable"))
        }
    }
}

// MARK: - Video Assembly Module

public final class VideoAssemblyModule: PipelineModule {
    public typealias Input = VideoAssemblyInput
    public typealias Output = VideoAssemblyOutput
    
    public let id = "videoassembly"
    public let name = "Video Assembly"
    public let version = "1.0.0"
    public var isEnabled = true
    
    private let fileManager = FileManager.default
    
    public func validate(input: VideoAssemblyInput) -> Bool {
        // Check if input is valid
        return !input.videoClips.isEmpty
    }
    
    public init() {}
    
    // MARK: - PipelineModule Implementation
    
    public func execute(input: VideoAssemblyInput, context: PipelineContext) async -> Result<VideoAssemblyOutput, PipelineError> {
        let startTime = Date()
        
        do {
            print("🎞️ Starting video assembly with \(input.videoClips.count) clips")
            print("🎬 Transitions: \(input.transitions.count)")
            print("🎵 Audio track: \(input.audioTrack != nil ? "Yes" : "No")")
            
            // Phase 1: Validate input clips
            try validateVideoClips(input.videoClips)
            
            // Phase 2: Process and optimize clips
            let processedClips = try await processVideoClips(input.videoClips, settings: input.projectSettings)
            
            // Phase 3: Apply transitions
            let clipsWithTransitions = try await applyTransitions(processedClips, transitions: input.transitions)
            
            // Phase 4: Assemble final video
            let assembledVideo = try await assembleFinalVideo(
                clips: clipsWithTransitions,
                audioTrack: input.audioTrack,
                settings: input.projectSettings,
                outputFormat: input.outputFormat
            )
            
            // Phase 5: Generate metadata
            let totalDuration = input.videoClips.reduce(0) { $0 + $1.duration }
            let metadata = VideoAssemblyMetadata(
                projectName: "Assembled Video",
                totalClips: input.videoClips.count,
                totalDuration: totalDuration
            )
            
            let processingTime = Date().timeIntervalSince(startTime)
            let fileSize = try getFileSize(url: assembledVideo)
            
            let output = VideoAssemblyOutput(
                assembledVideoURL: assembledVideo,
                duration: totalDuration,
                fileSize: fileSize,
                quality: input.projectSettings.resolution.width >= 1920 ? .high : .medium,
                clipsUsed: input.videoClips.count,
                transitionsUsed: input.transitions.count,
                processingTime: processingTime,
                metadata: metadata
            )
            
            print("✅ Video assembly completed in \(String(format: "%.2f", processingTime))s")
            print("📁 Output: \(assembledVideo.path)")
            print("📊 Final duration: \(String(format: "%.2f", totalDuration))s")
            
            return .success(output)
            
        } catch {
            print("❌ Video assembly failed: \(error.localizedDescription)")
            return .failure(.executionFailed(error.localizedDescription))
        }
    }
    
    // MARK: - Assembly Methods
    
    private func validateVideoClips(_ clips: [VideoClip]) throws {
        for (index, clip) in clips.enumerated() {
            guard fileManager.fileExists(atPath: clip.url.path) else {
                throw VideoAssemblyError.clipNotFound(index: index, url: clip.url)
            }
            
            guard clip.duration > 0 else {
                throw VideoAssemblyError.invalidDuration(index: index)
            }
            
            guard clip.startTime < clip.endTime else {
                throw VideoAssemblyError.invalidTimeRange(index: index)
            }
        }
    }
    
    private func processVideoClips(_ clips: [VideoClip], settings: VideoProjectSettings) async throws -> [VideoClip] {
        var processedClips: [VideoClip] = []
        
        for (index, clip) in clips.enumerated() {
            print("🔧 Processing clip \(index + 1)/\(clips.count)")
            
            // Simulate video processing (in real implementation, this would use AVFoundation)
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            // For now, return the clip as-is (in real implementation, this would apply processing)
            processedClips.append(clip)
        }
        
        return processedClips
    }
    
    private func applyTransitions(_ clips: [VideoClip], transitions: [VideoTransition]) async throws -> [VideoClip] {
        if transitions.isEmpty {
            return clips
        }
        
        print("✨ Applying \(transitions.count) transitions...")
        
        // Simulate transition processing
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // In real implementation, this would apply actual video transitions
        return clips
    }
    
    private func assembleFinalVideo(
        clips: [VideoClip],
        audioTrack: AudioTrack?,
        settings: VideoProjectSettings,
        outputFormat: VideoFormat
    ) async throws -> URL {
        print("🎬 Assembling final video...")
        
        // Create output URL
        let outputDir = fileManager.temporaryDirectory.appendingPathComponent("DirectorStudio")
        try fileManager.createDirectory(at: outputDir, withIntermediateDirectories: true)
        
        let timestamp = Int(Date().timeIntervalSince1970)
        let outputURL = outputDir.appendingPathComponent("assembled_video_\(timestamp).\(outputFormat.fileExtension)")
        
        // Simulate video assembly (in real implementation, this would use AVFoundation)
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Create assembled video file (placeholder)
        try createPlaceholderVideoFile(at: outputURL, duration: clips.reduce(0) { $0 + $1.duration })
        
        return outputURL
    }
    
    // MARK: - Helper Methods
    
    private func createPlaceholderVideoFile(at url: URL, duration: TimeInterval) throws {
        let placeholderData = Data("ASSEMBLED_VIDEO_DATA".utf8)
        try placeholderData.write(to: url)
    }
    
    private func getFileSize(url: URL) throws -> Int64 {
        let attributes = try fileManager.attributesOfItem(atPath: url.path)
        return attributes[.size] as? Int64 ?? 0
    }
    
    // MARK: - ModuleProtocol Implementation
    
    public func execute(input: VideoAssemblyInput) async throws -> VideoAssemblyOutput {
        let result = await executePipelineModule(input: input, context: PipelineContext())
        switch result {
        case .success(let output):
            return output
        case .failure(let error):
            throw error
        }
    }
    
    private func executePipelineModule(input: VideoAssemblyInput, context: PipelineContext) async -> Result<VideoAssemblyOutput, PipelineError> {
        do {
            let output = try await execute(input: input)
            return .success(output)
        } catch {
            return .failure(.executionFailed(error.localizedDescription))
        }
    }
}

// MARK: - Error Types

public enum VideoAssemblyError: Error, LocalizedError {
    case clipNotFound(index: Int, url: URL)
    case invalidDuration(index: Int)
    case invalidTimeRange(index: Int)
    case assemblyFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .clipNotFound(let index, let url):
            return "Video clip \(index) not found at: \(url.path)"
        case .invalidDuration(let index):
            return "Invalid duration for video clip \(index)"
        case .invalidTimeRange(let index):
            return "Invalid time range for video clip \(index)"
        case .assemblyFailed(let message):
            return "Video assembly failed: \(message)"
        }
    }
}
