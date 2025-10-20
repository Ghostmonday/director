//
//  LegacyAdapterKit.swift
//  LegacyAdapterKit
//
//  MODULE: LegacyAdapterKit
//  VERSION: 1.0.0
//  PURPOSE: Encapsulate UIKit/Storyboard-era logic for Xcode deferral compliance
//

import Foundation

// MARK: - Legacy Adapter Protocol

public protocol LegacyAdapterProtocol {
    func adaptLegacyModule<T>(_ legacyModule: T) -> any ModuleProtocol
    func removeGUIDependencies<T>(_ module: T) -> T
    func extractBusinessLogic<T>(_ legacyModule: T) -> Any
}

// MARK: - Legacy Adapter Implementation

public final class LegacyAdapterKit: LegacyAdapterProtocol {
    
    public init() {}
    
    // MARK: - Module Adaptation
    
    public func adaptLegacyModule<T>(_ legacyModule: T) -> any ModuleProtocol {
        // Extract business logic from legacy module
        let businessLogic = extractBusinessLogic(legacyModule)
        
        // Create CLI-compatible module wrapper
        return LegacyModuleWrapper(
            id: "legacy_\(String(describing: T.self))",
            name: "Legacy \(String(describing: T.self))",
            businessLogic: businessLogic
        )
    }
    
    public func removeGUIDependencies<T>(_ module: T) -> T {
        // This would remove @MainActor, @Published, ObservableObject, etc.
        // For now, return the module as-is since we've already refactored
        return module
    }
    
    public func extractBusinessLogic<T>(_ legacyModule: T) -> Any {
        // Extract core business logic from legacy module
        // This is a placeholder implementation
        return legacyModule
    }
}

// MARK: - Legacy Module Wrapper

public final class LegacyModuleWrapper: ModuleProtocol {
    public typealias Input = Any
    public typealias Output = Any
    
    public let id: String
    public let name: String
    public var isEnabled: Bool = true
    
    private let businessLogic: Any
    
    public init(id: String, name: String, businessLogic: Any) {
        self.id = id
        self.name = name
        self.businessLogic = businessLogic
    }
    
    public func validate(input: Any) -> Bool {
        // Basic validation for legacy modules
        return true
    }
    
    public func execute(input: Any) async throws -> Any {
        // Execute legacy business logic
        // This is a placeholder implementation
        return input
    }
}

// MARK: - Legacy Code Extractor

public final class LegacyCodeExtractor {
    
    public static func extractSwiftUIImports(from content: String) -> [String] {
        let lines = content.components(separatedBy: .newlines)
        return lines.compactMap { line in
            if line.contains("import SwiftUI") {
                return line.trimmingCharacters(in: .whitespaces)
            }
            return nil
        }
    }
    
    public static func extractUIKitImports(from content: String) -> [String] {
        let lines = content.components(separatedBy: .newlines)
        return lines.compactMap { line in
            if line.contains("import UIKit") {
                return line.trimmingCharacters(in: .whitespaces)
            }
            return nil
        }
    }
    
    public static func extractPublishedProperties(from content: String) -> [String] {
        let lines = content.components(separatedBy: .newlines)
        return lines.compactMap { line in
            if line.contains("@Published") {
                return line.trimmingCharacters(in: .whitespaces)
            }
            return nil
        }
    }
    
    public static func extractMainActorAnnotations(from content: String) -> [String] {
        let lines = content.components(separatedBy: .newlines)
        return lines.compactMap { line in
            if line.contains("@MainActor") {
                return line.trimmingCharacters(in: .whitespaces)
            }
            return nil
        }
    }
    
    public static func extractObservableObjectConformance(from content: String) -> [String] {
        let lines = content.components(separatedBy: .newlines)
        return lines.compactMap { line in
            if line.contains("ObservableObject") {
                return line.trimmingCharacters(in: .whitespaces)
            }
            return nil
        }
    }
}

// MARK: - Legacy Code Analyzer

public final class LegacyCodeAnalyzer {
    
    public static func analyzeFile(_ content: String) -> LegacyAnalysisResult {
        let swiftUIImports = LegacyCodeExtractor.extractSwiftUIImports(from: content)
        let uikitImports = LegacyCodeExtractor.extractUIKitImports(from: content)
        let publishedProperties = LegacyCodeExtractor.extractPublishedProperties(from: content)
        let mainActorAnnotations = LegacyCodeExtractor.extractMainActorAnnotations(from: content)
        let observableObjectConformance = LegacyCodeExtractor.extractObservableObjectConformance(from: content)
        
        return LegacyAnalysisResult(
            swiftUIImports: swiftUIImports,
            uikitImports: uikitImports,
            publishedProperties: publishedProperties,
            mainActorAnnotations: mainActorAnnotations,
            observableObjectConformance: observableObjectConformance,
            hasGUIDependencies: !swiftUIImports.isEmpty || !uikitImports.isEmpty || !publishedProperties.isEmpty || !mainActorAnnotations.isEmpty || !observableObjectConformance.isEmpty
        )
    }
    
    public static func generateComplianceReport(_ results: [LegacyAnalysisResult]) -> String {
        var report = "🔍 Legacy Code Analysis Report\n"
        report += "==============================\n\n"
        
        let totalFiles = results.count
        let compliantFiles = results.filter { !$0.hasGUIDependencies }.count
        let nonCompliantFiles = totalFiles - compliantFiles
        
        report += "📊 Summary:\n"
        report += "  Total Files: \(totalFiles)\n"
        report += "  Compliant: \(compliantFiles)\n"
        report += "  Non-Compliant: \(nonCompliantFiles)\n"
        report += "  Compliance Rate: \(String(format: "%.1f", Double(compliantFiles) / Double(totalFiles) * 100))%\n\n"
        
        if nonCompliantFiles > 0 {
            report += "⚠️  Non-Compliant Files:\n"
            for result in results where result.hasGUIDependencies {
                report += "  - \(result.fileName ?? "Unknown")\n"
                if !result.swiftUIImports.isEmpty {
                    report += "    SwiftUI imports: \(result.swiftUIImports.count)\n"
                }
                if !result.uikitImports.isEmpty {
                    report += "    UIKit imports: \(result.uikitImports.count)\n"
                }
                if !result.publishedProperties.isEmpty {
                    report += "    @Published properties: \(result.publishedProperties.count)\n"
                }
                if !result.mainActorAnnotations.isEmpty {
                    report += "    @MainActor annotations: \(result.mainActorAnnotations.count)\n"
                }
                if !result.observableObjectConformance.isEmpty {
                    report += "    ObservableObject conformance: \(result.observableObjectConformance.count)\n"
                }
            }
        }
        
        return report
    }
}

// MARK: - Legacy Analysis Result

public struct LegacyAnalysisResult {
    public let swiftUIImports: [String]
    public let uikitImports: [String]
    public let publishedProperties: [String]
    public let mainActorAnnotations: [String]
    public let observableObjectConformance: [String]
    public let hasGUIDependencies: Bool
    public let fileName: String?
    
    public init(
        swiftUIImports: [String],
        uikitImports: [String],
        publishedProperties: [String],
        mainActorAnnotations: [String],
        observableObjectConformance: [String],
        hasGUIDependencies: Bool,
        fileName: String? = nil
    ) {
        self.swiftUIImports = swiftUIImports
        self.uikitImports = uikitImports
        self.publishedProperties = publishedProperties
        self.mainActorAnnotations = mainActorAnnotations
        self.observableObjectConformance = observableObjectConformance
        self.hasGUIDependencies = hasGUIDependencies
        self.fileName = fileName
    }
}
