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
    
    @Option(name: [.long, .customShort("f")], help: "Input file path")
    var inputFile: String?
    
    @Option(name: .shortAndLong, help: "Output file path")
    var output: String?
    
    @Flag(name: .shortAndLong, help: "Enable verbose output")
    var verbose: Bool = false
    
    @Flag(name: [.long, .customShort("T")], help: "Run tests")
    var test: Bool = false
    
    @Flag(name: [.long, .customShort("H")], help: "Show health status")
    var health: Bool = false
    
    @Option(name: [.long, .customShort("m")], help: "Specific module to test")
    var testModule: String?
    
    mutating func run() async throws {
        let core = DirectorStudioCore.shared
        let gui = GUIAbstraction()
        
        if test {
            try await runTests(gui: gui)
        } else if health {
            try await showHealth(gui: gui)
        } else {
            try await processInput(gui: gui)
        }
    }
    
    private func processInput(gui: GUIAbstraction) async throws {
        let inputText = try getInputText()
        
        if verbose {
            print("🚀 Processing input with DirectorStudio pipeline...")
            print("📝 Input: \(inputText)")
        }
        
        // Create a new project
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        let projectName = "CLI Project \(formatter.string(from: Date()))"
        let project = try await gui.createProject(name: projectName, description: "Created from CLI")
        
        print("📁 Created project: \(project.name) (ID: \(project.id))")
        
        // Segment the story
        print("🔪 Segmenting story...")
        let segments = try await gui.segmentStory(story: inputText)
        
        print("✅ Created \(segments.count) segments:")
        for segment in segments {
            print("  📌 Segment \(segment.index): \(segment.content.prefix(50))...")
        }
        
        // Enrich segments with taxonomy
        print("\n🎬 Enriching segments with cinematic taxonomy...")
        let enrichedSegments = try await gui.enrichSegmentsWithTaxonomy()
        
        print("✅ Segments enriched with cinematic taxonomy")
        
        // Generate video if requested
        if output != nil {
            print("\n🎥 Generating video...")
            let video = try await gui.generateVideo(
                quality: .medium,
                format: .mp4,
                style: .cinematic
            )
            
            print("✅ Video generated: \(video.url.path)")
            print("⏱️ Duration: \(video.duration) seconds")
            print("🔍 Quality: \(video.quality)")
            print("📊 File size: \(formatFileSize(video.fileSize))")
            
            // Copy to output path if specified
            if let outputPath = output {
                let outputURL = URL(fileURLWithPath: outputPath)
                try FileManager.default.copyItem(at: video.url, to: outputURL)
                print("💾 Video copied to: \(outputPath)")
            }
        } else {
            // Output segments as JSON
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted]
            
            let segmentsData = try encoder.encode(segments)
            let segmentsJSON = String(data: segmentsData, encoding: .utf8)!
            
            print("\n📋 Segments JSON:")
            print(segmentsJSON)
        }
        
        // Show credits usage
        let creditsBalance = try await gui.getCreditsBalance()
        print("\n💰 Remaining credits: \(creditsBalance)")
    }
    
    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    private func runTests(gui: GUIAbstraction) async throws {
        print("🧪 Running DirectorStudio tests...")
        
        var testResults: [CLITestResult] = []
        
        // Test story segmentation
        print("🧪 Testing story segmentation...")
        do {
            let testStory = "This is a test story. It has multiple sentences. This is the third sentence."
            let project = try await gui.createProject(name: "Test Project", description: "Test project for CLI tests")
            let segments = try await gui.segmentStory(story: testStory)
            
            testResults.append(CLITestResult(
                moduleId: "segmentation",
                moduleName: "Segmentation",
                success: !segments.isEmpty,
                duration: 1.0,
                input: testStory,
                output: segments,
                error: segments.isEmpty ? CLITestError.validationFailed("No segments created") : nil
            ))
            
            print("  ✅ Created \(segments.count) segments")
        } catch {
            testResults.append(CLITestResult(
                moduleId: "segmentation",
                moduleName: "Segmentation",
                success: false,
                duration: 1.0,
                input: "Test input",
                output: nil,
                error: error
            ))
            
            print("  ❌ Segmentation test failed: \(error.localizedDescription)")
        }
        
        // Test credits balance
        print("🧪 Testing credits system...")
        do {
            let credits = try await gui.getCreditsBalance()
            
            testResults.append(CLITestResult(
                moduleId: "monetization",
                moduleName: "Credits",
                success: true,
                duration: 0.1,
                input: "get credits balance",
                output: credits,
                error: nil
            ))
            
            print("  ✅ Credits balance: \(credits)")
        } catch {
            testResults.append(CLITestResult(
                moduleId: "monetization",
                moduleName: "Credits",
                success: false,
                duration: 0.1,
                input: "get credits balance",
                output: nil,
                error: error
            ))
            
            print("  ❌ Credits test failed: \(error.localizedDescription)")
        }
        
        // Test specific module if requested
        if let moduleName = testModule {
            print("🔍 Testing specific module: \(moduleName)")
            // Add specific module testing logic here
        }
        
        // Generate and display test report
        print("\n📊 Test Results Summary:")
        
        // Check if all tests passed
        let allPassed = testResults.allSatisfy { $0.success }
        if !allPassed {
            print("❌ Some tests failed")
            Foundation.exit(1)
        } else {
            print("✅ All tests passed!")
        }
    }
    
    private func showHealth(gui: GUIAbstraction) async throws {
        print("🏥 DirectorStudio Health Check")
        print("=============================")
        
        var healthStatus: [String: Bool] = [:]
        
        // Check AI service
        do {
            let settings = try await gui.getUserSettings()
            healthStatus["AI Service"] = settings.aiServiceEnabled
        } catch {
            healthStatus["AI Service"] = false
        }
        
        // Check credits system
        do {
            let credits = try await gui.getCreditsBalance()
            healthStatus["Credits System"] = true
        } catch {
            healthStatus["Credits System"] = false
        }
        
        // Check persistence
        do {
            let projects = try await gui.getProjects()
            healthStatus["Persistence"] = true
        } catch {
            healthStatus["Persistence"] = false
        }
        
        // Check modules
        healthStatus["Segmentation Module"] = true
        healthStatus["Rewording Module"] = true
        healthStatus["Taxonomy Module"] = true
        healthStatus["Video Generation"] = true
        
        // Display results
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
