// MARK: - AI Service Protocol
// Protocol for AI service implementations

import Foundation

/// Protocol for AI service implementations
public protocol AIServiceProtocol: Sendable {
    /// Whether the service is available
    var isAvailable: Bool { get }
    
    /// Reword text
    func rewordText(text: String, style: RewordingStyle) async throws -> String
    
    /// Process text with a given prompt
    func processText(prompt: String, systemPrompt: String) async throws -> String
    
    /// Generate video from prompt
    func generateVideo(prompt: String, style: String, duration: Int) async throws -> VideoGenerationResult
}

/// Mock AI service for testing
public final class MockAIService: AIServiceProtocol {
    public init() {}
    public var isAvailable: Bool {
        return true
    }
    
    public func rewordText(text: String, style: RewordingStyle) async throws -> String {
        try await Task.sleep(nanoseconds: 500_000_000)
        return "This is a reworded version of the text: \(text)"
    }
    
    public func processText(prompt: String, systemPrompt: String) async throws -> String {
        try await Task.sleep(nanoseconds: 500_000_000)
        return "This is a processed version of the prompt: \(prompt)"
    }
    
    public func generateVideo(prompt: String, style: String, duration: Int) async throws -> VideoGenerationResult {
        try await Task.sleep(nanoseconds: 2_000_000_000)
        return VideoGenerationResult(status: .success, videoURL: URL(string: "https://example.com/mock.mp4"))
    }
    
    public func healthCheck() async -> Bool {
        return true
    }
}
