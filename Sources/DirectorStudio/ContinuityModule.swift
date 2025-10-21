//
//  ContinuityModule.swift
//  DirectorStudio
//
//  Advanced Cinematic Continuity Intelligence Engine
//  Scene-to-scene transition analysis with deep reasoning
//

import Foundation

// MARK: - Continuity Module

/// Advanced continuity validation and cinematic intelligence engine
/// Analyzes scene transitions with semantic understanding, emotional flow, and narrative coherence
@available(iOS 15.0, *)
public final class ContinuityModule: PipelineModule, ObservableObject {
    public typealias Input = ContinuityInput
    public typealias Output = ContinuityOutput
    
    // MARK: - Properties
    
    public let id = "continuity_module"
    public let name = "Cinematic Continuity Engine"
    public let version = "2.0.0"
    
    @Published public var isEnabled: Bool = true
    @Published public var validationResults: [ContinuityValidation] = []
    @Published public var isProcessing: Bool = false
    
    private let logger = Loggers.continuity
    
    // Continuity engines
    private let locationClassifier = LocationClassifier()
    private let toneGraph = ToneEvolutionGraph()
    private let propMemory = PropContinuityMemory()
    private let characterValidator = CharacterArcValidator()
    private let transitionTyper = TransitionTyper()
    
    // History tracking for multi-segment memory
    private var transitionHistory: [TransitionRecord] = []
    
    // MARK: - Initialization
    
    public init() {
        logger.info("ContinuityModule v2.0 initialized - Cinematic Intelligence Enabled")
        Telemetry.shared.logEvent("continuity_module_initialized", properties: ["version": "2.0.0"])
    }
    
    // MARK: - PipelineModule Implementation
    
    public func execute(
        input: Input,
        context: PipelineContext
    ) async -> Result<Output, PipelineError> {
        let startTime = Date()
        logger.info("🎬 Starting cinematic continuity analysis for \(input.segments.count) segments")
        Telemetry.shared.logEvent("continuity_analysis_started", properties: [
            "segment_count": input.segments.count,
            "strict_mode": input.strictMode
        ])
        
        await MainActor.run {
            isProcessing = true
        }
        
        defer {
            Task { @MainActor in
                isProcessing = false
            }
        }
        
        // Validate input
        guard validate(input: input) else {
            logger.error("Input validation failed")
            Telemetry.shared.logEvent("continuity_analysis_failed", properties: ["reason": "invalid_input"])
            return .failure(.invalidInput("Invalid segments provided"))
        }
        
        // Initialize continuity engines with context
        await prepareEngines(for: context)
        
        // Perform deep continuity analysis
        do {
            let result = try await analyzeContinuity(
                segments: input.segments,
                context: context,
                strictMode: input.strictMode
            )
            
            await MainActor.run {
                self.validationResults = result.validations
            }
            
            let duration = Date().timeIntervalSince(startTime)
            logger.info("✅ Continuity analysis completed in \(String(format: "%.2f", duration))s - Score: \(Int(result.continuityScore * 100))%")
            Telemetry.shared.logEvent("continuity_analysis_completed", properties: [
                "score": result.continuityScore,
                "duration_seconds": duration,
                "issue_count": result.issues.count,
                "suggestion_count": result.suggestions.count
            ])
            
            return .success(result)
        } catch {
            logger.error("Continuity analysis failed: \(error.localizedDescription)")
            Telemetry.shared.logEvent("continuity_analysis_error", properties: ["error": error.localizedDescription])
            return .failure(.executionFailed(error.localizedDescription))
        }
    }
    
    public func validate(input: Input) -> Bool {
        return !input.segments.isEmpty
    }
    
    public func execute(input: Input) async throws -> Output {
        let context = PipelineContext()
        let result = await execute(input: input, context: context)
        
        switch result {
        case .success(let output):
            return output
        case .failure(let error):
            throw error
        }
    }
    
    // MARK: - Engine Preparation
    
    private func prepareEngines(for context: PipelineContext) async {
        // Configure tone graph based on genre
        if let genre = context.genre {
            await toneGraph.configureForGenre(genre)
        }
        
        // Reset memory for new analysis
        propMemory.reset()
        await characterValidator.reset()
        transitionHistory.removeAll()
    }
    
    // MARK: - Deep Continuity Analysis
    
    private func analyzeContinuity(
        segments: [PromptSegment],
        context: PipelineContext,
        strictMode: Bool
    ) async throws -> ContinuityOutput {
        var validations: [ContinuityValidation] = []
        var issues: [ContinuityIssue] = []
        var suggestions: [ContinuitySuggestion] = []
        var transitionAnalysis: [TransitionAnalysis] = []
        
        context.progressCallback?(0.05)
        
        // First pass: Build semantic understanding
        logger.info("🧠 Building semantic understanding...")
        await buildSemanticContext(segments: segments, context: context)
        context.progressCallback?(0.15)
        
        // Second pass: Analyze transitions
        logger.info("🔄 Analyzing scene transitions...")
        for i in 0..<segments.count - 1 {
            let current = segments[i]
            let next = segments[i + 1]
            
            // Perform comprehensive transition analysis
            let analysis = await analyzeTransition(
                from: current,
                to: next,
                index: i,
                context: context,
                strictMode: strictMode
            )
            
            transitionAnalysis.append(analysis)
            validations.append(analysis.validation)
            issues.append(contentsOf: analysis.issues)
            suggestions.append(contentsOf: analysis.suggestions)
            
            // Record transition for historical context
            transitionHistory.append(TransitionRecord(
                fromIndex: i,
                toIndex: i + 1,
                analysis: analysis
            ))
            
            // Update progress
            let progress = Double(i + 1) / Double(segments.count - 1)
            context.progressCallback?(0.15 + progress * 0.7)
        }
        
        // Third pass: Cross-segment validation
        logger.info("🎭 Validating narrative arcs...")
        let arcIssues = await validateNarrativeArcs(segments: segments, context: context)
        issues.append(contentsOf: arcIssues)
        context.progressCallback?(0.90)
        
        // Generate weighted continuity score
        let score = calculateWeightedScore(
            validations: validations,
            issues: issues,
            segments: segments,
            context: context
        )
        
        // Generate intelligent suggestions
        let enhancedSuggestions = await generateIntelligentSuggestions(
            issues: issues,
            segments: segments,
            transitionAnalysis: transitionAnalysis,
            context: context
        )
        suggestions.append(contentsOf: enhancedSuggestions)
        
        context.progressCallback?(1.0)
        
        return ContinuityOutput(
            segments: segments,
            validations: validations,
            issues: issues,
            suggestions: suggestions,
            continuityScore: score,
            transitionAnalysis: transitionAnalysis,
            metadata: ContinuityMetadata(
                totalSegments: segments.count,
                validTransitions: validations.filter { $0.isValid }.count,
                issueCount: issues.count,
                suggestionCount: suggestions.count,
                averageTransitionQuality: transitionAnalysis.map { $0.quality }.average(),
                narrativeCoherence: calculateNarrativeCoherence(validations),
                emotionalFlowScore: calculateEmotionalFlowScore(transitionAnalysis)
            )
        )
    }
    
    // MARK: - Semantic Context Building
    
    private func buildSemanticContext(segments: [PromptSegment], context: PipelineContext) async {
        for segment in segments {
            // Classify locations semantically
            if !segment.location.isEmpty {
                locationClassifier.classify(segment.location)
            }
            
            // Track props across narrative
            propMemory.registerProps(segment.props, in: segment.index)
            
            // Build character presence map
            await characterValidator.registerCharacters(segment.characters, in: segment.index, content: segment.content)
        }
    }
    
    // MARK: - Transition Analysis
    
    private func analyzeTransition(
        from current: PromptSegment,
        to next: PromptSegment,
        index: Int,
        context: PipelineContext,
        strictMode: Bool
    ) async -> TransitionAnalysis {
        var issues: [ContinuityIssue] = []
        var suggestions: [ContinuitySuggestion] = []
        var scores: [String: Double] = [:]
        
        // 1. Location Continuity (Semantic)
        let locationResult = await analyzeLocationTransition(from: current, to: next, strictMode: strictMode)
        issues.append(contentsOf: locationResult.issues)
        suggestions.append(contentsOf: locationResult.suggestions)
        scores["location"] = locationResult.score
        
        // 2. Tone Evolution (Graph-based)
        let toneResult = await analyzeToneEvolution(from: current, to: next, history: transitionHistory)
        issues.append(contentsOf: toneResult.issues)
        suggestions.append(contentsOf: toneResult.suggestions)
        scores["tone"] = toneResult.score
        
        // 3. Character Arc (Deep validation)
        let characterResult = await analyzeCharacterArcs(from: current, to: next, context: context)
        issues.append(contentsOf: characterResult.issues)
        suggestions.append(contentsOf: characterResult.suggestions)
        scores["character"] = characterResult.score
        
        // 4. Prop Memory (Persistence tracking)
        let propResult = await analyzePropContinuity(from: current, to: next)
        issues.append(contentsOf: propResult.issues)
        suggestions.append(contentsOf: propResult.suggestions)
        scores["props"] = propResult.score
        
        // 5. Transition Type Detection
        let transitionType = transitionTyper.detectTransitionType(from: current, to: next)
        let transitionResult = await validateTransitionType(
            type: transitionType,
            from: current,
            to: next
        )
        issues.append(contentsOf: transitionResult.issues)
        suggestions.append(contentsOf: transitionResult.suggestions)
        scores["transition"] = transitionResult.score
        
        // 6. Emotional Flow (from StoryAnalysisModule integration)
        if let emotionalScore = await analyzeEmotionalFlow(from: current, to: next, context: context) {
            scores["emotional"] = emotionalScore
        }
        
        // Calculate overall quality
        let quality = Array(scores.values).average()
        let isValid = quality >= (strictMode ? 0.8 : 0.6) && issues.filter { $0.severity == .critical || $0.severity == .high }.isEmpty
        
        let validation = ContinuityValidation(
            segmentIndex: index,
            fromSegment: current.index,
            toSegment: next.index,
            isValid: isValid,
            quality: quality,
            issues: issues
        )
        
        return TransitionAnalysis(
            validation: validation,
            issues: issues,
            suggestions: suggestions,
            transitionType: transitionType,
            quality: quality,
            scores: scores
        )
    }
    
    // MARK: - Location Analysis (Semantic)
    
    private func analyzeLocationTransition(
        from current: PromptSegment,
        to next: PromptSegment,
        strictMode: Bool
    ) async -> AnalysisResult {
        var issues: [ContinuityIssue] = []
        var suggestions: [ContinuitySuggestion] = []
        
        guard current.location != next.location else {
            return AnalysisResult(score: 1.0, issues: [], suggestions: [])
        }
        
        // Semantic classification
        let currentType = locationClassifier.classify(current.location)
        let nextType = locationClassifier.classify(next.location)
        
        // Check semantic relationship
        let relationship = locationClassifier.analyzeRelationship(from: currentType, to: nextType)
        
        // Detect transition indicators
        let hasExplicitTransition = detectTransitionIndicators(in: next.content)
        let transitionKeywords = extractTransitionKeywords(from: next.content)
        
        var score = 1.0
        
        switch relationship {
        case .sameLocation:
            score = 1.0
            
        case .subLocation:
            // Moving to a sub-location (e.g., "forest" → "forest clearing")
            score = hasExplicitTransition ? 0.9 : 0.7
            if !hasExplicitTransition && strictMode {
                issues.append(ContinuityIssue(
                    type: .locationJump,
                    severity: .low,
                    fromSegment: current.index,
                    toSegment: next.index,
                    description: "Moving from '\(current.location)' to '\(next.location)' without explicit navigation",
                    affectedElement: next.location,
                    context: "These locations are related but transition could be clearer"
                ))
            }
            
        case .adjacentLocation:
            // Nearby locations (e.g., "deck" → "bridge" on same ship)
            score = hasExplicitTransition ? 0.85 : 0.6
            if !hasExplicitTransition {
                suggestions.append(ContinuitySuggestion(
                    type: .addTransition,
                    segmentIndex: next.index,
                    description: "Add spatial transition",
                    proposedChange: "Consider adding: 'They move from the \(current.location) to the \(next.location)' or a similar bridging phrase"
                ))
                score = 0.6
            }
            
        case .distantLocation:
            // Major location change
            score = hasExplicitTransition ? 0.7 : 0.3
            if !hasExplicitTransition {
                let severity: ContinuityIssue.Severity = strictMode ? .high : .medium
                issues.append(ContinuityIssue(
                    type: .locationJump,
                    severity: severity,
                    fromSegment: current.index,
                    toSegment: next.index,
                    description: "Sudden location jump from '\(current.location)' to '\(next.location)' without explanation",
                    affectedElement: next.location,
                    context: "Distance: \(relationship.rawValue), requires transition"
                ))
                suggestions.append(ContinuitySuggestion(
                    type: .addTransition,
                    segmentIndex: next.index,
                    description: "Add location transition",
                    proposedChange: "Add a transition shot, time card, or narrative bridge like 'Later, at the \(next.location)...' or 'Cut to: \(next.location)'"
                ))
                score = 0.3
            } else {
                // Has transition but could be enhanced
                if transitionKeywords.isEmpty {
                    suggestions.append(ContinuitySuggestion(
                        type: .smoothTransition,
                        segmentIndex: next.index,
                        description: "Enhance transition clarity",
                        proposedChange: "Strengthen the transition with specific temporal or spatial markers"
                    ))
                }
            }
        }
        
        Telemetry.shared.logEvent("location_transition_analyzed", properties: [
            "from": current.location,
            "to": next.location,
            "relationship": relationship.rawValue,
            "has_transition": hasExplicitTransition,
            "score": score
        ])
        
        return AnalysisResult(score: score, issues: issues, suggestions: suggestions)
    }
    
    // MARK: - Tone Evolution Analysis
    
    private func analyzeToneEvolution(
        from current: PromptSegment,
        to next: PromptSegment,
        history: [TransitionRecord]
    ) async -> AnalysisResult {
        var issues: [ContinuityIssue] = []
        var suggestions: [ContinuitySuggestion] = []
        
        // Extract tones (you may integrate with TaxonomyModule here)
        let currentTone = extractTone(from: current.content)
        let nextTone = extractTone(from: next.content)
        
        // Check tone adjacency in graph
        let isAdjacent = await toneGraph.areAdjacent(from: currentTone, to: nextTone)
        let distance = await toneGraph.distance(from: currentTone, to: nextTone)
        
        // Consider historical context
        let recentTones = history.suffix(3).compactMap { extractTone(from: $0.analysis.validation.content ?? "") }
        let hasRepeatedShifts = await toneGraph.detectRepeatedShifts(in: recentTones + [currentTone, nextTone])
        
        var score = 1.0
        
        if !isAdjacent && distance > 2 {
            // Jarring tone shift
            let severity: ContinuityIssue.Severity = distance > 3 ? .high : .medium
            issues.append(ContinuityIssue(
                type: .toneShift,
                severity: severity,
                fromSegment: current.index,
                toSegment: next.index,
                description: "Abrupt tone shift from '\(currentTone.rawValue)' to '\(nextTone.rawValue)'",
                affectedElement: nextTone.rawValue,
                context: "Distance: \(distance), Adjacency check failed"
            ))
            suggestions.append(ContinuitySuggestion(
                type: .smoothTransition,
                segmentIndex: next.index,
                description: "Smooth tone transition",
                proposedChange: "Consider adding a bridge scene with intermediate tone: \(await toneGraph.suggestBridgeTone(from: currentTone, to: nextTone)?.rawValue ?? "transitional")"
            ))
            score = max(0.3, 1.0 - Double(distance) * 0.15)
        } else if hasRepeatedShifts {
            // Whiplash effect
            issues.append(ContinuityIssue(
                type: .toneShift,
                severity: .medium,
                fromSegment: current.index,
                toSegment: next.index,
                description: "Tone whiplash detected - rapid shifts may disorient viewers",
                affectedElement: nil,
                context: "Recent pattern: \(recentTones.map { $0.rawValue }.joined(separator: " → "))"
            ))
            score = 0.6
        } else if distance == 2 {
            // Acceptable but could be smoother
            score = 0.8
            suggestions.append(ContinuitySuggestion(
                type: .smoothTransition,
                segmentIndex: next.index,
                description: "Consider smoothing tone transition",
                proposedChange: "Optional: Add subtle emotional bridging to ease the shift"
            ))
        } else {
            score = 1.0
        }
        
        Telemetry.shared.logEvent("tone_evolution_analyzed", properties: [
            "from_tone": currentTone.rawValue,
            "to_tone": nextTone.rawValue,
            "distance": distance,
            "is_adjacent": isAdjacent,
            "score": score
        ])
        
        return AnalysisResult(score: score, issues: issues, suggestions: suggestions)
    }
    
    // MARK: - Character Arc Analysis
    
    private func analyzeCharacterArcs(
        from current: PromptSegment,
        to next: PromptSegment,
        context: PipelineContext
    ) async -> AnalysisResult {
        var issues: [ContinuityIssue] = []
        var suggestions: [ContinuitySuggestion] = []
        var score = 1.0
        
        // Analyze character transitions
        let disappearing = Set(current.characters).subtracting(Set(next.characters))
        let appearing = Set(next.characters).subtracting(Set(current.characters))
        
        // Advanced character analysis
        for character in disappearing {
            let validation = await characterValidator.validateDisappearance(
                character: character,
                fromSegment: current.index,
                toSegment: next.index,
                context: next.content
            )
            
            if let issue = validation.issue {
                issues.append(issue)
                score -= 0.15
            }
            if let suggestion = validation.suggestion {
                suggestions.append(suggestion)
            }
        }
        
        for character in appearing {
            let validation = await characterValidator.validateAppearance(
                character: character,
                inSegment: next.index,
                context: next.content,
                previousSegments: [current]
            )
            
            if let issue = validation.issue {
                issues.append(issue)
                score -= 0.15
            }
            if let suggestion = validation.suggestion {
                suggestions.append(suggestion)
            }
        }
        
        // Check for emotional arc consistency (integrate with StoryAnalysisModule)
        if let emotionalIssues = await validateEmotionalConsistency(
            characters: Set(current.characters).intersection(Set(next.characters)),
            from: current,
            to: next,
            context: context
        ) {
            issues.append(contentsOf: emotionalIssues)
            score -= Double(emotionalIssues.count) * 0.1
        }
        
        score = max(0.0, score)
        
        Telemetry.shared.logEvent("character_arc_analyzed", properties: [
            "disappearing_count": disappearing.count,
            "appearing_count": appearing.count,
            "issue_count": issues.count,
            "score": score
        ])
        
        return AnalysisResult(score: score, issues: issues, suggestions: suggestions)
    }
    
    // MARK: - Prop Continuity Analysis
    
    private func analyzePropContinuity(
        from current: PromptSegment,
        to next: PromptSegment
    ) async -> AnalysisResult {
        var issues: [ContinuityIssue] = []
        var suggestions: [ContinuitySuggestion] = []
        
        // Check critical props
        let criticalProps = propMemory.getCriticalProps(in: current.index)
        let missingProps = criticalProps.filter { prop in
            !propMemory.isPresent(prop, in: next.index) && !propMemory.wasExplicitlyRemoved(prop, before: next.index)
        }
        
        var score = 1.0
        
        for prop in missingProps {
            let propInfo = propMemory.getInfo(for: prop)
            let severity: ContinuityIssue.Severity = propInfo.criticalityScore > 0.7 ? .high : .medium
            
            issues.append(ContinuityIssue(
                type: .propMissing,
                severity: severity,
                fromSegment: current.index,
                toSegment: next.index,
                description: "Critical prop '\(prop)' missing - last seen in segment \(propInfo.lastSeenSegment)",
                affectedElement: prop,
                context: "Function: \(propInfo.function), Criticality: \(String(format: "%.1f", propInfo.criticalityScore))"
            ))
            
            suggestions.append(ContinuitySuggestion(
                type: .maintainElement,
                segmentIndex: next.index,
                description: "Maintain prop continuity",
                proposedChange: "Either show '\(prop)' in the scene or explain its absence (stored, dropped, etc.)"
            ))
            
            score -= propInfo.criticalityScore * 0.2
        }
        
        // Check for prop state changes
        let stateIssues = propMemory.validateStateTransitions(from: current.index, to: next.index)
        issues.append(contentsOf: stateIssues)
        
        score = max(0.0, score)
        
        Telemetry.shared.logEvent("prop_continuity_analyzed", properties: [
            "critical_props_count": criticalProps.count,
            "missing_props_count": missingProps.count,
            "score": score
        ])
        
        return AnalysisResult(score: score, issues: issues, suggestions: suggestions)
    }
    
    // MARK: - Transition Type Validation
    
    private func validateTransitionType(
        type: TransitionType,
        from current: PromptSegment,
        to next: PromptSegment
    ) async -> AnalysisResult {
        var issues: [ContinuityIssue] = []
        var suggestions: [ContinuitySuggestion] = []
        var score = 1.0
        
        let appropriateness = transitionTyper.evaluateAppropriateness(
            type: type,
            from: current,
            to: next
        )
        
        if appropriateness < 0.6 {
            let suggestedType = transitionTyper.suggestTransitionType(from: current, to: next)
            
            issues.append(ContinuityIssue(
                type: .transitionMismatch,
                severity: .medium,
                fromSegment: current.index,
                toSegment: next.index,
                description: "Transition type '\(type.rawValue)' may not be ideal for this scene change",
                affectedElement: type.rawValue,
                context: "Appropriateness score: \(String(format: "%.2f", appropriateness))"
            ))
            
            suggestions.append(ContinuitySuggestion(
                type: .changeTransition,
                segmentIndex: next.index,
                description: "Consider different transition",
                proposedChange: "Recommended transition: '\(suggestedType.rawValue)' - \(suggestedType.description)"
            ))
            
            score = appropriateness
        }
        
        return AnalysisResult(score: score, issues: issues, suggestions: suggestions)
    }
    
    // MARK: - Emotional Flow Analysis
    
    private func analyzeEmotionalFlow(
        from current: PromptSegment,
        to next: PromptSegment,
        context: PipelineContext
    ) async -> Double? {
        // This would integrate with StoryAnalysisModule to get emotional data
        // For now, return basic analysis
        
        let currentEmotions = extractEmotions(from: current.content)
        let nextEmotions = extractEmotions(from: next.content)
        
        let similarity = calculateEmotionalSimilarity(currentEmotions, nextEmotions)
        
        // Emotional changes should be gradual unless there's a dramatic event
        let hasDramaticEvent = next.content.contains(anyOf: ["explosion", "reveal", "death", "attack", "discover"])
        
        if !hasDramaticEvent && similarity < 0.4 {
            return 0.6 // Jarring emotional shift
        } else if similarity > 0.8 {
            return 1.0 // Smooth emotional flow
        } else {
            return 0.85 // Acceptable emotional transition
        }
    }
    
    // MARK: - Narrative Arc Validation
    
    private func validateNarrativeArcs(
        segments: [PromptSegment],
        context: PipelineContext
    ) async -> [ContinuityIssue] {
        var issues: [ContinuityIssue] = []
        
        // Check for unresolved character arcs
        let unresolvedCharacters = await characterValidator.getUnresolvedCharacters()
        for character in unresolvedCharacters {
            issues.append(ContinuityIssue(
                type: .unresolvedArc,
                severity: .medium,
                fromSegment: await characterValidator.firstAppearance(of: character) ?? 0,
                toSegment: segments.count - 1,
                description: "Character '\(character)' arc remains unresolved",
                affectedElement: character,
                context: "Character introduced but story thread not concluded"
            ))
        }
        
        // Check for abandoned props
        let abandonedProps = propMemory.getAbandonedProps()
        for prop in abandonedProps {
            let info = propMemory.getInfo(for: prop)
            if info.criticalityScore > 0.6 {
                issues.append(ContinuityIssue(
                    type: .propAbandoned,
                    severity: .low,
                    fromSegment: info.firstAppearance,
                    toSegment: info.lastSeenSegment,
                    description: "Important prop '\(prop)' introduced but not resolved",
                    affectedElement: prop,
                    context: "Last seen in segment \(info.lastSeenSegment)"
                ))
            }
        }
        
        return issues
    }
    
    // MARK: - Weighted Scoring
    
    private func calculateWeightedScore(
        validations: [ContinuityValidation],
        issues: [ContinuityIssue],
        segments: [PromptSegment],
        context: PipelineContext
    ) -> Double {
        guard !validations.isEmpty else { return 1.0 }
        
        // Base score from validations
        let baseScore = validations.map { $0.quality }.average()
        
        // Severity penalties
        let severityPenalty = issues.reduce(0.0) { total, issue in
            total + issue.severity.penaltyWeight
        }
        
        // Genre-specific weighting
        let genreWeight = context.genre?.continuityImportance ?? 1.0
        
        // Strict mode modifier
        let strictModifier = context.strictMode ?? false ? 1.2 : 1.0
        
        let finalScore = max(0.0, min(1.0, (baseScore - severityPenalty * 0.1) * genreWeight * strictModifier))
        
        Telemetry.shared.logEvent("continuity_score_calculated", properties: [
            "base_score": baseScore,
            "severity_penalty": severityPenalty,
            "final_score": finalScore
        ])
        
        return finalScore
    }
    
    // MARK: - Intelligent Suggestions
    
    private func generateIntelligentSuggestions(
        issues: [ContinuityIssue],
        segments: [PromptSegment],
        transitionAnalysis: [TransitionAnalysis],
        context: PipelineContext
    ) async -> [ContinuitySuggestion] {
        var suggestions: [ContinuitySuggestion] = []
        
        // Group issues by type
        let groupedIssues = Dictionary(grouping: issues, by: { $0.type })
        
        // Generate pattern-based suggestions
        if let locationIssues = groupedIssues[.locationJump], locationIssues.count > 2 {
            suggestions.append(ContinuitySuggestion(
                type: .globalImprovement,
                segmentIndex: 0,
                description: "Multiple location jumps detected",
                proposedChange: "Consider adding a montage sequence or time cards to smooth multiple location transitions"
            ))
        }
        
        if let toneIssues = groupedIssues[.toneShift], toneIssues.count > 2 {
            suggestions.append(ContinuitySuggestion(
                type: .globalImprovement,
                segmentIndex: 0,
                description: "Frequent tone shifts detected",
                proposedChange: "Consider establishing a more consistent emotional rhythm or adding transitional scenes"
            ))
        }
        
        // Analyze weak transition clusters
        let weakTransitions = transitionAnalysis.filter { $0.quality < 0.6 }
        if weakTransitions.count >= 2 {
            let indices = weakTransitions.map { $0.validation.fromSegment }
            suggestions.append(ContinuitySuggestion(
                type: .narrativeStructure,
                segmentIndex: indices.first ?? 0,
                description: "Multiple weak transitions in sequence",
                proposedChange: "Segments \(indices.map { String($0) }.joined(separator: ", ")) need stronger connective tissue"
            ))
        }
        
        return suggestions
    }
    
    // MARK: - Helper Methods
    
    private func calculateNarrativeCoherence(_ validations: [ContinuityValidation]) -> Double {
        guard !validations.isEmpty else { return 1.0 }
        let weights = validations.enumerated().map { index, validation in
            // Early transitions are more important for setup
            let positionWeight = 1.0 + (Double(validations.count - index) / Double(validations.count)) * 0.3
            return validation.quality * positionWeight
        }
        return weights.average()
    }
    
    private func calculateEmotionalFlowScore(_ analysis: [TransitionAnalysis]) -> Double {
        let emotionalScores = analysis.compactMap { $0.scores["emotional"] }
        return emotionalScores.isEmpty ? 0.8 : emotionalScores.average()
    }
    
    private func detectTransitionIndicators(in content: String) -> Bool {
        let indicators = [
            "cut to", "fade to", "dissolve to", "later", "meanwhile",
            "the next day", "hours later", "moments later",
            "travel", "arrive", "reach", "enter", "move to",
            "transition", "shift", "pan to"
        ]
        return indicators.contains { content.lowercased().contains($0) }
    }
    
    private func extractTransitionKeywords(from content: String) -> [String] {
        let keywords = ["cut", "fade", "dissolve", "later", "meanwhile", "next", "travel", "arrive"]
        return keywords.filter { content.lowercased().contains($0) }
    }
    
    private func extractTone(from content: String) -> Tone {
        // Simple tone extraction - integrate with TaxonomyModule for better results
        let contentLower = content.lowercased()
        
        if contentLower.contains(anyOf: ["tense", "danger", "threat", "suspense"]) {
            return .tense
        } else if contentLower.contains(anyOf: ["action", "fight", "chase", "battle"]) {
            return .action
        } else if contentLower.contains(anyOf: ["sad", "tears", "grief", "loss"]) {
            return .melancholic
        } else if contentLower.contains(anyOf: ["happy", "laugh", "joy", "celebrate"]) {
            return .joyful
        } else if contentLower.contains(anyOf: ["dark", "ominous", "sinister", "dread"]) {
            return .dark
        } else if contentLower.contains(anyOf: ["mystery", "unknown", "strange", "curious"]) {
            return .mysterious
        } else if contentLower.contains(anyOf: ["calm", "peaceful", "serene", "quiet"]) {
            return .calm
        } else {
            return .neutral
        }
    }
    
    private func extractEmotions(from content: String) -> Set<String> {
        let emotionWords = ["fear", "joy", "anger", "sadness", "hope", "tension", "relief", "anxiety"]
        return Set(emotionWords.filter { content.lowercased().contains($0) })
    }
    
    private func calculateEmotionalSimilarity(_ emotions1: Set<String>, _ emotions2: Set<String>) -> Double {
        guard !emotions1.isEmpty || !emotions2.isEmpty else { return 1.0 }
        let intersection = emotions1.intersection(emotions2).count
        let union = emotions1.union(emotions2).count
        return union > 0 ? Double(intersection) / Double(union) : 0.0
    }
    
    private func validateEmotionalConsistency(
        characters: Set<String>,
        from current: PromptSegment,
        to next: PromptSegment,
        context: PipelineContext
    ) async -> [ContinuityIssue]? {
        // Placeholder for StoryAnalysisModule integration
        // Would check if character emotional states change believably
        return nil
    }
}

// MARK: - Location Classifier

@available(iOS 15.0, *)
private class LocationClassifier {
    private var locationCache: [String: SceneLocation] = [:]
    
    func classify(_ location: String) -> SceneLocation {
        if let cached = locationCache[location] {
            return cached
        }
        
        let classified = SceneLocation.classify(location)
        locationCache[location] = classified
        return classified
    }
    
    func analyzeRelationship(from: SceneLocation, to: SceneLocation) -> LocationRelationship {
        return from.relationshipTo(to)
    }
}

// MARK: - Scene Location Types

@available(iOS 15.0, *)
private enum SceneLocation: Equatable {
    case interior(category: InteriorCategory, subcategory: String?)
    case exterior(category: ExteriorCategory, subcategory: String?)
    case vehicle(type: VehicleType, location: String?)
    case transitional
    case abstract
    
    enum InteriorCategory {
        case domestic, commercial, institutional, industrial, entertainment, other
    }
    
    enum ExteriorCategory {
        case urban, rural, natural, water, sky, space, other
    }
    
    enum VehicleType {
        case ground, air, water, space
    }
    
    static func classify(_ location: String) -> SceneLocation {
        let lower = location.lowercased()
        
        // Vehicle detection
        if lower.contains(anyOf: ["car", "truck", "bus", "taxi"]) {
            return .vehicle(type: .ground, location: location)
        }
        if lower.contains(anyOf: ["plane", "helicopter", "aircraft"]) {
            return .vehicle(type: .air, location: location)
        }
        if lower.contains(anyOf: ["boat", "ship", "submarine", "yacht"]) {
            return .vehicle(type: .water, location: location)
        }
        if lower.contains(anyOf: ["spaceship", "spacecraft", "shuttle"]) {
            return .vehicle(type: .space, location: location)
        }
        
        // Interior detection
        if lower.contains(anyOf: ["room", "house", "apartment", "kitchen", "bedroom", "office", "hallway", "lobby"]) {
            if lower.contains(anyOf: ["home", "house", "apartment", "bedroom", "kitchen"]) {
                return .interior(category: .domestic, subcategory: location)
            } else if lower.contains(anyOf: ["office", "store", "restaurant", "bar", "cafe"]) {
                return .interior(category: .commercial, subcategory: location)
            } else if lower.contains(anyOf: ["school", "hospital", "church", "museum"]) {
                return .interior(category: .institutional, subcategory: location)
            } else if lower.contains(anyOf: ["factory", "warehouse", "plant"]) {
                return .interior(category: .industrial, subcategory: location)
            } else if lower.contains(anyOf: ["theater", "cinema", "club", "arena"]) {
                return .interior(category: .entertainment, subcategory: location)
            }
            return .interior(category: .other, subcategory: location)
        }
        
        // Exterior detection
        if lower.contains(anyOf: ["street", "road", "city", "downtown", "alley", "sidewalk"]) {
            return .exterior(category: .urban, subcategory: location)
        }
        if lower.contains(anyOf: ["field", "farm", "village", "countryside"]) {
            return .exterior(category: .rural, subcategory: location)
        }
        if lower.contains(anyOf: ["forest", "mountain", "desert", "jungle", "beach", "cliff", "valley"]) {
            return .exterior(category: .natural, subcategory: location)
        }
        if lower.contains(anyOf: ["ocean", "sea", "lake", "river", "underwater"]) {
            return .exterior(category: .water, subcategory: location)
        }
        if lower.contains(anyOf: ["sky", "clouds", "air"]) {
            return .exterior(category: .sky, subcategory: location)
        }
        if lower.contains(anyOf: ["space", "orbit", "asteroid", "planet"]) {
            return .exterior(category: .space, subcategory: location)
        }
        
        // Transitional spaces
        if lower.contains(anyOf: ["doorway", "threshold", "entrance", "exit", "corridor"]) {
            return .transitional
        }
        
        // Abstract or undefined
        if lower.contains(anyOf: ["void", "dimension", "dream", "memory", "vision"]) {
            return .abstract
        }
        
        return .exterior(category: .other, subcategory: location)
    }
    
    func relationshipTo(_ other: SceneLocation) -> LocationRelationship {
        if self == other {
            return .sameLocation
        }
        
        switch (self, other) {
        case (.interior(let cat1, _), .interior(let cat2, _)):
            return cat1 == cat2 ? .adjacentLocation : .distantLocation
            
        case (.exterior(let cat1, _), .exterior(let cat2, _)):
            return cat1 == cat2 ? .adjacentLocation : .distantLocation
            
        case (.vehicle(let type1, _), .vehicle(let type2, _)):
            return type1 == type2 ? .adjacentLocation : .distantLocation
            
        case (.interior, .exterior), (.exterior, .interior):
            return .adjacentLocation
            
        case (.vehicle, .interior), (.interior, .vehicle),
             (.vehicle, .exterior), (.exterior, .vehicle):
            return .adjacentLocation
            
        default:
            return .distantLocation
        }
    }
}

// MARK: - Location Relationship

@available(iOS 15.0, *)
private enum LocationRelationship: String {
    case sameLocation = "same"
    case subLocation = "sub"
    case adjacentLocation = "adjacent"
    case distantLocation = "distant"
}

// MARK: - Tone Evolution Graph

@available(iOS 15.0, *)
private actor ToneEvolutionGraph {
    private var adjacencyMap: [Tone: Set<Tone>] = [:]
    private var genreAdjustments: [String: [Tone: Set<Tone>]] = [:]
    
    init() {
        buildDefaultAdjacencyMap()
    }
    
    func configureForGenre(_ genre: String) {
        // Genre-specific tone flow patterns
        // Could be loaded from TaxonomyModule
    }
    
    func areAdjacent(from: Tone, to: Tone) -> Bool {
        return adjacencyMap[from]?.contains(to) ?? false
    }
    
    func distance(from: Tone, to: Tone) -> Int {
        // BFS to find shortest path in tone graph
        if from == to { return 0 }
        if adjacencyMap[from]?.contains(to) == true { return 1 }
        
        var visited: Set<Tone> = [from]
        var queue: [(Tone, Int)] = [(from, 0)]
        
        while !queue.isEmpty {
            let (current, dist) = queue.removeFirst()
            
            if let neighbors = adjacencyMap[current] {
                for neighbor in neighbors {
                    if neighbor == to {
                        return dist + 1
                    }
                    if !visited.contains(neighbor) {
                        visited.insert(neighbor)
                        queue.append((neighbor, dist + 1))
                    }
                }
            }
        }
        
        return 5 // Max distance if not connected
    }
    
    func suggestBridgeTone(from: Tone, to: Tone) -> Tone? {
        // Find intermediate tone that connects both
        guard let fromNeighbors = adjacencyMap[from],
              let toNeighbors = adjacencyMap[to] else {
            return nil
        }
        
        let intersection = fromNeighbors.intersection(toNeighbors)
        return intersection.first
    }
    
    func detectRepeatedShifts(in tones: [Tone]) -> Bool {
        guard tones.count >= 4 else { return false }
        
        // Detect whiplash pattern (A -> B -> A -> B)
        for i in 0..<tones.count - 3 {
            if tones[i] == tones[i+2] && tones[i+1] == tones[i+3] && tones[i] != tones[i+1] {
                return true
            }
        }
        
        return false
    }
    
    private func buildDefaultAdjacencyMap() {
        adjacencyMap = [
            .neutral: [.calm, .mysterious, .joyful, .tense],
            .calm: [.neutral, .joyful, .mysterious, .melancholic],
            .joyful: [.calm, .neutral, .action],
            .action: [.tense, .joyful, .neutral],
            .tense: [.action, .dark, .neutral],
            .dark: [.tense, .melancholic, .mysterious],
            .melancholic: [.dark, .calm, .neutral],
            .mysterious: [.neutral, .dark, .tense, .calm]
        ]
    }
}

// MARK: - Tone Enum

@available(iOS 15.0, *)
private enum Tone: String, Hashable {
    case neutral, calm, joyful, action, tense, dark, melancholic, mysterious
}

// MARK: - Prop Continuity Memory

@available(iOS 15.0, *)
private class PropContinuityMemory {
    private var props: [String: PropInfo] = [:]
    private var segmentProps: [Int: Set<String>] = [:]
    
    func reset() {
        props.removeAll()
        segmentProps.removeAll()
    }
    
    func registerProps(_ propList: [String], in segment: Int) {
        segmentProps[segment] = Set(propList)
        
        for prop in propList {
            if props[prop] == nil {
                props[prop] = PropInfo(
                    name: prop,
                    firstAppearance: segment,
                    criticalityScore: calculateCriticality(prop)
                )
            }
            props[prop]?.appearances.insert(segment)
            props[prop]?.lastSeenSegment = segment
        }
    }
    
    func getCriticalProps(in segment: Int) -> [String] {
        return segmentProps[segment]?.filter { props[$0]?.criticalityScore ?? 0 > 0.5 } ?? []
    }
    
    func isPresent(_ prop: String, in segment: Int) -> Bool {
        return segmentProps[segment]?.contains(prop) ?? false
    }
    
    func wasExplicitlyRemoved(_ prop: String, before segment: Int) -> Bool {
        // Could check segment content for removal keywords
        // Placeholder implementation
        return false
    }
    
    func getInfo(for prop: String) -> PropInfo {
        return props[prop] ?? PropInfo(name: prop, firstAppearance: 0, criticalityScore: 0.5)
    }
    
    func validateStateTransitions(from: Int, to: Int) -> [ContinuityIssue] {
        // Check if props changed state unrealistically
        // Placeholder implementation
        return []
    }
    
    func getAbandonedProps() -> [String] {
        return props.filter { $0.value.criticalityScore > 0.6 && $0.value.appearances.count == 1 }.map { $0.key }
    }
    
    private func calculateCriticality(_ prop: String) -> Double {
        let criticalKeywords = ["weapon", "key", "device", "document", "artifact", "ring", "map", "evidence"]
        let lower = prop.lowercased()
        
        for keyword in criticalKeywords {
            if lower.contains(keyword) {
                return 0.9
            }
        }
        
        if lower.contains(anyOf: ["phone", "letter", "photo", "note"]) {
            return 0.7
        }
        
        return 0.4
    }
}

// MARK: - Prop Info

@available(iOS 15.0, *)
private struct PropInfo {
    let name: String
    let firstAppearance: Int
    var lastSeenSegment: Int
    var appearances: Set<Int> = []
    let criticalityScore: Double
    var function: String = "unknown"
    
    init(name: String, firstAppearance: Int, criticalityScore: Double) {
        self.name = name
        self.firstAppearance = firstAppearance
        self.lastSeenSegment = firstAppearance
        self.criticalityScore = criticalityScore
        self.appearances = [firstAppearance]
    }
}

// MARK: - Character Arc Validator

@available(iOS 15.0, *)
private actor CharacterArcValidator {
    private var characters: [String: CharacterInfo] = [:]
    
    func reset() {
        characters.removeAll()
    }
    
    func registerCharacters(_ characterList: [String], in segment: Int, content: String) {
        for character in characterList {
            if characters[character] == nil {
                characters[character] = CharacterInfo(name: character, firstAppearance: segment)
            }
            characters[character]?.appearances.insert(segment)
            characters[character]?.lastSeen = segment
            
            // Track role mentions
            if content.lowercased().contains(character.lowercased()) {
                characters[character]?.activeMentions.insert(segment)
            }
        }
    }
    
    func validateDisappearance(
        character: String,
        fromSegment: Int,
        toSegment: Int,
        context: String
    ) -> CharacterValidation {
        let hasExitKeywords = context.lowercased().contains(anyOf: ["exit", "leave", "depart", "gone"])
        let hasLocationChange = context.lowercased().contains(anyOf: ["cut to", "meanwhile", "elsewhere"])
        
        if hasExitKeywords || hasLocationChange {
            return CharacterValidation(issue: nil, suggestion: nil)
        }
        
        let info = characters[character]
        let isMinorCharacter = (info?.appearances.count ?? 0) <= 2
        
        let severity: ContinuityIssue.Severity = isMinorCharacter ? .low : .medium
        
        let issue = ContinuityIssue(
            type: .characterDisappeared,
            severity: severity,
            fromSegment: fromSegment,
            toSegment: toSegment,
            description: "Character '\(character)' disappears without explanation",
            affectedElement: character,
            context: "Consider adding exit action or location change"
        )
        
        let suggestion = ContinuitySuggestion(
            type: .clarifyAction,
            segmentIndex: toSegment,
            description: "Clarify character exit",
            proposedChange: "Add '\(character) exits' or establish location change"
        )
        
        return CharacterValidation(issue: issue, suggestion: suggestion)
    }
    
    func validateAppearance(
        character: String,
        inSegment: Int,
        context: String,
        previousSegments: [PromptSegment]
    ) -> CharacterValidation {
        let hasEntryKeywords = context.lowercased().contains(anyOf: ["enter", "arrive", "appear", "walks in"])
        let hasIntroduction = context.lowercased().contains(anyOf: ["meet", "introduce", "new"])
        
        if hasEntryKeywords || hasIntroduction {
            return CharacterValidation(issue: nil, suggestion: nil)
        }
        
        let issue = ContinuityIssue(
            type: .characterAppeared,
            severity: .medium,
            fromSegment: inSegment - 1,
            toSegment: inSegment,
            description: "Character '\(character)' appears without introduction or entry",
            affectedElement: character,
            context: "Consider adding entrance or introduction"
        )
        
        let suggestion = ContinuitySuggestion(
            type: .clarifyAction,
            segmentIndex: inSegment,
            description: "Introduce character properly",
            proposedChange: "Add '\(character) enters' or provide introduction context"
        )
        
        return CharacterValidation(issue: issue, suggestion: suggestion)
    }
    
    func getUnresolvedCharacters() -> [String] {
        // Characters that appeared significantly but don't have resolution
        return characters.filter { $0.value.appearances.count >= 3 && !$0.value.hasResolution }.map { $0.key }
    }
    
    func firstAppearance(of character: String) -> Int? {
        return characters[character]?.firstAppearance
    }
}

// MARK: - Character Info

@available(iOS 15.0, *)
private struct CharacterInfo {
    let name: String
    let firstAppearance: Int
    var lastSeen: Int
    var appearances: Set<Int> = []
    var activeMentions: Set<Int> = []
    var hasResolution: Bool = false
    
    init(name: String, firstAppearance: Int) {
        self.name = name
        self.firstAppearance = firstAppearance
        self.lastSeen = firstAppearance
        self.appearances = [firstAppearance]
    }
}

// MARK: - Character Validation Result

@available(iOS 15.0, *)
private struct CharacterValidation {
    let issue: ContinuityIssue?
    let suggestion: ContinuitySuggestion?
}

// MARK: - Transition Typer

@available(iOS 15.0, *)
private class TransitionTyper {
    func detectTransitionType(from: PromptSegment, to: PromptSegment) -> TransitionType {
        let content = to.content.lowercased()
        
        if content.contains(anyOf: ["cut to", "smash cut"]) {
            return .cut
        }
        if content.contains(anyOf: ["fade to", "fade in", "fade out"]) {
            return .fade
        }
        if content.contains(anyOf: ["dissolve", "blend"]) {
            return .dissolve
        }
        if content.contains(anyOf: ["montage", "series of shots"]) {
            return .montage
        }
        if content.contains(anyOf: ["wipe", "swipe"]) {
            return .wipe
        }
        if content.contains(anyOf: ["match cut", "match on"]) {
            return .matchCut
        }
        if content.contains(anyOf: ["jump cut", "sudden"]) {
            return .jumpCut
        }
        if content.contains(anyOf: ["voiceover", "narration continues"]) {
            return .voiceoverBridge
        }
        
        // Default: infer from context
        if from.location == to.location {
            return .cut
        }
        if abs(extractTime(from: from.content) - extractTime(from: to.content)) > 60 {
            return .fade
        }
        
        return .cut
    }
    
    func evaluateAppropriateness(type: TransitionType, from: PromptSegment, to: PromptSegment) -> Double {
        switch type {
        case .cut:
            // Cuts work for most transitions
            return 0.8
            
        case .fade:
            // Fades good for time/location changes
            let hasTimeChange = to.content.lowercased().contains(anyOf: ["later", "next", "morning", "night"])
            let hasLocationChange = from.location != to.location
            return (hasTimeChange || hasLocationChange) ? 0.9 : 0.5
            
        case .dissolve:
            // Dissolves good for thematic connections
            let toneSimilar = extractTone(from: from.content) == extractTone(from: to.content)
            return toneSimilar ? 0.85 : 0.6
            
        case .montage:
            // Montages need multiple related actions
            return 0.7
            
        case .matchCut:
            // Match cuts need visual/thematic parallel
            return 0.75
            
        case .jumpCut:
            // Jump cuts good for energy/disorientation
            return 0.7
            
        case .voiceoverBridge:
            // Good for narrative continuity
            return 0.8
            
        default:
            return 0.7
        }
    }
    
    func suggestTransitionType(from: PromptSegment, to: PromptSegment) -> TransitionType {
        let hasTimeChange = to.content.lowercased().contains(anyOf: ["later", "next", "morning", "night"])
        let hasLocationChange = from.location != to.location
        let toneDifference = extractTone(from: from.content) != extractTone(from: to.content)
        
        if hasTimeChange && hasLocationChange {
            return .fade
        }
        if toneDifference {
            return .dissolve
        }
        if hasLocationChange {
            return .cut
        }
        
        return .cut
    }
    
    private func extractTime(from content: String) -> Int {
        // Extract time hints (simplified)
        if content.lowercased().contains("night") { return 22 }
        if content.lowercased().contains("morning") { return 8 }
        if content.lowercased().contains("afternoon") { return 14 }
        return 12
    }
    
    private func extractTone(from content: String) -> Tone {
        let contentLower = content.lowercased()
        if contentLower.contains(anyOf: ["tense", "danger"]) { return .tense }
        if contentLower.contains(anyOf: ["action", "fight"]) { return .action }
        if contentLower.contains(anyOf: ["sad", "tears"]) { return .melancholic }
        if contentLower.contains(anyOf: ["happy", "joy"]) { return .joyful }
        if contentLower.contains(anyOf: ["dark", "ominous"]) { return .dark }
        return .neutral
    }
}

// MARK: - Transition Types

@available(iOS 15.0, *)
public enum TransitionType: String, Sendable, Codable {
    case cut = "cut"
    case fade = "fade"
    case dissolve = "dissolve"
    case wipe = "wipe"
    case montage = "montage"
    case matchCut = "match_cut"
    case jumpCut = "jump_cut"
    case voiceoverBridge = "voiceover_bridge"
    case smashCut = "smash_cut"
    case unknown = "unknown"
    
    var description: String {
        switch self {
        case .cut: return "Direct cut between scenes"
        case .fade: return "Fade transition, good for time/location changes"
        case .dissolve: return "Dissolve for thematic connections"
        case .wipe: return "Wipe transition for dynamic shifts"
        case .montage: return "Montage sequence for time compression"
        case .matchCut: return "Match cut for visual/thematic parallels"
        case .jumpCut: return "Jump cut for energy or disorientation"
        case .voiceoverBridge: return "Voiceover bridge for narrative continuity"
        case .smashCut: return "Smash cut for dramatic contrast"
        case .unknown: return "Unspecified transition"
        }
    }
}

// MARK: - Analysis Result

@available(iOS 15.0, *)
private struct AnalysisResult {
    let score: Double
    let issues: [ContinuityIssue]
    let suggestions: [ContinuitySuggestion]
}

// MARK: - Transition Record

@available(iOS 15.0, *)
private struct TransitionRecord {
    let fromIndex: Int
    let toIndex: Int
    let analysis: TransitionAnalysis
}

// MARK: - Transition Analysis

@available(iOS 15.0, *)
public struct TransitionAnalysis: Sendable {
    public let validation: ContinuityValidation
    public let issues: [ContinuityIssue]
    public let suggestions: [ContinuitySuggestion]
    public let transitionType: TransitionType
    public let quality: Double
    public let scores: [String: Double]
}

// MARK: - Input/Output Types

@available(iOS 15.0, *)
public struct ContinuityInput: Sendable {
    public let segments: [PromptSegment]
    public let strictMode: Bool
    
    public init(segments: [PromptSegment], strictMode: Bool = false) {
        self.segments = segments
        self.strictMode = strictMode
    }
}

@available(iOS 15.0, *)
public struct ContinuityOutput: Sendable {
    public let segments: [PromptSegment]
    public let validations: [ContinuityValidation]
    public let issues: [ContinuityIssue]
    public let suggestions: [ContinuitySuggestion]
    public let continuityScore: Double
    public let transitionAnalysis: [TransitionAnalysis]
    public let metadata: ContinuityMetadata
}

// MARK: - Supporting Types

@available(iOS 15.0, *)
public struct ContinuityValidation: Sendable, Identifiable {
    public let id = UUID()
    public let segmentIndex: Int
    public let fromSegment: Int
    public let toSegment: Int
    public let isValid: Bool
    public let quality: Double
    public let issues: [ContinuityIssue]
    public var content: String? = nil
}

@available(iOS 15.0, *)
public struct ContinuityIssue: Sendable, Identifiable {
    public let id = UUID()
    public let type: IssueType
    public let severity: Severity
    public let fromSegment: Int
    public let toSegment: Int
    public let description: String
    public let affectedElement: String?
    public let context: String?
    
    public init(type: IssueType, severity: Severity, fromSegment: Int, toSegment: Int, description: String, affectedElement: String?, context: String? = nil) {
        self.type = type
        self.severity = severity
        self.fromSegment = fromSegment
        self.toSegment = toSegment
        self.description = description
        self.affectedElement = affectedElement
        self.context = context
    }
    
    public enum IssueType: String, Sendable {
        case characterDisappeared = "character_disappeared"
        case characterAppeared = "character_appeared"
        case locationJump = "location_jump"
        case propMissing = "prop_missing"
        case propAbandoned = "prop_abandoned"
        case toneShift = "tone_shift"
        case timeInconsistency = "time_inconsistency"
        case transitionMismatch = "transition_mismatch"
        case unresolvedArc = "unresolved_arc"
    }
    
    public enum Severity: String, Sendable {
        case low = "low"
        case medium = "medium"
        case high = "high"
        case critical = "critical"
        
        var penaltyWeight: Double {
            switch self {
            case .low: return 0.5
            case .medium: return 1.0
            case .high: return 2.0
            case .critical: return 3.0
            }
        }
    }
}

@available(iOS 15.0, *)
public struct ContinuitySuggestion: Sendable, Identifiable {
    public let id = UUID()
    public let type: SuggestionType
    public let segmentIndex: Int
    public let description: String
    public let proposedChange: String
    
    public enum SuggestionType: String, Sendable {
        case addTransition = "add_transition"
        case smoothTransition = "smooth_transition"
        case changeTransition = "change_transition"
        case clarifyAction = "clarify_action"
        case maintainElement = "maintain_element"
        case globalImprovement = "global_improvement"
        case narrativeStructure = "narrative_structure"
    }
}

@available(iOS 15.0, *)
public struct ContinuityMetadata: Sendable {
    public let totalSegments: Int
    public let validTransitions: Int
    public let issueCount: Int
    public let suggestionCount: Int
    public let averageTransitionQuality: Double
    public let narrativeCoherence: Double
    public let emotionalFlowScore: Double
}

// SwiftUI views moved to DirectorStudioUI module

// SwiftUI views moved to DirectorStudioUI module

// SwiftUI views moved to DirectorStudioUI module

// MARK: - Utility Extensions

extension String {
    func contains(anyOf strings: [String]) -> Bool {
        return strings.contains { self.contains($0) }
    }
}

extension Array where Element == Double {
    func average() -> Double {
        guard !isEmpty else { return 0.0 }
        return reduce(0.0, +) / Double(count)
    }
}

extension PipelineContext {
    var genre: String? {
        // Would be populated from TaxonomyModule
        return nil
    }
    
    var strictMode: Bool? {
        return nil
    }
}

extension String {
    var continuityImportance: Double {
        // Genre-specific continuity importance
        // Could be loaded from configuration
        return 1.0
    }
}

// MARK: - Telemetry (Placeholder)

// Telemetry is handled by Telemetry.swift

// MARK: - Loggers (Placeholder)

// Logging is handled by Telemetry.swift

// Placeholder types removed - using types from Core/PipelineProtocols.swift and DataModels.swift