//
//  segmentation.swift
//  DirectorStudio
//
//  MODULE #3 - Segmentation (MIGRATED FROM YOUR ORIGINAL)
//  Intelligent segmentation with adaptive pacing and cinematic flow
//  Handles any narrative structure with smart boundary detection
//

import Foundation

// MARK: - Input

public struct SegmentationInput: Sendable {
    public let story: String
    public let maxDuration: TimeInterval
    
    public init(story: String, maxDuration: TimeInterval = 4.0) {
        self.story = story
        self.maxDuration = maxDuration
    }
}

// MARK: - Output

public struct SegmentationOutput: Sendable {
    public let segments: [PromptSegment]
    public let totalSegments: Int
    public let averageDuration: TimeInterval
    public let metrics: SegmentationMetrics
    public let processingTime: TimeInterval
    
    public init(segments: [PromptSegment], totalSegments: Int, averageDuration: TimeInterval, metrics: SegmentationMetrics, processingTime: TimeInterval) {
        self.segments = segments
        self.totalSegments = totalSegments
        self.averageDuration = averageDuration
        self.metrics = metrics
        self.processingTime = processingTime
    }
}




public struct SegmentationMetrics: Codable, Sendable {
    public let averageDuration: TimeInterval
    public let minDuration: TimeInterval
    public let maxDuration: TimeInterval
    public let standardDeviation: TimeInterval
    public let qualityScore: Double
    public let boundaryQuality: Double
    public let pacingConsistency: Double
    
    public init(averageDuration: TimeInterval = 0, minDuration: TimeInterval = 0, maxDuration: TimeInterval = 0, standardDeviation: TimeInterval = 0, qualityScore: Double = 0, boundaryQuality: Double = 0, pacingConsistency: Double = 0) {
        self.averageDuration = averageDuration
        self.minDuration = minDuration
        self.maxDuration = maxDuration
        self.standardDeviation = standardDeviation
        self.qualityScore = qualityScore
        self.boundaryQuality = boundaryQuality
        self.pacingConsistency = pacingConsistency
    }
}

// MARK: - Module

public final class SegmentationModule: PipelineModule {
    public typealias Input = SegmentationInput
    public typealias Output = SegmentationOutput
    
    public let id = "segmentation"
    public let name = "Segmentation"
    public let version = "1.0.0"
    public var isEnabled = true
    
    public init() {}
    
    public nonisolated func validate(input: SegmentationInput) -> Bool {
        let trimmed = input.story.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && input.maxDuration > 0 && input.maxDuration <= 60
    }
    
    public func execute(input: SegmentationInput) async throws -> SegmentationOutput {
        let startTime = Date()
        
        // Analyze story structure
        let analysis = analyzeSegmentationOpportunities(input.story)
        
        // Perform intelligent segmentation
        var segments = performIntelligentSegmentation(story: input.story, maxDuration: input.maxDuration, analysis: analysis)
        
        // Enhance with pacing metadata
        segments = enhanceWithPacingMetadata(segments, analysis: analysis)
        
        // Calculate quality metrics
        let metrics = calculateSegmentationMetrics(segments, targetDuration: input.maxDuration)
        let processingTime = Date().timeIntervalSince(startTime)
        
        return SegmentationOutput(
            segments: segments,
            totalSegments: segments.count,
            averageDuration: metrics.averageDuration,
            metrics: metrics,
            processingTime: processingTime
        )
    }
    
    // MARK: - Structure Analysis
    
    private func analyzeSegmentationOpportunities(_ story: String) -> SegmentationAnalysis {
        let paragraphs = story.components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        let sentences = story.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        var naturalBreaks: [NaturalBreak] = []
        
        // Detect paragraph boundaries
        var currentPosition = 0
        for (index, paragraph) in paragraphs.enumerated() {
            if index > 0 {
                naturalBreaks.append(NaturalBreak(position: currentPosition, type: .paragraph, strength: 0.8))
            }
            currentPosition += paragraph.count + 2
        }
        
        // Detect scene transitions
        let transitionMarkers = ["Meanwhile", "Later", "The next day", "Suddenly", "Then"]
        for marker in transitionMarkers {
            if let range = story.range(of: marker, options: .caseInsensitive) {
                let position = story.distance(from: story.startIndex, to: range.lowerBound)
                naturalBreaks.append(NaturalBreak(position: position, type: .sceneTransition, strength: 1.0))
            }
        }
        
        naturalBreaks.sort { $0.position < $1.position }
        
        return SegmentationAnalysis(
            paragraphs: paragraphs,
            sentences: sentences,
            naturalBreaks: naturalBreaks,
            averageParagraphLength: paragraphs.isEmpty ? 0 : paragraphs.reduce(0) { $0 + $1.count } / paragraphs.count,
            hasDialogue: story.contains("\""),
            narrativeStyle: detectNarrativeStyle(paragraphs, sentences: sentences)
        )
    }
    
    // MARK: - Intelligent Segmentation
    
    private func performIntelligentSegmentation(story: String, maxDuration: TimeInterval, analysis: SegmentationAnalysis) -> [PromptSegment] {
        var segments: [PromptSegment] = []
        
        // Choose strategy based on narrative style
        switch analysis.narrativeStyle {
        case .structured:
            segments = segmentByParagraphs(story, analysis: analysis, maxDuration: maxDuration)
        case .dialogue:
            segments = segmentByDialogue(story, analysis: analysis, maxDuration: maxDuration)
        case .stream:
            segments = segmentBySentences(story, analysis: analysis, maxDuration: maxDuration)
        case .fragmented:
            segments = segmentBySentences(story, analysis: analysis, maxDuration: maxDuration)
        }
        
        // Enforce max duration
        segments = enforceMaxDuration(segments, maxDuration: maxDuration)
        
        return segments
    }
    
    private func segmentByParagraphs(_ story: String, analysis: SegmentationAnalysis, maxDuration: TimeInterval) -> [PromptSegment] {
        var segments: [PromptSegment] = []
        var currentSegment = ""
        var order = 1
        
        for paragraph in analysis.paragraphs {
            let testSegment = currentSegment.isEmpty ? paragraph : "\(currentSegment)\n\n\(paragraph)"
            let estimatedDuration = estimateDuration(for: testSegment)
            
            if estimatedDuration <= maxDuration {
                currentSegment = testSegment
            } else {
                if !currentSegment.isEmpty {
                    segments.append(createSegment(text: currentSegment, order: order, duration: estimateDuration(for: currentSegment)))
                    order += 1
                }
                currentSegment = paragraph
            }
        }
        
        if !currentSegment.isEmpty {
            segments.append(createSegment(text: currentSegment, order: order, duration: estimateDuration(for: currentSegment)))
        }
        
        return segments
    }
    
    private func segmentByDialogue(_ story: String, analysis: SegmentationAnalysis, maxDuration: TimeInterval) -> [PromptSegment] {
        var segments: [PromptSegment] = []
        let lines = story.components(separatedBy: "\n")
        var currentSegment = ""
        var order = 1
        
        for line in lines {
            let testSegment = currentSegment.isEmpty ? line : "\(currentSegment)\n\(line)"
            let estimatedDuration = estimateDuration(for: testSegment)
            
            if estimatedDuration <= maxDuration {
                currentSegment = testSegment
            } else {
                if !currentSegment.isEmpty {
                    segments.append(createSegment(text: currentSegment, order: order, duration: estimateDuration(for: currentSegment)))
                    order += 1
                }
                currentSegment = line
            }
        }
        
        if !currentSegment.isEmpty {
            segments.append(createSegment(text: currentSegment, order: order, duration: estimateDuration(for: currentSegment)))
        }
        
        return segments
    }
    
    private func segmentBySentences(_ story: String, analysis: SegmentationAnalysis, maxDuration: TimeInterval) -> [PromptSegment] {
        var segments: [PromptSegment] = []
        var currentSegment = ""
        var order = 1
        
        for sentence in analysis.sentences {
            let testSegment = currentSegment.isEmpty ? sentence : "\(currentSegment) \(sentence)"
            let estimatedDuration = estimateDuration(for: testSegment)
            
            if estimatedDuration <= maxDuration {
                currentSegment = testSegment
            } else {
                if !currentSegment.isEmpty {
                    segments.append(createSegment(text: currentSegment, order: order, duration: estimateDuration(for: currentSegment)))
                    order += 1
                }
                currentSegment = sentence
            }
        }
        
        if !currentSegment.isEmpty {
            segments.append(createSegment(text: currentSegment, order: order, duration: estimateDuration(for: currentSegment)))
        }
        
        return segments
    }
    
    private func enforceMaxDuration(_ segments: [PromptSegment], maxDuration: TimeInterval) -> [PromptSegment] {
        var result: [PromptSegment] = []
        var order = 1
        
        for segment in segments {
            if Double(segment.duration) <= maxDuration {
                var adjusted = segment
                result.append(adjusted)
                order += 1
            } else {
                // Split oversized segment
                let words = segment.content.components(separatedBy: CharacterSet.whitespacesAndNewlines)
                var currentChunk = ""
                var currentWords: [String] = []
                
                for word in words {
                    currentWords.append(word)
                    currentChunk = currentWords.joined(separator: " ")
                    
                    if estimateDuration(for: currentChunk) >= maxDuration * 0.9 {
                        result.append(createSegment(text: currentChunk, order: order, duration: estimateDuration(for: currentChunk)))
                        order += 1
                        currentWords = []
                        currentChunk = ""
                    }
                }
                
                if !currentChunk.isEmpty {
                    result.append(createSegment(text: currentChunk, order: order, duration: estimateDuration(for: currentChunk)))
                    order += 1
                }
            }
        }
        
        return result
    }
    
    private func enhanceWithPacingMetadata(_ segments: [PromptSegment], analysis: SegmentationAnalysis) -> [PromptSegment] {
        return segments.enumerated().map { index, segment in
            var enhanced = segment
            let pacing = calculatePacing(segment, index: index, total: segments.count)
            let transitionType = detectTransitionType(segment, previousSegment: index > 0 ? segments[index - 1] : nil)
            
            // Add structured metadata to cinematic tags
            enhanced.cinematicTags = CinematicTaxonomy(
                shotType: "Medium Shot",
                cameraAngle: "Eye Level",
                framing: "Standard",
                lighting: "Natural",
                colorPalette: "Neutral",
                lensType: "Standard",
                cameraMovement: "Static",
                emotionalTone: pacing.rawValue,
                visualStyle: transitionType.rawValue,
                actionCues: ["Position: \(String(format: "%.2f", Double(index) / Double(max(segments.count - 1, 1))))"]
            )
            
            return enhanced
        }
    }
    
    // MARK: - Helper Methods
    
    private func estimateDuration(for text: String) -> TimeInterval {
        let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        let wordsPerSecond = 2.0
        return Double(words.count) / wordsPerSecond
    }
    
    private func createSegment(text: String, order: Int, duration: TimeInterval) -> PromptSegment {
        PromptSegment(
            index: order,
            duration: Int(duration),
            content: text.trimmingCharacters(in: .whitespacesAndNewlines),
            characters: [],
            setting: "Unknown Setting",
            action: "Unknown Action",
            continuityNotes: "",
            location: "Unknown Location",
            props: [],
            tone: "Neutral"
        )
    }
    
    private func detectNarrativeStyle(_ paragraphs: [String], sentences: [String]) -> NarrativeStyle {
        let avgParagraphLength = paragraphs.isEmpty ? 0 : paragraphs.reduce(0) { $0 + $1.count } / paragraphs.count
        let hasDialogue = paragraphs.contains { $0.contains("\"") }
        let avgSentenceLength = sentences.isEmpty ? 0 : sentences.reduce(0) { $0 + $1.count } / sentences.count
        
        if hasDialogue && paragraphs.filter({ $0.contains("\"") }).count > paragraphs.count / 2 {
            return .dialogue
        } else if avgSentenceLength < 30 {
            return .fragmented
        } else if avgParagraphLength < 200 {
            return .stream
        } else {
            return .structured
        }
    }
    
    private func calculatePacing(_ segment: PromptSegment, index: Int, total: Int) -> SegmentPacing {
        let wordCount = segment.content.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
        if wordCount < 20 { return .fast }
        if wordCount > 60 { return .slow }
        let position = Double(index) / Double(max(total - 1, 1))
        if position > 0.3 && position < 0.7 { return .building }
        return .moderate
    }
    
    private func detectTransitionType(_ segment: PromptSegment, previousSegment: PromptSegment?) -> TransitionType {
        guard previousSegment != nil else { return .hard }
        let currentStart = String(segment.content.prefix(50)).lowercased()
        if currentStart.contains("meanwhile") || currentStart.contains("later") { return .temporal }
        if currentStart.contains("at ") || currentStart.contains("in the") { return .spatial }
        if segment.content.contains("\"") { return .dialogue }
        return .cut
    }
    
    private func calculateSegmentationMetrics(_ segments: [PromptSegment], targetDuration: TimeInterval) -> SegmentationMetrics {
        guard !segments.isEmpty else {
            return SegmentationMetrics()
        }
        
        let durations = segments.map { Double($0.duration) }
        let avgDuration = durations.reduce(0, +) / Double(durations.count)
        let minDuration = durations.min() ?? 0
        let maxDuration = durations.max() ?? 0
        
        let variance = durations.reduce(0.0) { sum, duration in
            sum + pow(duration - avgDuration, 2)
        } / Double(durations.count)
        let stdDev = sqrt(variance)
        
        let avgDeviation = abs(avgDuration - targetDuration) / targetDuration
        let qualityScore = max(0.0, 1.0 - avgDeviation)
        let boundaryQuality = max(0.0, 1.0 - (stdDev / avgDuration))
        
        return SegmentationMetrics(
            averageDuration: avgDuration,
            minDuration: minDuration,
            maxDuration: maxDuration,
            standardDeviation: stdDev,
            qualityScore: qualityScore,
            boundaryQuality: boundaryQuality,
            pacingConsistency: boundaryQuality
        )
    }
}

// MARK: - Supporting Types

private struct SegmentationAnalysis {
    let paragraphs: [String]
    let sentences: [String]
    let naturalBreaks: [NaturalBreak]
    let averageParagraphLength: Int
    let hasDialogue: Bool
    let narrativeStyle: NarrativeStyle
}

private struct NaturalBreak {
    let position: Int
    let type: BreakType
    let strength: Double
}

private enum BreakType {
    case paragraph
    case sceneTransition
    case dialogueShift
}

private enum NarrativeStyle {
    case structured
    case dialogue
    case stream
    case fragmented
}

// MARK: - Pacing Types

/// Segment pacing classification for video generation
public enum PacingType: String, Codable, Sendable, CaseIterable {
    case fast = "Fast"
    case moderate = "Moderate"
    case slow = "Slow"
    case building = "Building"
    
    public var id: String { rawValue }
}

// MARK: - PipelineModule Implementation

extension SegmentationModule {
    public func execute(input: SegmentationInput, context: PipelineContext) async -> Result<SegmentationOutput, PipelineError> {
        do {
            let output = try await execute(input: input)
            return .success(output)
        } catch {
            return .failure(.executionFailed(error.localizedDescription))
        }
    }
}

