//
//  PolloAPIService.swift
//  DirectorStudio
//
//  Pollo API integration for video generation
//

import Foundation

/// Result of video generation request
public struct VideoGenerationResult: Sendable {
    public let status: Status
    public let videoURL: URL?
    public let errorMessage: String?
    
    public enum Status: String, Sendable {
        case success
        case failed
        case processing
    }
    
    public init(status: Status, videoURL: URL? = nil, errorMessage: String? = nil) {
        self.status = status
        self.videoURL = videoURL
        self.errorMessage = errorMessage
    }
}

/// Pollo API Service for video generation
public final class PolloAPIService: AIServiceProtocol, @unchecked Sendable {
    public static let shared = PolloAPIService()
    
    private let baseURL = "https://api.pollo.ai/v1/generate" // Adjust if different
    private var apiKey: String?
    
    public var isAvailable: Bool {
        return apiKey != nil
    }
    
    private init() {
        // Load API key from SecretsManager, environment, or Info.plist
        if let key = SecretsManager.shared.getSecret(for: "PolloAPIKey") {
            self.apiKey = key
        } else if let key = ProcessInfo.processInfo.environment["PolloAPIKey"] {
            self.apiKey = key
        } else if let key = Bundle.main.infoDictionary?["PolloAPIKey"] as? String {
            self.apiKey = key
        }
    }
    
    // MARK: - Public API
    
    /// Generate video from prompt
    /// - Parameters:
    ///   - prompt: Scene description
    ///   - style: Visual style (e.g., "cinematic noir")
    ///   - duration: Video duration in seconds
    /// - Returns: VideoGenerationResult with local file URL
    public func generateVideo(
        prompt: String,
        style: String = "cinematic",
        duration: Int = 20
    ) async -> VideoGenerationResult {
        
        // Validate API key
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            let error = "Pollo API key not found. Set PolloAPIKey in environment or Info.plist"
            Telemetry.shared.logEvent("VideoGenerationFailure", properties: [
                "error": error,
                "reason": "missing_api_key"
            ])
            return VideoGenerationResult(status: .failed, errorMessage: error)
        }
        
        // Build request
        guard let url = URL(string: baseURL) else {
            return VideoGenerationResult(status: .failed, errorMessage: "Invalid API URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Build payload
        let payload: [String: Any] = [
            "prompt": prompt,
            "style": style,
            "duration": duration
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            Telemetry.shared.logEvent("VideoGenerationFailure", properties: [
                "error": error.localizedDescription,
                "reason": "payload_serialization_failed"
            ])
            return VideoGenerationResult(status: .failed, errorMessage: "Failed to create request payload")
        }
        
        // Log request
        Telemetry.shared.logEvent("VideoGenerationStarted", properties: [
            "prompt_length": prompt.count,
            "style": style,
            "duration": duration
        ])
        
        // Send request
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return VideoGenerationResult(status: .failed, errorMessage: "Invalid response")
            }
            
            // Check status code
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMsg = "API returned status code \(httpResponse.statusCode)"
                Telemetry.shared.logEvent("VideoGenerationFailure", properties: [
                    "status_code": httpResponse.statusCode,
                    "error": errorMsg
                ])
                return VideoGenerationResult(status: .failed, errorMessage: errorMsg)
            }
            
            // Parse response
            let result = try parseResponse(data: data)
            
            // Download video if URL provided
            if let videoURLString = result["video_url"] as? String,
               let videoURL = URL(string: videoURLString) {
                
                // Download and save video
                let localURL = try await downloadVideo(from: videoURL)
                
                Telemetry.shared.logEvent("VideoGenerationSuccess", properties: [
                    "file_size": try? FileManager.default.attributesOfItem(atPath: localURL.path)[.size] as? Int ?? 0,
                    "duration": duration
                ])
                
                return VideoGenerationResult(status: .success, videoURL: localURL)
            }
            
            // If response contains binary video data directly
            if let videoData = result["video_data"] as? Data {
                let localURL = try saveVideoData(videoData)
                
                Telemetry.shared.logEvent("VideoGenerationSuccess", properties: [
                    "file_size": videoData.count,
                    "duration": duration
                ])
                
                return VideoGenerationResult(status: .success, videoURL: localURL)
            }
            
            return VideoGenerationResult(status: .failed, errorMessage: "No video URL or data in response")
            
        } catch {
            Telemetry.shared.logEvent("VideoGenerationFailure", properties: [
                "error": error.localizedDescription,
                "reason": "network_error"
            ])
            return VideoGenerationResult(status: .failed, errorMessage: error.localizedDescription)
        }
    }
    
    // MARK: - Private Helpers
    
    private func parseResponse(data: Data) throws -> [String: Any] {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "PolloAPI", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Invalid JSON response"
            ])
        }
        return json
    }
    
    private func downloadVideo(from url: URL) async throws -> URL {
        let (tempURL, response) = try await URLSession.shared.download(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "PolloAPI", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Failed to download video"
            ])
        }
        
        // Move to permanent location
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let videosDirectory = documentsDirectory.appendingPathComponent("GeneratedVideos", isDirectory: true)
        
        // Create directory if needed
        try FileManager.default.createDirectory(at: videosDirectory, withIntermediateDirectories: true)
        
        let timestamp = Int(Date().timeIntervalSince1970)
        let finalURL = videosDirectory.appendingPathComponent("video_\(timestamp).mov")
        
        // Remove existing file if present
        if FileManager.default.fileExists(atPath: finalURL.path) {
            try FileManager.default.removeItem(at: finalURL)
        }
        
        // Move file
        try FileManager.default.moveItem(at: tempURL, to: finalURL)
        
        return finalURL
    }
    
    private func saveVideoData(_ data: Data) throws -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let videosDirectory = documentsDirectory.appendingPathComponent("GeneratedVideos", isDirectory: true)
        
        // Create directory if needed
        try FileManager.default.createDirectory(at: videosDirectory, withIntermediateDirectories: true)
        
        let timestamp = Int(Date().timeIntervalSince1970)
        let finalURL = videosDirectory.appendingPathComponent("video_\(timestamp).mov")
        
        try data.write(to: finalURL)
        
        return finalURL
    }
    
    // MARK: - Text Rewording
    
    public func rewordText(text: String, style: RewordingStyle) async throws -> String {
        guard let apiKey = SecretsManager.shared.getSecret(for: "RewordingAPIKey") else {
            throw NSError(domain: "RewordingService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Rewording API key not found."])
        }
        
        let url = URL(string: "https://api.pollo.ai/v1/reword")! // Adjust if different
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "text": text,
            "style": style.rawValue
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let result = try JSONDecoder().decode([String: String].self, from: data)
        return result["reworded_text"] ?? ""
    }
    
    public func processText(prompt: String, systemPrompt: String) async throws -> String {
        // This can be a more generic endpoint on your API if it exists,
        // or it can be adapted to use the reword logic.
        // For now, let's make it an alias for a simple reword.
        return try await rewordText(text: prompt, style: .cinematicMood)
    }
}

// MARK: - Integration with VideoGenerationModule

extension PolloAPIService {
    /// Generate video from PromptSegment
    public func generateVideo(from segment: PromptSegment) async -> VideoGenerationResult {
        // Build comprehensive prompt from segment
        let prompt = buildPrompt(from: segment)
        
        // Determine style from cinematic tags
        let style = segment.cinematicTags?.emotionalTone ?? "cinematic"
        
        // Use segment duration
        let duration = segment.duration
        
        return await generateVideo(prompt: prompt, style: style, duration: duration)
    }
    
    private func buildPrompt(from segment: PromptSegment) -> String {
        var components: [String] = []
        
        // Content
        components.append(segment.content)
        
        // Setting
        if !segment.setting.isEmpty {
            components.append("Setting: \(segment.setting)")
        }
        
        // Characters
        if !segment.characters.isEmpty {
            components.append("Characters: \(segment.characters.joined(separator: ", "))")
        }
        
        // Action
        if !segment.action.isEmpty {
            components.append("Action: \(segment.action)")
        }
        
        // Cinematic details
        if let tags = segment.cinematicTags {
            components.append("Camera: \(tags.cameraAngle)")
            components.append("Lighting: \(tags.lighting)")
            components.append("Color: \(tags.colorPalette)")
        }
        
        return components.joined(separator: ". ")
    }
}

