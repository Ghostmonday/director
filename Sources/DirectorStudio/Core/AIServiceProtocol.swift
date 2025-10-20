// MARK: - AI Service Protocol
// Protocol for AI service implementations

import Foundation

/// Protocol for AI service implementations
public protocol AIServiceProtocol: Sendable {
    /// Whether the service is available
    var isAvailable: Bool { get }
    
    /// Process text using AI
    /// - Parameters:
    ///   - prompt: The input prompt
    ///   - systemPrompt: Optional system prompt
    /// - Returns: Processed text result
    func processText(prompt: String, systemPrompt: String?) async throws -> String
    
    /// Health check for the service
    /// - Returns: Whether the service is healthy
    func healthCheck() async -> Bool
}

/// Mock AI service for testing
public final class MockAIService: AIServiceProtocol {
    public init() {}
    public var isAvailable: Bool {
        return true
    }
    
    public func processText(prompt: String, systemPrompt: String?) async throws -> String {
        // Mock processing - just return a modified version
        return "Mock processed: \(prompt)"
    }
    
    public func healthCheck() async -> Bool {
        return true
    }
}
