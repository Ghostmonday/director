// MARK: - Core Pipeline Protocols
// Foundation protocols for the DirectorStudio pipeline system

import Foundation

// MARK: - Pipeline Module Protocol

/// Core protocol that all pipeline modules must conform to
/// Provides standardized interface for module execution
public protocol PipelineModule: ModuleProtocol where Input: Sendable, Output: Sendable {
    /// Module version string
    var version: String { get }
    
    /// Execute the module with given input and context
    /// - Parameters:
    ///   - input: Module-specific input data
    ///   - context: Pipeline execution context
    /// - Returns: Result containing output or error
    func execute(
        input: Input,
        context: PipelineContext
    ) async -> Result<Output, PipelineError>
}

// MARK: - Pipeline Context

/// Execution context passed to all pipeline modules
/// Contains shared state and configuration
public struct PipelineContext: Sendable {
    /// Unique execution ID
    public let executionID: String
    
    /// Project identifier
    public let projectID: String
    
    /// Execution start time
    public let startTime: Date
    
    /// Additional metadata
    public let metadata: [String: String]
    
    /// Progress callback for long-running operations
    public let progressCallback: (@Sendable (Double) -> Void)?
    
    public init(
        executionID: String = UUID().uuidString,
        projectID: String = "default",
        startTime: Date = Date(),
        metadata: [String: String] = [:],
        progressCallback: (@Sendable (Double) -> Void)? = nil
    ) {
        self.executionID = executionID
        self.projectID = projectID
        self.startTime = startTime
        self.metadata = metadata
        self.progressCallback = progressCallback
    }
}

// MARK: - Pipeline Error

/// Standardized error types for pipeline operations
public enum PipelineError: Error, Sendable {
    /// Input validation failed
    case invalidInput(String)
    
    /// Module execution failed
    case executionFailed(String)
    
    /// Timeout during execution
    case timeout(Double)
    
    /// Dependency not available
    case dependencyUnavailable(String)
    
    /// Configuration error
    case configurationError(String)
    
    /// Resource unavailable
    case resourceUnavailable(String)
    
    /// Network error
    case networkError(String)
    
    /// Unknown error
    case unknown(String)
    
    /// Human-readable error description
    public var localizedDescription: String {
        switch self {
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        case .executionFailed(let message):
            return "Execution failed: \(message)"
        case .timeout(let duration):
            return "Timeout after \(duration) seconds"
        case .dependencyUnavailable(let dependency):
            return "Dependency unavailable: \(dependency)"
        case .configurationError(let message):
            return "Configuration error: \(message)"
        case .resourceUnavailable(let resource):
            return "Resource unavailable: \(resource)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .unknown(let message):
            return "Unknown error: \(message)"
        }
    }
}

// MARK: - Module Protocol (Legacy Compatibility)

/// Legacy module protocol for backward compatibility
/// Maps to PipelineModule for seamless transition
public protocol ModuleProtocol: Sendable {
    associatedtype Input: Sendable
    associatedtype Output: Sendable
    
    var id: String { get }
    var name: String { get }
    var isEnabled: Bool { get set }
    
    func validate(input: Input) -> Bool
    func execute(input: Input) async throws -> Output
}

// MARK: - Pipeline Orchestrator Protocol

/// Protocol for pipeline orchestration and execution
public protocol PipelineOrchestrator: Sendable {
    /// Execute pipeline with given input
    func executePipeline<T: PipelineModule>(
        module: T,
        input: T.Input
    ) async -> Result<T.Output, PipelineError>
    
    /// Get pipeline execution status
    func getStatus() -> PipelineStatus
    
    /// Cancel pipeline execution
    func cancel() async
}

// MARK: - Pipeline Status

/// Current status of pipeline execution
public enum PipelineStatus: Sendable {
    case idle
    case running
    case paused
    case completed
    case failed(PipelineError)
    case cancelled
}

// MARK: - Progress Tracking

/// Progress tracking for long-running operations
public struct ProgressTracker: Sendable {
    public let total: Int
    public let completed: Int
    public let currentStep: String?
    
    public var percentage: Double {
        guard total > 0 else { return 0.0 }
        return Double(completed) / Double(total)
    }
    
    public init(total: Int, completed: Int = 0, currentStep: String? = nil) {
        self.total = total
        self.completed = completed
        self.currentStep = currentStep
    }
}
