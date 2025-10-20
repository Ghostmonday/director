#!/usr/bin/env swift

//
//  verify-types.swift
//  DirectorStudio Type Verification Script
//
//  PREEMPTIVE HARDENING: Core Type Interface Verification
//  This script verifies that current core types match the frozen snapshot
//  to prevent interface drift during automated execution.
//

import Foundation

// MARK: - Type Verification Engine

struct TypeVerificationEngine {
    let snapshotFile: String
    let sourceDirectory: String
    
    init(snapshotFile: String = "Sources/DirectorStudio/Core/CoreTypeSnapshot.swift",
         sourceDirectory: String = "Sources/DirectorStudio") {
        self.snapshotFile = snapshotFile
        self.sourceDirectory = sourceDirectory
    }
    
    func verifyAllTypes() throws -> VerificationResult {
        print("🔍 Starting core type verification...")
        
        var results: [TypeVerification] = []
        
        // Verify each core type
        let typesToVerify = [
            "PromptSegment",
            "PipelineContext",
            "PipelineConfiguration", 
            "AIService",
            "ContentAnalysis",
            "CinematicTaxonomy",
            "SceneModel"
        ]
        
        for typeName in typesToVerify {
            let verification = try verifyType(typeName)
            results.append(verification)
            
            if verification.isCompatible {
                print("✅ \(typeName): Compatible")
            } else {
                print("❌ \(typeName): Interface drift detected")
                print("   Issues: \(verification.issues.joined(separator: ", "))")
            }
        }
        
        let compatibleCount = results.filter { $0.isCompatible }.count
        let totalCount = results.count
        
        return VerificationResult(
            sourceDirectory: sourceDirectory,
            totalTypes: totalCount,
            compatibleTypes: compatibleCount,
            incompatibleTypes: totalCount - compatibleCount,
            verifications: results
        )
    }
    
    private func verifyType(_ typeName: String) throws -> TypeVerification {
        let snapshotDefinition = try extractSnapshotDefinition(typeName)
        let currentDefinition = try extractCurrentDefinition(typeName)
        
        let issues = compareDefinitions(
            snapshot: snapshotDefinition,
            current: currentDefinition,
            typeName: typeName
        )
        
        return TypeVerification(
            typeName: typeName,
            isCompatible: issues.isEmpty,
            issues: issues,
            snapshotDefinition: snapshotDefinition,
            currentDefinition: currentDefinition
        )
    }
    
    private func extractSnapshotDefinition(_ typeName: String) throws -> String {
        let fileURL = URL(fileURLWithPath: snapshotFile)
        let content = try String(contentsOf: fileURL, encoding: .utf8)
        
        // Extract the frozen interface definition
        let pattern = "public struct \(typeName)Interface[\\s\\S]*?^}"
        let regex = try NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines, .dotMatchesLineSeparators])
        let range = NSRange(location: 0, length: content.utf16.count)
        
        if let match = regex.firstMatch(in: content, options: [], range: range) {
            let matchRange = match.range
            let startIndex = content.index(content.startIndex, offsetBy: matchRange.location)
            let endIndex = content.index(startIndex, offsetBy: matchRange.length)
            return String(content[startIndex..<endIndex])
        }
        
        throw VerificationError.snapshotNotFound(typeName)
    }
    
    private func extractCurrentDefinition(_ typeName: String) throws -> String {
        let files = try findSwiftFiles()
        var foundDefinition: String?
        
        for file in files {
            let content = try String(contentsOf: URL(fileURLWithPath: file), encoding: .utf8)
            
            // Look for struct/class/protocol definition
            let patterns = [
                "public struct \(typeName)[\\s\\S]*?^}",
                "public class \(typeName)[\\s\\S]*?^}",
                "public protocol \(typeName)[\\s\\S]*?^}"
            ]
            
            for pattern in patterns {
                let regex = try NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines, .dotMatchesLineSeparators])
                let range = NSRange(location: 0, length: content.utf16.count)
                
                if let match = regex.firstMatch(in: content, options: [], range: range) {
                    let matchRange = match.range
                    let startIndex = content.index(content.startIndex, offsetBy: matchRange.location)
                    let endIndex = content.index(startIndex, offsetBy: matchRange.length)
                    foundDefinition = String(content[startIndex..<endIndex])
                    break
                }
            }
            
            if foundDefinition != nil { break }
        }
        
        guard let definition = foundDefinition else {
            throw VerificationError.currentTypeNotFound(typeName)
        }
        
        return definition
    }
    
    private func compareDefinitions(snapshot: String, current: String, typeName: String) -> [String] {
        var issues: [String] = []
        
        // Extract property signatures
        let snapshotProperties = extractPropertySignatures(snapshot)
        let currentProperties = extractPropertySignatures(current)
        
        // Check for missing properties
        for (name, signature) in snapshotProperties {
            if let currentSignature = currentProperties[name] {
                if currentSignature != signature {
                    issues.append("Property '\(name)' signature changed: expected '\(signature)', found '\(currentSignature)'")
                }
            } else {
                issues.append("Missing required property '\(name)'")
            }
        }
        
        // Check for extra properties
        for name in currentProperties.keys {
            if snapshotProperties[name] == nil {
                issues.append("Unexpected property '\(name)' added")
            }
        }
        
        return issues
    }
    
    private func extractPropertySignatures(_ definition: String) -> [String: String] {
        var properties: [String: String] = [:]
        
        // Extract public let/var properties
        let pattern = "public\\s+(let|var)\\s+(\\w+)\\s*:\\s*([^=\\n]+)"
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: definition.utf16.count)
        
        let matches = regex.matches(in: definition, options: [], range: range)
        for match in matches {
            if let nameRange = Range(match.range(at: 2), in: definition),
               let typeRange = Range(match.range(at: 3), in: definition) {
                let name = String(definition[nameRange])
                let type = String(definition[typeRange]).trimmingCharacters(in: .whitespaces)
                properties[name] = type
            }
        }
        
        return properties
    }
    
    private func findSwiftFiles() throws -> [String] {
        let fileManager = FileManager.default
        var swiftFiles: [String] = []
        
        func enumerateDirectory(_ path: String) throws {
            let contents = try fileManager.contentsOfDirectory(atPath: path)
            
            for item in contents {
                let fullPath = "\(path)/\(item)"
                var isDirectory: ObjCBool = false
                
                if fileManager.fileExists(atPath: fullPath, isDirectory: &isDirectory) {
                    if isDirectory.boolValue {
                        try enumerateDirectory(fullPath)
                    } else if item.hasSuffix(".swift") {
                        swiftFiles.append(fullPath)
                    }
                }
            }
        }
        
        try enumerateDirectory(sourceDirectory)
        return swiftFiles
    }
}

// MARK: - Verification Models

struct VerificationResult: Codable {
    let sourceDirectory: String
    let totalTypes: Int
    let compatibleTypes: Int
    let incompatibleTypes: Int
    let verifications: [TypeVerification]
    
    var isAllCompatible: Bool {
        return incompatibleTypes == 0
    }
    
    var summary: String {
        return "Verification Complete: \(compatibleTypes)/\(totalTypes) types compatible"
    }
}

struct TypeVerification: Codable {
    let typeName: String
    let isCompatible: Bool
    let issues: [String]
    let snapshotDefinition: String
    let currentDefinition: String
}

enum VerificationError: Error {
    case snapshotNotFound(String)
    case currentTypeNotFound(String)
    case fileReadError(String)
    
    var localizedDescription: String {
        switch self {
        case .snapshotNotFound(let type):
            return "Snapshot definition not found for type: \(type)"
        case .currentTypeNotFound(let type):
            return "Current definition not found for type: \(type)"
        case .fileReadError(let path):
            return "Failed to read file: \(path)"
        }
    }
}

// MARK: - Main Execution

func main() {
    let arguments = CommandLine.arguments
    
    if arguments.contains("--help") || arguments.contains("-h") {
        print("""
        Core Type Verification Script
        
        Usage: swift verify-types.swift [options]
        
        Options:
          --help, -h     Show this help message
          --verbose, -v  Enable verbose output
          --json         Output results in JSON format
        """)
        return
    }
    
    let verbose = arguments.contains("--verbose") || arguments.contains("-v")
    let jsonOutput = arguments.contains("--json")
    
    do {
        let engine = TypeVerificationEngine()
        let result = try engine.verifyAllTypes()
        
        if jsonOutput {
            let jsonData = try JSONEncoder().encode(result)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }
        } else {
            print("\n📊 \(result.summary)")
            
            if result.isAllCompatible {
                print("🎉 All core types are compatible with frozen snapshot!")
                exit(0)
            } else {
                print("⚠️  \(result.incompatibleTypes) types have interface drift")
                print("\nDetailed Issues:")
                
                for verification in result.verifications where !verification.isCompatible {
                    print("\n❌ \(verification.typeName):")
                    for issue in verification.issues {
                        print("   • \(issue)")
                    }
                    
                    if verbose {
                        print("\n   Snapshot Definition:")
                        print("   \(verification.snapshotDefinition)")
                        print("\n   Current Definition:")
                        print("   \(verification.currentDefinition)")
                    }
                }
                
                exit(1)
            }
        }
    } catch {
        print("❌ Verification failed: \(error.localizedDescription)")
        exit(1)
    }
}

main()
