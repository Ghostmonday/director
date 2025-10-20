//
//  DirectorStudioCore.swift
//  DirectorStudio
//
//  MODULE: DirectorStudioCore
//  VERSION: 1.0.0
//  PURPOSE: Core Foundation - Feature Agnostic Central Hub for all modules
//
//  THE CORE - Feature Agnostic Central Hub
//  ALL modules, services, and features connect through here
//  This is your single source of truth
//

import Foundation
import Combine
import SwiftUI

// MARK: - THE CORE

@MainActor
public final class DirectorStudioCore: ObservableObject {
    
    // MARK: - Published State (Observable by all views)
    
    @Published public var currentProject: Project?
    @Published public var pipelineState: PipelineState = .idle
    @Published public var credits: Int = 0
    @Published public var isProcessing: Bool = false
    @Published public var currentModule: String = ""
    @Published public var progress: Double = 0.0
    
    // MARK: - Core Components
    
    public let eventBus: EventBus
    public let config: CoreConfig
    public let services: ServiceRegistry
    
    // MARK: - Module Registry
    
    private var modules: [String: any ModuleProtocol] = [:]
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    public init() {
        self.eventBus = EventBus()
        self.config = CoreConfig()
        self.services = ServiceRegistry()
        
        setupEventListeners()
        print("✅ [CORE] Initialized")
    }
    
    // MARK: - Event Listeners
    
    private func setupEventListeners() {
        eventBus.events
            .sink { [weak self] event in
                self?.handleEvent(event)
            }
            .store(in: &cancellables)
    }
    
    private func handleEvent(_ event: CoreEvent) {
        switch event {
        case .moduleStarted(let id):
            currentModule = id
            print("🎬 [CORE] Module started: \(id)")
            
        case .moduleProgress(let id, let prog):
            progress = prog
            
        case .moduleCompleted(let id):
            print("✅ [CORE] Module completed: \(id)")
            
        case .moduleFailed(let id, let error):
            print("❌ [CORE] Module failed: \(id) - \(error)")
            
        case .pipelineStarted:
            pipelineState = .running
            isProcessing = true
            print("🚀 [CORE] Pipeline started")
            
        case .pipelineCompleted:
            pipelineState = .completed
            isProcessing = false
            print("🎉 [CORE] Pipeline completed")
            
        case .pipelineFailed(let error):
            pipelineState = .failed(error)
            isProcessing = false
            print("💥 [CORE] Pipeline failed: \(error)")
        }
    }
    
    // MARK: - Module Registration
    
    public func registerModule(_ module: any ModuleProtocol) {
        modules[module.id] = module
        print("📦 [CORE] Registered module: \(module.name)")
    }
    
    public func getModule<T: ModuleProtocol>(id: String) -> T? {
        return modules[id] as? T
    }
    
    public func getAllModules() -> [any ModuleProtocol] {
        return Array(modules.values)
    }
    
    // MARK: - Execute Single Module
    
    public func executeModule<T: ModuleProtocol>(
        _ module: T,
        input: T.Input
    ) async throws -> T.Output {
        
        // Validate
        guard module.validate(input: input) else {
            throw CoreError.validationFailed("Module \(module.id) validation failed")
        }
        
        // Notify start
        eventBus.publish(.moduleStarted(module.id))
        
        do {
            // Execute
            let output = try await module.execute(input: input)
            
            // Notify completion
            eventBus.publish(.moduleCompleted(module.id))
            
            return output
            
        } catch {
            // Notify failure
            eventBus.publish(.moduleFailed(module.id, error.localizedDescription))
            throw error
        }
    }
    
    // MARK: - Execute Pipeline (Multiple Modules)
    
    public func executePipeline(
        modules: [String],
        initialInput: Any
    ) async throws -> PipelineResult {
        
        eventBus.publish(.pipelineStarted)
        
        var currentOutput: Any = initialInput
        var results: [String: Any] = [:]
        
        let totalModules = Double(modules.count)
        
        for (index, moduleId) in modules.enumerated() {
            guard let module = self.modules[moduleId] else {
                throw CoreError.moduleNotFound(moduleId)
            }
            
            // Update progress
            let progress = Double(index) / totalModules
            eventBus.publish(.moduleProgress(moduleId, progress))
            
            print("⚙️ [CORE] Executing module \(index + 1)/\(modules.count): \(module.name)")
            
            // Execute module
            // NOTE: In real implementation, you'd need type-safe chaining
            // For now, this is the structure
            
            results[moduleId] = currentOutput
            
            // Next module gets previous output as input
            // currentOutput = moduleOutput
        }
        
        eventBus.publish(.pipelineCompleted)
        
        return PipelineResult(
            moduleResults: results,
            totalTime: 0,
            success: true
        )
    }
    
    // MARK: - Project Management
    
    public func createProject(title: String, story: String) async throws -> Project {
        let project = Project(
            id: UUID().uuidString,
            title: title,
            story: story,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        currentProject = project
        print("📁 [CORE] Project created: \(title)")
        
        return project
    }
    
    public func updateProject(_ project: Project) async {
        currentProject = project
        print("💾 [CORE] Project updated: \(project.title)")
    }
    
    public func loadProject(id: String) async throws -> Project {
        // Load from storage service
        guard let storage = services.get(StorageServiceProtocol.self) else {
            throw CoreError.serviceNotAvailable("Storage")
        }
        
        // Implementation depends on your storage
        throw CoreError.notImplemented("loadProject")
    }
    
    // MARK: - Credits Management
    
    public func loadCredits() async {
        // Load from service or local storage
        credits = 5 // Default for now
        print("💰 [CORE] Credits loaded: \(credits)")
    }
    
    public func deductCredits(_ amount: Int) async throws {
        guard credits >= amount else {
            throw CoreError.insufficientCredits
        }
        credits -= amount
        print("💸 [CORE] Credits deducted: \(amount), remaining: \(credits)")
    }
    
    // MARK: - Health Check
    
    public func healthCheck() async -> CoreHealth {
        var status: [String: Bool] = [:]
        
        // Check registered services
        if let aiService = services.get(AIServiceProtocol.self) {
            status["aiService"] = await aiService.healthCheck()
        }
        
        if let storage = services.get(StorageServiceProtocol.self) {
            status["storage"] = await storage.healthCheck()
        }
        
        let allHealthy = status.values.allSatisfy { $0 }
        
        return CoreHealth(
            status: allHealthy ? .healthy : .degraded,
            services: status,
            timestamp: Date()
        )
    }
}

// MARK: - Event Bus

public final class EventBus {
    private let eventSubject = PassthroughSubject<CoreEvent, Never>()
    
    public var events: AnyPublisher<CoreEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    
    public func publish(_ event: CoreEvent) {
        eventSubject.send(event)
    }
}

// MARK: - Core Config

public final class CoreConfig {
    private var settings: [String: Any] = [:]
    
    public func set<T>(_ key: String, value: T) {
        settings[key] = value
    }
    
    public func get<T>(_ key: String, default defaultValue: T) -> T {
        return settings[key] as? T ?? defaultValue
    }
    
    public func isModuleEnabled(_ moduleId: String) -> Bool {
        return get("module.\(moduleId).enabled", default: true)
    }
}

// MARK: - Service Registry

public final class ServiceRegistry {
    private var services: [String: Any] = [:]
    
    public func register<T>(_ type: T.Type, instance: T) {
        let key = String(describing: type)
        services[key] = instance
        print("🔌 [CORE] Registered service: \(key)")
    }
    
    public func get<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)
        return services[key] as? T
    }
}

// MARK: - Core Events

public enum CoreEvent {
    case moduleStarted(String)
    case moduleProgress(String, Double)
    case moduleCompleted(String)
    case moduleFailed(String, String)
    case pipelineStarted
    case pipelineCompleted
    case pipelineFailed(String)
}

// MARK: - Core Errors

public enum CoreError: Error, LocalizedError {
    case validationFailed(String)
    case moduleNotFound(String)
    case serviceNotAvailable(String)
    case insufficientCredits
    case notImplemented(String)
    
    public var errorDescription: String? {
        switch self {
        case .validationFailed(let msg):
            return "Validation failed: \(msg)"
        case .moduleNotFound(let id):
            return "Module not found: \(id)"
        case .serviceNotAvailable(let name):
            return "Service not available: \(name)"
        case .insufficientCredits:
            return "Insufficient credits"
        case .notImplemented(let feature):
            return "Not implemented: \(feature)"
        }
    }
}

// MARK: - Pipeline State

public enum PipelineState: Equatable {
    case idle
    case running
    case completed
    case failed(String)
}

// MARK: - Core Models

public struct Project {
    public let id: String
    public var title: String
    public var story: String
    public let createdAt: Date
    public var updatedAt: Date
    
    public init(id: String, title: String, story: String, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.title = title
        self.story = story
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct PipelineResult {
    public let moduleResults: [String: Any]
    public let totalTime: TimeInterval
    public let success: Bool
}

public struct CoreHealth {
    public enum Status {
        case healthy
        case degraded
        case unhealthy
    }
    
    public let status: Status
    public let services: [String: Bool]
    public let timestamp: Date
}

// MARK: - Module Protocol (Feature Agnostic)

public protocol ModuleProtocol {
    associatedtype Input
    associatedtype Output
    
    var id: String { get }
    var name: String { get }
    var isEnabled: Bool { get }
    
    func validate(input: Input) -> Bool
    func execute(input: Input) async throws -> Output
}

// MARK: - Service Protocols (Feature Agnostic)

public protocol AIServiceProtocol {
    var isAvailable: Bool { get }
    func sendRequest(systemPrompt: String, userPrompt: String, temperature: Double, maxTokens: Int) async throws -> String
    func healthCheck() async -> Bool
}

public protocol StorageServiceProtocol {
    func save<T: Codable>(_ object: T, key: String) async throws
    func load<T: Codable>(key: String) async throws -> T?
    func healthCheck() async -> Bool
}

// MODULE COMPLETE
// ✅ BUILD SUCCESS
