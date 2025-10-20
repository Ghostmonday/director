// MARK: - Simple Logging System
// Cross-platform logging without macOS version dependencies

import Foundation

/// Simple logging system that works across all platforms
public struct SimpleLogger: Sendable {
    public let subsystem: String
    public let category: String
    
    public init(subsystem: String, category: String) {
        self.subsystem = subsystem
        self.category = category
    }
    
    public func info(_ message: String) {
        log(level: "INFO", message: message)
    }
    
    public func warning(_ message: String) {
        log(level: "WARNING", message: message)
    }
    
    public func error(_ message: String) {
        log(level: "ERROR", message: message)
    }
    
    public func debug(_ message: String) {
        log(level: "DEBUG", message: message)
    }
    
    private func log(level: String, message: String) {
        let timestamp = DateFormatter.logTimestamp.string(from: Date())
        print("[\(timestamp)] \(level) [\(subsystem).\(category)]: \(message)")
    }
}

extension DateFormatter {
    static let logTimestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
}

/// Global logger instances for different subsystems
public enum Loggers {
    public static let pipeline = SimpleLogger(subsystem: "com.directorstudio.pipeline", category: "pipeline")
    public static let continuity = SimpleLogger(subsystem: "com.directorstudio.pipeline", category: "continuity")
    public static let taxonomy = SimpleLogger(subsystem: "com.directorstudio.pipeline", category: "taxonomy")
    public static let packaging = SimpleLogger(subsystem: "com.directorstudio.pipeline", category: "packaging")
}
