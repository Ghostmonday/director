//
//  Telemetry.swift
//  DirectorStudio
//
//  MODULE: Telemetry
//  VERSION: 1.0.0
//  PURPOSE: Centralized telemetry and analytics system
//

import Foundation
import os.log

/// Central telemetry system for tracking events, performance, and user behavior
public class Telemetry {
    public static let shared = Telemetry()
    
    private init() {}
    
    /// Logs an event with optional properties
    /// - Parameters:
    ///   - event: Event name/identifier
    ///   - properties: Optional event properties
    ///   - level: Log level (default: .info)
    public func logEvent(_ event: String, properties: [String: Any]? = nil, level: LogLevel = .info) {
        let timestamp = Date()
        let eventData = TelemetryEvent(
            event: event,
            properties: properties ?? [:],
            timestamp: timestamp,
            level: level
        )
        
        // Log to system for iOS app
        os_log("📊 [TELEMETRY] %{public}@", log: .default, type: .info, event)
        if let properties = properties, !properties.isEmpty {
            os_log("   Properties: %{public}@", log: .default, type: .info, String(describing: properties))
        }
        
        // In production, send to analytics backend
        #if !DEBUG
        sendToAnalytics(eventData)
        #endif
    }
    
    /// Logs a module execution event
    /// - Parameters:
    ///   - moduleId: Module identifier
    ///   - moduleName: Human-readable module name
    ///   - success: Whether execution succeeded
    ///   - duration: Execution duration in seconds
    ///   - inputSize: Size of input data (optional)
    public func logModuleExecution(
        moduleId: String,
        moduleName: String,
        success: Bool,
        duration: TimeInterval,
        inputSize: Int? = nil
    ) {
        var properties: [String: Any] = [
            "module_id": moduleId,
            "module_name": moduleName,
            "success": success,
            "duration": duration,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        if let inputSize = inputSize {
            properties["input_size"] = inputSize
        }
        
        logEvent("module_execution", properties: properties)
    }
    
    /// Logs a pipeline execution event
    /// - Parameters:
    ///   - modules: Array of module IDs in execution order
    ///   - success: Whether pipeline succeeded
    ///   - totalDuration: Total pipeline duration
    ///   - inputSize: Size of input data
    public func logPipelineExecution(
        modules: [String],
        success: Bool,
        totalDuration: TimeInterval,
        inputSize: Int
    ) {
        let properties: [String: Any] = [
            "modules": modules,
            "module_count": modules.count,
            "success": success,
            "total_duration": totalDuration,
            "input_size": inputSize,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        logEvent("pipeline_execution", properties: properties)
    }
    
    /// Logs a user action event
    /// - Parameters:
    ///   - action: Action identifier
    ///   - context: Optional context information
    ///   - success: Whether action succeeded
    public func logUserAction(_ action: String, context: String? = nil, success: Bool = true) {
        var properties: [String: Any] = [
            "action": action,
            "success": success,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        if let context = context {
            properties["context"] = context
        }
        
        logEvent("user_action", properties: properties)
    }
    
    /// Logs an error event
    /// - Parameters:
    ///   - error: Error that occurred
    ///   - context: Context where error occurred
    ///   - moduleId: Optional module ID where error occurred
    public func logError(_ error: Error, context: String, moduleId: String? = nil) {
        var properties: [String: Any] = [
            "error_description": error.localizedDescription,
            "error_type": String(describing: type(of: error)),
            "context": context,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        if let moduleId = moduleId {
            properties["module_id"] = moduleId
        }
        
        logEvent("error", properties: properties, level: .error)
    }
    
    /// Logs a performance metric
    /// - Parameters:
    ///   - metric: Metric name
    ///   - value: Metric value
    ///   - unit: Unit of measurement
    ///   - context: Optional context
    public func logPerformance(_ metric: String, value: Double, unit: String, context: String? = nil) {
        var properties: [String: Any] = [
            "metric": metric,
            "value": value,
            "unit": unit,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        if let context = context {
            properties["context"] = context
        }
        
        logEvent("performance_metric", properties: properties)
    }
    
    // MARK: - Private Methods
    
    private func sendToAnalytics(_ event: TelemetryEvent) {
        // In production, implement actual analytics backend integration
        // This could be Firebase Analytics, Mixpanel, or custom backend
    }
}

// MARK: - Supporting Types

public struct TelemetryEvent {
    public let event: String
    public let properties: [String: Any]
    public let timestamp: Date
    public let level: LogLevel
}

public enum LogLevel: String, CaseIterable {
    case debug = "debug"
    case info = "info"
    case warning = "warning"
    case error = "error"
    case critical = "critical"
}

// MARK: - Convenience Extensions

extension Telemetry {
    /// Logs view lifecycle events
    public func logViewAppeared(_ viewName: String) {
        logUserAction("view_appeared", context: viewName)
    }
    
    /// Logs view lifecycle events
    public func logViewDisappeared(_ viewName: String) {
        logUserAction("view_disappeared", context: viewName)
    }
    
    /// Logs button tap events
    public func logButtonTap(_ buttonName: String, context: String? = nil) {
        logUserAction("button_tap", context: "\(buttonName)\(context.map { " - \($0)" } ?? "")")
    }
    
    /// Logs text input events
    public func logTextInput(_ fieldName: String, length: Int) {
        logUserAction("text_input", context: "\(fieldName) - \(length) chars")
    }
}
