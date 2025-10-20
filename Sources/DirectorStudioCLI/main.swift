//
//  main.swift
//  DirectorStudioCLI
//
//  MODULE: DirectorStudioCLI
//  VERSION: 1.0.0
//  PURPOSE: Command-line interface for DirectorStudio
//

import Foundation
import ArgumentParser
import DirectorStudio

@main
struct DirectorStudioCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "director-studio",
        abstract: "DirectorStudio CLI - AI-powered story processing pipeline",
        version: "1.0.0"
    )
    
    @Option(name: .shortAndLong, help: "Input text to process")
    var input: String?
    
    @Option(name: .shortAndLong, help: "Input file path")
    var inputFile: String?
    
    @Option(name: .shortAndLong, help: "Output file path")
    var output: String?
    
    @Flag(name: .shortAndLong, help: "Enable verbose output")
    var verbose: Bool = false
    
    @Flag(name: .shortAndLong, help: "Run tests")
    var test: Bool = false
    
    @Flag(name: .shortAndLong, help: "Show health status")
    var health: Bool = false
    
    @Option(name: .shortAndLong, help: "Specific module to test")
    var testModule: String?
    
    mutating func run() async throws {
        let core = DirectorStudioCoreCLI()
        
        if test {
            try await runTests(core: core)
        } else if health {
            try await showHealth(core: core)
        } else {
            try await processInput(core: core)
        }
    }
    
    private func processInput(core: DirectorStudioCoreProtocol) async throws {
        let inputText = try getInputText()
        
        if verbose {
            print("🚀 Processing input with DirectorStudio pipeline...")
            print("📝 Input: \(inputText)")
        }
        
        let result = try await core.executePipeline(input: inputText)
        
        if result.success {
            if verbose {
                print("✅ Pipeline completed successfully!")
                print("📊 Results:")
                for (key, value) in result.results {
                    print("  \(key): \(value)")
                }
            }
            
            if let outputPath = output {
                try saveResults(result, to: outputPath)
                print("💾 Results saved to: \(outputPath)")
            } else {
                print("📋 Pipeline Results:")
                printResult(result)
            }
        } else {
            print("❌ Pipeline failed")
            Foundation.exit(1)
        }
    }
    
    private func runTests(core: DirectorStudioCoreProtocol) async throws {
        print("🧪 Running DirectorStudio tests...")
        
        // Register test modules
        let mockAIService = MockAIService()
        let rewordModule = RewordingModule(aiService: mockAIService)
        let segmentModule = SegmentationModule()
        
        core.registerModule(rewordModule)
        core.registerModule(segmentModule)
        
        var testResults: [CLITestResult] = []
        
        // Test RewordingModule
        let rewordInput = RewordingInput(text: "Test input", type: .modernizeOldEnglish)
        let rewordResult = try await CLITestFramework.testModule(rewordModule, input: rewordInput)
        testResults.append(rewordResult)
        
        // Test SegmentationModule
        let segmentInput = SegmentationInput(story: "Test story", maxDuration: 30)
        let segmentResult = try await CLITestFramework.testModule(segmentModule, input: segmentInput)
        testResults.append(segmentResult)
        
        // Test specific module if requested
        if let moduleName = testModule {
            print("🔍 Testing specific module: \(moduleName)")
            // Add specific module testing logic here
        }
        
        // Generate and display test report
        let report = CLITestFramework.generateTestReport(testResults)
        print(report)
        
        // Check if all tests passed
        let allPassed = testResults.allSatisfy { $0.success }
        if !allPassed {
            print("❌ Some tests failed")
            Foundation.exit(1)
        } else {
            print("✅ All tests passed!")
        }
    }
    
    private func showHealth(core: DirectorStudioCoreProtocol) async throws {
        print("🏥 DirectorStudio Health Check")
        print("=============================")
        
        let healthStatus = await core.healthCheck()
        
        for (component, status) in healthStatus {
            let indicator = status ? "✅" : "❌"
            print("\(indicator) \(component): \(status ? "Healthy" : "Unhealthy")")
        }
        
        let allHealthy = healthStatus.values.allSatisfy { $0 }
        if allHealthy {
            print("\n🎉 All systems healthy!")
        } else {
            print("\n⚠️  Some systems unhealthy")
            Foundation.exit(1)
        }
    }
    
    private func getInputText() throws -> String {
        if let input = input {
            return input
        } else if let inputFile = inputFile {
            return try String(contentsOfFile: inputFile)
        } else {
            print("❌ Error: Please provide either --input or --input-file")
            throw CLIError.missingInput
        }
    }
    
    private func saveResults(_ result: PipelineResult, to path: String) throws {
        let jsonData = try JSONSerialization.data(withJSONObject: [
            "success": result.success,
            "results": result.results,
            "executionTime": result.executionTime
        ], options: .prettyPrinted)
        
        try jsonData.write(to: URL(fileURLWithPath: path))
    }
    
    private func printResult(_ result: PipelineResult) {
        print("Success: \(result.success)")
        print("Execution Time: \(String(format: "%.3f", result.executionTime))s")
        print("Results:")
        for (key, value) in result.results {
            print("  \(key): \(value)")
        }
    }
}

enum CLIError: Error {
    case missingInput
    case invalidInputFile
    case invalidOutputFile
}
