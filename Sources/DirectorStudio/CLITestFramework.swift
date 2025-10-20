//
//  CLITestFramework.swift
//  DirectorStudio
//
//  MODULE: CLITestFramework
//  VERSION: 1.0.0
//  PURPOSE: CLI-compatible testing framework for module validation
//

import Foundation

// MARK: - CLI Test Framework

public struct CLITestFramework {
    
    // MARK: - Test Execution
    
    public static func testModule<T: ModuleProtocol>(
        _ module: T,
        input: T.Input,
        expectedOutput: T.Output? = nil
    ) async throws -> CLITestResult {
        let startTime = Date()
        
        do {
            let output = try await module.execute(input: input)
            let duration = Date().timeIntervalSince(startTime)
            
            let result = CLITestResult(
                moduleId: module.id,
                moduleName: module.name,
                success: true,
                duration: duration,
                input: input,
                output: output,
                error: nil
            )
            
            // Validate expected output if provided
            if let expected = expectedOutput {
                let isValid = validateOutput(output, expected: expected)
                if !isValid {
                    return CLITestResult(
                        moduleId: module.id,
                        moduleName: module.name,
                        success: false,
                        duration: duration,
                        input: input,
                        output: output,
                        error: CLITestError.validationFailed("Output doesn't match expected result")
                    )
                }
            }
            
            return result
            
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            return CLITestResult(
                moduleId: module.id,
                moduleName: module.name,
                success: false,
                duration: duration,
                input: input,
                output: nil,
                error: error
            )
        }
    }
    
    // MARK: - Pipeline Testing
    
    public static func testPipeline(
        core: DirectorStudioCoreProtocol,
        input: String
    ) async throws -> CLIPipelineTestResult {
        let startTime = Date()
        
        do {
            let result = try await core.executePipeline(input: input)
            let duration = Date().timeIntervalSince(startTime)
            
            return CLIPipelineTestResult(
                success: true,
                duration: duration,
                input: input,
                result: result,
                error: nil
            )
            
        } catch {
            let duration = Date().timeIntervalSince(startTime)
            return CLIPipelineTestResult(
                success: false,
                duration: duration,
                input: input,
                result: nil,
                error: error
            )
        }
    }
    
    // MARK: - Validation Helpers
    
    private static func validateOutput<T>(_ output: T, expected: T) -> Bool {
        // Simple validation - can be extended for specific types
        return String(describing: output) == String(describing: expected)
    }
    
    // MARK: - Test Reporting
    
    public static func generateTestReport(_ results: [CLITestResult]) -> String {
        var report = "🧪 CLI Test Report\n"
        report += "==================\n\n"
        
        let totalTests = results.count
        let passedTests = results.filter { $0.success }.count
        let failedTests = totalTests - passedTests
        
        report += "📊 Summary:\n"
        report += "  Total Tests: \(totalTests)\n"
        report += "  Passed: \(passedTests)\n"
        report += "  Failed: \(failedTests)\n"
        report += "  Success Rate: \(String(format: "%.1f", Double(passedTests) / Double(totalTests) * 100))%\n\n"
        
        report += "📋 Detailed Results:\n"
        for result in results {
            let status = result.success ? "✅" : "❌"
            report += "  \(status) \(result.moduleName) (\(result.moduleId))\n"
            report += "    Duration: \(String(format: "%.3f", result.duration))s\n"
            
            if !result.success, let error = result.error {
                report += "    Error: \(error)\n"
            }
            report += "\n"
        }
        
        return report
    }
    
    public static func generatePipelineReport(_ result: CLIPipelineTestResult) -> String {
        var report = "🚀 CLI Pipeline Test Report\n"
        report += "============================\n\n"
        
        let status = result.success ? "✅ SUCCESS" : "❌ FAILED"
        report += "Status: \(status)\n"
        report += "Duration: \(String(format: "%.3f", result.duration))s\n"
        report += "Input: \(result.input)\n\n"
        
        if result.success, let pipelineResult = result.result {
            report += "📊 Pipeline Results:\n"
            for (key, value) in pipelineResult.results {
                report += "  \(key): \(value)\n"
            }
        } else if let error = result.error {
            report += "❌ Error: \(error)\n"
        }
        
        return report
    }
}

// MARK: - Test Result Types

public struct CLITestResult {
    public let moduleId: String
    public let moduleName: String
    public let success: Bool
    public let duration: TimeInterval
    public let input: Any
    public let output: Any?
    public let error: Error?
    
    public init(moduleId: String, moduleName: String, success: Bool, duration: TimeInterval, input: Any, output: Any?, error: Error?) {
        self.moduleId = moduleId
        self.moduleName = moduleName
        self.success = success
        self.duration = duration
        self.input = input
        self.output = output
        self.error = error
    }
}

public struct CLIPipelineTestResult {
    public let success: Bool
    public let duration: TimeInterval
    public let input: String
    public let result: PipelineResult?
    public let error: Error?
}

public enum CLITestError: Error, LocalizedError {
    case validationFailed(String)
    case moduleNotEnabled(String)
    case invalidInput(String)
    
    public var errorDescription: String? {
        switch self {
        case .validationFailed(let message):
            return "Validation failed: \(message)"
        case .moduleNotEnabled(let moduleId):
            return "Module not enabled: \(moduleId)"
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        }
    }
}

// MARK: - Test Commands

public struct CLITestCommands {
    
    public static func buildCommand() -> String {
        return "swift build"
    }
    
    public static func testCommand() -> String {
        return "swift test"
    }
    
    public static func testModuleCommand(_ moduleName: String) -> String {
        return "swift test --filter \(moduleName)Tests"
    }
    
    public static func testSpecificTest(_ testName: String) -> String {
        return "swift test --filter \(testName)"
    }
    
    public static func verboseTestCommand() -> String {
        return "swift test --verbose"
    }
    
    public static func parallelTestCommand() -> String {
        return "swift test --parallel"
    }
}

// MARK: - Test Validation

public struct CLITestValidator {
    
    public static func validateModule<T: ModuleProtocol>(_ module: T) -> [String] {
        var issues: [String] = []
        
        // Check if module is enabled
        if !module.isEnabled {
            issues.append("Module \(module.name) is disabled")
        }
        
        // Check if module has valid ID
        if module.id.isEmpty {
            issues.append("Module \(module.name) has empty ID")
        }
        
        // Check if module has valid name
        if module.name.isEmpty {
            issues.append("Module \(module.id) has empty name")
        }
        
        return issues
    }
    
    public static func validateCore(_ core: DirectorStudioCoreProtocol) -> [String] {
        var issues: [String] = []
        
        // Check if core is processing
        if core.isProcessing {
            issues.append("Core is currently processing - tests may be unreliable")
        }
        
        // Check pipeline state
        if case .failed = core.pipelineState {
            issues.append("Pipeline is in failed state")
        }
        
        return issues
    }
}
