//
//  continuity.swift
//  DirectorStudio Pipeline Module #6
//
//  MODULE: Continuity Engine
//  VERSION: 2.0.0 - Enhanced with telemetry learning
//  EXTRACTED FROM: PipelineBackup/ContinuityEngine.swift
//  ADAPTED TO: PipelineModule protocol while preserving 100% logic fidelity
//

import Foundation
import os.log
import NaturalLanguage

// MARK: - Continuity Module

/// Advanced continuity validation and tracking across video segments
/// Features telemetry-based learning, multi-rule validation, and prompt enhancement
public struct ContinuityModule: PipelineModule {
    public typealias Input = ContinuityInput
    public typealias Output = ContinuityOutput
    
    public let id = "continuity"
    public let name = "Continuity Engine"
    public let version = "2.0.0"
    public var isEnabled: Bool = true
    
    private let logger = Loggers.continuity
    private let storage: ContinuityStorageProtocol
    
    public init(storage: ContinuityStorageProtocol = InMemoryContinuityStorage()) {
        self.storage = storage
    }
    
    public func execute(input: ContinuityInput) async throws -> ContinuityOutput {
        let context = PipelineContext()
        let result = await execute(input: input, context: context)
        switch result {
        case .success(let output):
            return output
        case .failure(let error):
            throw error
        }
    }
    
    public func execute(
        input: ContinuityInput,
        context: PipelineContext
    ) async -> Result<ContinuityOutput, PipelineError> {
        logger.info("🔗 Starting continuity validation [v2.0] for \(input.segments.count) segments")
        
        let startTime = Date()
        var validatedSegments: [PromptSegment] = []
        var continuityIssues: [ContinuityIssue] = []
        var overallConfidence: Double = 1.0
        
        // Load previous state and telemetry
        var previousState: SceneState? = try? await storage.loadState()
        let manifestationScores = try? await storage.loadManifestationScores()
        
        // Validate each segment
        for (index, segment) in input.segments.enumerated() {
            let sceneState = extractSceneState(from: segment, index: index)
            
            // Perform validation against previous state
            let validation = validateScene(
                current: sceneState,
                previous: previousState,
                manifestationScores: manifestationScores ?? [:]
            )
            
            // Enhance prompt based on validation and telemetry
            var enhanced = segment
            enhanced = PromptSegment(
                index: segment.index,
                duration: segment.duration,
                content: enhancePrompt(
                    segment.content,
                    sceneState: sceneState,
                    previousState: previousState,
                    manifestationScores: manifestationScores ?? [:]
                ),
                characters: segment.characters,
                setting: segment.setting,
                action: segment.action,
                continuityNotes: segment.continuityNotes,
                location: segment.location,
                props: segment.props,
                tone: segment.tone
            )
            
            validatedSegments.append(enhanced)
            
            // Log issues
            if !validation.issues.isEmpty {
                let issue = ContinuityIssue(
                    segmentIndex: index,
                    confidence: validation.confidence,
                    issues: validation.issues,
                    severity: validation.confidence < 0.6 ? .critical : .warning
                )
                continuityIssues.append(issue)
                
                logger.warning("⚠️ Segment \(index + 1): confidence=\(String(format: "%.2f", validation.confidence)), issues=\(validation.issues.count)")
            }
            
            // Update overall confidence (multiplicative)
            overallConfidence *= validation.confidence
            
            // Save state for next iteration
            try? await storage.saveState(sceneState)
            previousState = sceneState
        }
        
        // Generate continuity anchors
        let anchors = generateContinuityAnchors(from: input.segments)
        
        let executionTime = Date().timeIntervalSince(startTime)
        
        let output = ContinuityOutput(
            validatedSegments: validatedSegments,
            continuityAnchors: anchors,
            continuityIssues: continuityIssues,
            overallConfidence: overallConfidence,
            requiresHumanReview: overallConfidence < 0.6
        )
        
        logger.info("✅ Continuity validation completed in \(String(format: "%.2f", executionTime))s")
        logger.info("📊 Overall confidence: \(String(format: "%.2f%%", overallConfidence * 100))")
        
        if output.requiresHumanReview {
            logger.warning("⚠️ Human review recommended - confidence below threshold")
        }
        
        return .success(output)
    }
    
    public func validate(input: ContinuityInput) -> Bool {
        return !input.segments.isEmpty
    }
    
    public func canSkip() -> Bool {
        // Continuity can be skipped for single-segment projects
        true
    }
    
    // MARK: - Scene State Extraction
    
    /// Extracts scene state from a prompt segment
    private func extractSceneState(from segment: PromptSegment, index: Int) -> SceneState {
        let text = segment.content.lowercased()
        
        // Extract characters (basic NER simulation)
        var characters: [String] = []
        let characterPatterns = [
            "character", "person", "man", "woman", "hero", "villain",
            "protagonist", "antagonist", "friend", "enemy"
        ]
        for pattern in characterPatterns {
            if text.contains(pattern) {
                characters.append(pattern.capitalized)
            }
        }
        
        // Extract location
        var location = "Unknown"
        let locationPatterns = [
            ("forest", "Forest"),
            ("city", "City"),
            ("room", "Room"),
            ("house", "House"),
            ("street", "Street"),
            ("building", "Building"),
            ("park", "Park"),
            ("beach", "Beach")
        ]
        for (pattern, value) in locationPatterns {
            if text.contains(pattern) {
                location = value
                break
            }
        }
        
        // Extract props
        var props: [String] = []
        let propPatterns = [
            "sword", "gun", "book", "phone", "car", "computer",
            "key", "letter", "photograph", "weapon", "tool"
        ]
        for pattern in propPatterns {
            if text.contains(pattern) {
                props.append(pattern.capitalized)
            }
        }
        
        // Determine tone
        let tone = determineTone(text)
        
        return SceneState(
            id: index,
            location: location,
            characters: characters,
            props: props,
            prompt: segment.content,
            tone: tone
        )
    }
    
    // MARK: - Validation Rules
    
    /// Validates current scene against previous state
    private func validateScene(
        current: SceneState,
        previous: SceneState?,
        manifestationScores: [String: ManifestationScore]
    ) -> ValidationResult {
        
        guard let prev = previous else {
            // First scene - nothing to validate against
            return ValidationResult(confidence: 1.0, issues: [])
        }
        
        var confidence = 1.0
        var issues: [String] = []
        
        // Rule 1: Prop persistence
        for prop in prev.props where !current.props.contains(prop) {
            confidence *= 0.7
            issues.append("❌ \(prop) disappeared (was in scene \(prev.id + 1))")
        }
        
        // Rule 2: Character location logic
        if prev.location == current.location {
            for char in prev.characters where !current.characters.contains(char) {
                confidence *= 0.5
                issues.append("❌ \(char) vanished from \(current.location)")
            }
        }
        
        // Rule 3: Tone whiplash detection
        let toneDistance = calculateToneDistance(prev.tone, current.tone)
        if toneDistance > 0.8 {
            confidence *= 0.6
            issues.append("⚠️ Tone jumped: \(prev.tone) → \(current.tone)")
        }
        
        // Rule 4: Manifestation score check
        for prop in current.props {
            if let score = manifestationScores[prop.lowercased()],
               score.manifestationRate < 0.3 {
                confidence *= 0.9
                issues.append("⚠️ \(prop) has low manifestation rate (\(String(format: "%.0f%%", score.manifestationRate * 100)))")
            }
        }
        
        return ValidationResult(confidence: confidence, issues: issues)
    }
    
    // MARK: - Prompt Enhancement
    
    /// Enhances prompt with continuity hints
    private func enhancePrompt(
        _ prompt: String,
        sceneState: SceneState,
        previousState: SceneState?,
        manifestationScores: [String: ManifestationScore]
    ) -> String {
        
        var enhanced = prompt
        var enhancements: [String] = []
        
        // Enhance props with low manifestation rates
        for prop in sceneState.props {
            let rate = manifestationScores[prop.lowercased()]?.manifestationRate ?? 0.8
            if rate < 0.5 {
                enhancements.append("CLEARLY SHOWING \(prop)")
            }
        }
        
        // Add character consistency hints
        if let prev = previousState {
            for char in sceneState.characters where prev.characters.contains(char) {
                enhancements.append("\(char) with same appearance as previous scene")
            }
        }
        
        // Append enhancements if any
        if !enhancements.isEmpty {
            enhanced += " [CONTINUITY: " + enhancements.joined(separator: ", ") + "]"
        }
        
        return enhanced
    }
    
    // MARK: - Continuity Anchors
    
    /// Generates continuity anchors from segments
    private func generateContinuityAnchors(from segments: [PromptSegment]) -> [ContinuityAnchor] {
        var anchors: [ContinuityAnchor] = []
        var characterMap: [String: Set<String>] = [:]
        
        // Collect all character descriptions across segments
        for (index, segment) in segments.enumerated() {
            let state = extractSceneState(from: segment, index: index)
            
            for character in state.characters {
                if characterMap[character] == nil {
                    characterMap[character] = []
                }
                characterMap[character]?.insert(segment.content)
            }
        }
        
        // Create anchors for each character
        for (character, descriptions) in characterMap {
            let anchor = ContinuityAnchor(
                anchorType: "Character",
                description: "\(character): \(descriptions.joined(separator: " | "))",
                segmentIndex: 0
            )
            anchors.append(anchor)
        }
        
        return anchors
    }
    
    // MARK: - Helper Methods
    
    /// Determines tone from text
    private func determineTone(_ text: String) -> String {
        let toneKeywords: [String: String] = [
            "dark": "Dark",
            "scary": "Dark",
            "tense": "Tense",
            "peaceful": "Calm",
            "happy": "Joyful",
            "sad": "Melancholic",
            "exciting": "Exciting",
            "mysterious": "Mysterious"
        ]
        
        for (keyword, tone) in toneKeywords {
            if text.contains(keyword) {
                return tone
            }
        }
        
        return "Neutral"
    }
    
    /// Calculates tone distance using sentiment analysis
    private func calculateToneDistance(_ tone1: String, _ tone2: String) -> Double {
        func sentiment(_ s: String) -> Double {
            let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmed.count >= 2 else { return 0 }
            
            let tagger = NLTagger(tagSchemes: [.sentimentScore])
            tagger.string = trimmed
            var score: Double = 0
            
            let range = trimmed.startIndex..<trimmed.endIndex
            tagger.enumerateTags(in: range, unit: .paragraph, scheme: .sentimentScore) { tag, _ in
                if let raw = tag?.rawValue, let val = Double(raw) {
                    score = val
                } else {
                    score = 0
                }
                return false
            }
            
            return score
        }
        
        return abs(sentiment(tone1) - sentiment(tone2))
    }
    
    // MARK: - Telemetry Update (Called externally after generation)
    
    /// Updates manifestation telemetry for a word/element
    public static func updateTelemetry(
        word: String,
        appeared: Bool,
        storage: ContinuityStorageProtocol
    ) async throws {
        try await storage.saveTelemetry(word, appeared: appeared)
    }
}

// MARK: - Supporting Types

public struct ContinuityInput: Sendable {
    public let segments: [PromptSegment]
    public let projectID: String
    
    public init(segments: [PromptSegment], projectID: String = "") {
        self.segments = segments
        self.projectID = projectID
    }
}

public struct ContinuityOutput: Sendable {
    public let validatedSegments: [PromptSegment]
    public let continuityAnchors: [ContinuityAnchor]
    public let continuityIssues: [ContinuityIssue]
    public let overallConfidence: Double
    public let requiresHumanReview: Bool
    
    public init(
        validatedSegments: [PromptSegment],
        continuityAnchors: [ContinuityAnchor],
        continuityIssues: [ContinuityIssue] = [],
        overallConfidence: Double = 1.0,
        requiresHumanReview: Bool = false
    ) {
        self.validatedSegments = validatedSegments
        self.continuityAnchors = continuityAnchors
        self.continuityIssues = continuityIssues
        self.overallConfidence = overallConfidence
        self.requiresHumanReview = requiresHumanReview
    }
}

public struct ContinuityIssue: Sendable, Codable {
    public let segmentIndex: Int
    public let confidence: Double
    public let issues: [String]
    public let severity: Severity
    
    public enum Severity: String, Codable, Sendable {
        case warning = "Warning"
        case critical = "Critical"
    }
    
    public init(segmentIndex: Int, confidence: Double, issues: [String], severity: Severity) {
        self.segmentIndex = segmentIndex
        self.confidence = confidence
        self.issues = issues
        self.severity = severity
    }
}

// MARK: - Internal Types

public struct SceneState: Sendable, Codable {
    let id: Int
    let location: String
    let characters: [String]
    let props: [String]
    let prompt: String
    let tone: String
}

private struct ValidationResult {
    let confidence: Double
    let issues: [String]
}

public struct ManifestationScore: Sendable, Codable {
    public var attempts: Int
    public var successes: Int
    
    public var manifestationRate: Double {
        guard attempts > 0 else { return 0.8 }
        return Double(successes) / Double(attempts)
    }
    
    public init(attempts: Int = 0, successes: Int = 0) {
        self.attempts = attempts
        self.successes = successes
    }
}

// MARK: - Storage Protocol

/// Storage protocol for continuity state and telemetry
public protocol ContinuityStorageProtocol: Sendable {
    func saveState(_ state: SceneState) async throws
    func loadState() async throws -> SceneState?
    func saveTelemetry(_ element: String, appeared: Bool) async throws
    func loadManifestationScores() async throws -> [String: ManifestationScore]
    func clear() async throws
}

/// In-memory storage implementation (for basic usage)
public actor InMemoryContinuityStorage: ContinuityStorageProtocol {
    private var state: SceneState?
    private var manifestationScores: [String: ManifestationScore] = [:]
    
    public init() {}
    
    public func saveState(_ state: SceneState) async throws {
        self.state = state
    }
    
    public func loadState() async throws -> SceneState? {
        return state
    }
    
    public func saveTelemetry(_ element: String, appeared: Bool) async throws {
        let key = element.lowercased()
        var score = manifestationScores[key] ?? ManifestationScore()
        score.attempts += 1
        if appeared {
            score.successes += 1
        }
        manifestationScores[key] = score
    }
    
    public func loadManifestationScores() async throws -> [String: ManifestationScore] {
        return manifestationScores
    }
    
    public func clear() async throws {
        state = nil
        manifestationScores.removeAll()
    }
}

// MARK: - CoreData Storage (Optional - for production use)

/*
/// CoreData-backed storage for persistence
/// Requires CoreData entities: SceneState, ContinuityLog, Telemetry
public actor CoreDataContinuityStorage: ContinuityStorageProtocol {
    private let context: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    public func saveState(_ state: SceneState) async throws {
        guard NSEntityDescription.entity(forEntityName: "SceneState", in: context) != nil else { return }
        
        let entity = NSEntityDescription.insertNewObject(forEntityName: "SceneState", into: context)
        entity.setValue(state.id, forKey: "id")
        entity.setValue(state.location, forKey: "location")
        entity.setValue(state.characters, forKey: "characters")
        entity.setValue(state.props, forKey: "props")
        entity.setValue(state.prompt, forKey: "prompt")
        entity.setValue(state.tone, forKey: "tone")
        entity.setValue(Date(), forKey: "timestamp")
        
        try context.save()
    }
    
    public func loadState() async throws -> SceneState? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "SceneState")
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        request.fetchLimit = 1
        
        guard let result = try context.fetch(request).first else { return nil }
        
        return SceneState(
            id: result.value(forKey: "id") as? Int ?? 0,
            location: result.value(forKey: "location") as? String ?? "",
            characters: result.value(forKey: "characters") as? [String] ?? [],
            props: result.value(forKey: "props") as? [String] ?? [],
            prompt: result.value(forKey: "prompt") as? String ?? "",
            tone: result.value(forKey: "tone") as? String ?? ""
        )
    }
    
    public func saveTelemetry(_ element: String, appeared: Bool) async throws {
        guard NSEntityDescription.entity(forEntityName: "Telemetry", in: context) != nil else { return }
        
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Telemetry", into: context)
        entity.setValue(element, forKey: "word")
        entity.setValue(appeared, forKey: "appeared")
        entity.setValue(Date(), forKey: "timestamp")
        
        try context.save()
    }
    
    public func loadManifestationScores() async throws -> [String: ManifestationScore] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Telemetry")
        let results = try context.fetch(request)
        
        var scores: [String: ManifestationScore] = [:]
        for result in results {
            guard let word = result.value(forKey: "word") as? String,
                  let appeared = result.value(forKey: "appeared") as? Bool else { continue }
            
            var score = scores[word.lowercased()] ?? ManifestationScore()
            score.attempts += 1
            if appeared { score.successes += 1 }
            scores[word.lowercased()] = score
        }
        
        return scores
    }
    
    public func clear() async throws {
        let entities = ["SceneState", "ContinuityLog", "Telemetry"]
        for entityName in entities {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            try context.execute(deleteRequest)
        }
        try context.save()
    }
}
*/
