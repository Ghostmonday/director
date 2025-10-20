//
//  SupportingTypes.swift
//  DirectorStudio
//
//  MODULE: SupportingTypes
//  VERSION: 1.0.0
//  PURPOSE: Core data types and supporting structures
//

import Foundation

// MARK: - Project Model

public struct Project: Codable, Identifiable {
    public var id = UUID()
    public var name: String
    public var description: String
    public let createdAt: Date
    public var lastModified: Date
    public var updatedAt: Date
    public let status: ProjectStatus
    
    public init(name: String, description: String = "", status: ProjectStatus = .draft) {
        self.name = name
        self.description = description
        self.createdAt = Date()
        self.lastModified = Date()
        self.updatedAt = Date()
        self.status = status
    }
}

public enum ProjectStatus: String, Codable, CaseIterable {
    case draft = "draft"
    case processing = "processing"
    case complete = "complete"
    case failed = "failed"
}

// MARK: - Event Bus

public final class EventBus {
    private var listeners: [String: [Any]] = [:]
    
    public var isHealthy: Bool {
        return true // Simple health check
    }
    
    public func addEventListener<T>(for eventType: T.Type, handler: @escaping (T) -> Void) {
        let key = String(describing: eventType)
        if listeners[key] == nil {
            listeners[key] = []
        }
        listeners[key]?.append(handler)
    }
    
    public func emit<T>(_ event: T) {
        let key = String(describing: T.self)
        guard let handlers = listeners[key] else { return }
        
        for handler in handlers {
            if let typedHandler = handler as? (T) -> Void {
                typedHandler(event)
            }
        }
    }
}

// MARK: - Core Configuration

public final class CoreConfig {
    public var isHealthy: Bool {
        return true // Simple health check
    }
    
    public init() {
        // Initialize configuration
    }
}

// MARK: - Service Registry

public final class ServiceRegistry {
    private var services: [String: Any] = [:]
    
    public var isHealthy: Bool {
        return true // Simple health check
    }
    
    public func register<T>(_ service: T, as protocolType: T.Type) {
        let key = String(describing: protocolType)
        services[key] = service
    }
    
    public func get<T>(_ protocolType: T.Type) -> T? {
        let key = String(describing: protocolType)
        return services[key] as? T
    }
}

// MARK: - Mock AI Service

public final class MockAIServiceImpl: AIServiceProtocol {
    public var isAvailable: Bool {
        return true
    }
    
    public func processText(prompt: String, systemPrompt: String?) async throws -> String {
        return "Mock processed: \(prompt)"
    }
    
    public func healthCheck() async -> Bool {
        return true
    }
    
    public func sendRequest(
        systemPrompt: String,
        userPrompt: String,
        temperature: Double,
        maxTokens: Int
    ) async throws -> String {
        // Mock implementation
        return "Mock AI response for: \(userPrompt)"
    }
}
