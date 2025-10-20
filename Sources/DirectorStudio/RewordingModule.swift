//
//  rewording.swift
//  DirectorStudio
//
//  MODULE #4 - Rewording (FROM YOUR PIPELINEBACKUP)
//  7 transformation types for text refinement
//

import Foundation

// MARK: - Input

public struct RewordingInput: Sendable {
    public let text: String
    public let type: RewordingType
    
    public init(text: String, type: RewordingType) {
        self.text = text
        self.type = type
    }
    
    public enum RewordingType: String, CaseIterable, Identifiable, Sendable {
        case modernizeOldEnglish = "Modernize Old English"
        case improveGrammar = "Improve Grammar"
        case casualTone = "Casual Tone"
        case formalTone = "Formal Tone"
        case poeticStyle = "Poetic Style"
        case fasterPacing = "Faster Pacing"
        case cinematicMood = "Cinematic Mood"
        
        public var id: String { rawValue }
        
        public var systemPrompt: String {
            switch self {
            case .modernizeOldEnglish:
                return "You are an expert at modernizing archaic or old English text into contemporary, natural language while preserving the original meaning and tone. Make it accessible to modern readers."
            case .improveGrammar:
                return "You are a professional editor specializing in grammar improvement. Fix grammatical errors, improve sentence structure, and enhance clarity without changing the core meaning or voice."
            case .casualTone:
                return "You are a skilled writer who can transform text into a casual, conversational tone. Make it feel natural, approachable, and relatable while keeping the essential message intact."
            case .formalTone:
                return "You are an expert at transforming text into formal, professional language. Elevate the sophistication and polish while maintaining the original meaning."
            case .poeticStyle:
                return "You are a poet who can transform narrative text into poetic, evocative language with vivid imagery and rhythmic flow while preserving the story."
            case .fasterPacing:
                return "You are an editor specializing in pacing. Rewrite the text to be more dynamic, urgent, and fast-paced. Use shorter sentences, active voice, and punchy language."
            case .cinematicMood:
                return "You are a screenwriter who can transform text into cinematic prose with visual richness, atmospheric detail, and dramatic tension suitable for film."
            }
        }
    }
}

// MARK: - RewordingStyle Type Alias

public typealias RewordingStyle = RewordingInput.RewordingType

// MARK: - Output

public struct RewordingOutput: Sendable {
    public let originalText: String
    public let rewordedText: String
    public let type: RewordingInput.RewordingType
    public let processingTime: TimeInterval
    
    public init(originalText: String, rewordedText: String, type: RewordingInput.RewordingType, processingTime: TimeInterval) {
        self.originalText = originalText
        self.rewordedText = rewordedText
        self.type = type
        self.processingTime = processingTime
    }
}

// MARK: - Module

public final class RewordingModule: PipelineModule {
    public typealias Input = RewordingInput
    public typealias Output = RewordingOutput
    
    public let id = "rewording"
    public let name = "Rewording"
    public let version = "1.0.0"
    public var isEnabled = true
    
    private let aiService: AIServiceProtocol
    
    public init(aiService: AIServiceProtocol = MockAIService()) {
        self.aiService = aiService
    }
    
    public nonisolated func validate(input: RewordingInput) -> Bool {
        let trimmed = input.text.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count <= 10_000 && aiService.isAvailable
    }
    
    public func execute(input: RewordingInput) async throws -> RewordingOutput {
        let startTime = Date()
        
        let userPrompt = "Rewrite the following text:\n\n\(input.text)"
        
        let rewordedText = try await aiService.processText(
            prompt: userPrompt,
            systemPrompt: input.type.systemPrompt
        )
        
        let processingTime = Date().timeIntervalSince(startTime)
        
        return RewordingOutput(
            originalText: input.text,
            rewordedText: rewordedText,
            type: input.type,
            processingTime: processingTime
        )
    }
}

// MARK: - PipelineModule Implementation

extension RewordingModule {
    public func execute(input: RewordingInput, context: PipelineContext) async -> Result<RewordingOutput, PipelineError> {
        do {
            let output = try await execute(input: input)
            return .success(output)
        } catch {
            return .failure(.executionFailed(error.localizedDescription))
        }
    }
}
