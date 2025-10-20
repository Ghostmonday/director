//
//  StoryAnalysisView.swift
//  DirectorStudioUI
//
//  Created by DirectorStudio on $(date)
//  Copyright © 2025 DirectorStudio. All rights reserved.
//

import SwiftUI

/// Story Analysis Module UI - Multi-tab analysis interface
struct StoryAnalysisView: View {
    @State private var storyText: String = ""
    @State private var isProcessing: Bool = false
    @State private var analysisResult: GUIStoryAnalysis?
    @State private var selectedTab: AnalysisTab = .overview
    @State private var errorMessage: String?
    @State private var currentPhase: Int = 0
    @State private var totalPhases: Int = 8
    
    private let guiAbstraction = GUIAbstraction()
    
    enum AnalysisTab: String, CaseIterable {
        case overview = "Overview"
        case characters = "Characters"
        case structure = "Structure"
        case themes = "Themes"
        case emotions = "Emotions"
        case relationships = "Relationships"
        
        var icon: String {
            switch self {
            case .overview: return "doc.text"
            case .characters: return "person.2"
            case .structure: return "chart.bar"
            case .themes: return "lightbulb"
            case .emotions: return "heart"
            case .relationships: return "network"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if analysisResult == nil {
                    // Input View
                    inputView
                } else {
                    // Results View
                    resultsView
                }
            }
            .navigationTitle("Story Analysis")
        }
    }
    
    // MARK: - Input View
    
    private var inputView: some View {
        VStack(spacing: 20) {
            // Header
            headerSection
            
            // Story Input
            storyInputSection
            
            // Analyze Button
            analyzeButtonSection
            
            // Loading State
            if isProcessing {
                loadingSection
            }
            
            // Error Message
            if let errorMessage = errorMessage {
                errorSection(errorMessage)
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Results View
    
    private var resultsView: some View {
        VStack(spacing: 0) {
            // Tab Picker
            tabPickerSection
            
            // Tab Content
            tabContentSection
            
            // Export Button
            exportButtonSection
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Analyze your story")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Get comprehensive insights into your story's structure, characters, themes, and emotional arc")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Story Input Section
    
    private var storyInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Story")
                .font(.headline)
            
            TextEditor(text: $storyText)
                .frame(minHeight: 300)
                .padding(8)
                .background(Color.systemGray6)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.systemGray4, lineWidth: 1)
                )
            
            if storyText.isEmpty {
                Text("Enter your story for comprehensive analysis...")
                    .foregroundColor(.secondary)
                    .font(.caption)
            } else {
                Text("\(storyText.count) characters")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
    }
    
    // MARK: - Analyze Button Section
    
    private var analyzeButtonSection: some View {
        Button(action: analyzeStory) {
            HStack {
                if isProcessing {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "brain.head.profile")
                }
                Text(isProcessing ? "Analyzing..." : "Analyze Story")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(canAnalyze ? Color.blue : Color.systemGray4)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .disabled(!canAnalyze || isProcessing)
        .animation(.easeInOut(duration: 0.2), value: isProcessing)
    }
    
    // MARK: - Loading Section
    
    private var loadingSection: some View {
        VStack(spacing: 16) {
            // Phase Progress
            VStack(spacing: 8) {
                Text("Phase \(currentPhase) of \(totalPhases)")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Text(phaseDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Progress Bar
            ProgressView(value: Double(currentPhase), total: Double(totalPhases))
                .progressViewStyle(LinearProgressViewStyle())
                .scaleEffect(1.0, anchor: .center)
            
            // Processing Animation
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                        .scaleEffect(isProcessing ? 1.0 : 0.5)
                        .animation(
                            .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                            value: isProcessing
                        )
                }
            }
        }
        .padding()
        .background(Color.systemGray6)
        .cornerRadius(8)
    }
    
    // MARK: - Tab Picker Section
    
    private var tabPickerSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(AnalysisTab.allCases, id: \.self) { tab in
                    Button { selectedTab = tab } label: {
                        VStack(spacing: 4) {
                            Image(systemName: tab.icon)
                                .font(.title2)
                            
                            Text(tab.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(selectedTab == tab ? .blue : .secondary)
                        .frame(width: 80, height: 60)
                        .background(
                            selectedTab == tab ? Color.blue.opacity(0.1) : Color.clear
                        )
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color.systemBackground)
    }
    
    // MARK: - Tab Content Section
    
    private var tabContentSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                switch selectedTab {
                case .overview:
                    overviewContent
                case .characters:
                    charactersContent
                case .structure:
                    structureContent
                case .themes:
                    themesContent
                case .emotions:
                    emotionsContent
                case .relationships:
                    relationshipsContent
                }
            }
            .padding()
        }
    }
    
    // MARK: - Export Button Section
    
    private var exportButtonSection: some View {
        Button(action: exportAnalysis) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Export Analysis")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.systemGray6)
            .foregroundColor(.primary)
            .cornerRadius(10)
        }
        .padding()
    }
    
    // MARK: - Tab Content Views
    
    private var overviewContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let analysis = analysisResult {
                // Genre & Target Audience
                VStack(alignment: .leading, spacing: 8) {
                    Text("Genre & Audience")
                        .font(.headline)
                    
                    HStack {
                        Text("Genre:")
                            .fontWeight(.semibold)
                        Text(analysis.genre)
                        Spacer()
                    }
                    
                    HStack {
                        Text("Target Audience:")
                            .fontWeight(.semibold)
                        Text(analysis.targetAudience)
                        Spacer()
                    }
                }
                
                // Estimated Duration
                VStack(alignment: .leading, spacing: 8) {
                    Text("Duration Analysis")
                        .font(.headline)
                    
                    HStack {
                        Text("Estimated Duration:")
                            .fontWeight(.semibold)
                        Text("\(analysis.estimatedDuration) seconds")
                        Spacer()
                    }
                    
                    HStack {
                        Text("Complexity Score:")
                            .fontWeight(.semibold)
                        Text("\(analysis.complexityScore, specifier: "%.1f")/10")
                        Spacer()
                    }
                }
                
                // Narrative Arc
                VStack(alignment: .leading, spacing: 8) {
                    Text("Narrative Arc")
                        .font(.headline)
                    
                    Text(analysis.narrativeArc)
                        .font(.body)
                        .padding()
                        .background(Color.systemGray6)
                        .cornerRadius(8)
                }
            }
        }
    }
    
    private var charactersContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let analysis = analysisResult {
                Text("Character Analysis")
                    .font(.headline)
                
                Text(analysis.characterDevelopment)
                    .font(.body)
                    .padding()
                    .background(Color.systemGray6)
                    .cornerRadius(8)
            }
        }
    }
    
    private var structureContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let analysis = analysisResult {
                Text("Story Structure")
                    .font(.headline)
                
                Text(analysis.narrativeArc)
                    .font(.body)
                    .padding()
                    .background(Color.systemGray6)
                    .cornerRadius(8)
            }
        }
    }
    
    private var themesContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let analysis = analysisResult {
                Text("Themes")
                    .font(.headline)
                
                Text(analysis.themes)
                    .font(.body)
                    .padding()
                    .background(Color.systemGray6)
                    .cornerRadius(8)
            }
        }
    }
    
    private var emotionsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let analysis = analysisResult {
                Text("Emotional Arc")
                    .font(.headline)
                
                Text(analysis.emotionalCurve)
                    .font(.body)
                    .padding()
                    .background(Color.systemGray6)
                    .cornerRadius(8)
            }
        }
    }
    
    private var relationshipsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let analysis = analysisResult {
                Text("Character Relationships")
                    .font(.headline)
                
                Text("Relationship analysis would be displayed here")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color.systemGray6)
                    .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Error Section
    
    private func errorSection(_ message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.red)
            
            Spacer()
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
    
    // MARK: - Computed Properties
    
    private var canAnalyze: Bool {
        !storyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var phaseDescription: String {
        let phases = [
            "Analyzing text structure...",
            "Identifying characters...",
            "Mapping locations...",
            "Breaking down scenes...",
            "Analyzing dialogue...",
            "Detecting themes...",
            "Calculating emotional curve...",
            "Building relationship graph..."
        ]
        
        guard currentPhase > 0 && currentPhase <= phases.count else {
            return "Preparing analysis..."
        }
        
        return phases[currentPhase - 1]
    }
    
    // MARK: - Actions
    
    private func analyzeStory() {
        guard canAnalyze else {
            errorMessage = "Please enter a story to analyze"
            return
        }
        
        isProcessing = true
        errorMessage = nil
        analysisResult = nil
        currentPhase = 0
        
        Task {
            do {
                // Simulate phase progress
                for phase in 1...totalPhases {
                    await MainActor.run {
                        currentPhase = phase
                    }
                    try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds per phase
                }
                
                let result = try await guiAbstraction.analyzeStory(story: storyText)
                
                await MainActor.run {
                    analysisResult = result
                    isProcessing = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isProcessing = false
                    currentPhase = 0
                }
            }
        }
    }
    
    private func exportAnalysis() {
        guard let analysis = analysisResult else { return }
        
        // Create JSON representation
        let exportData: [String: Any] = [
            "genre": analysis.genre,
            "targetAudience": analysis.targetAudience,
            "estimatedDuration": analysis.estimatedDuration,
            "complexityScore": analysis.complexityScore,
            "narrativeArc": analysis.narrativeArc,
            "emotionalCurve": analysis.emotionalCurve,
            "characterDevelopment": analysis.characterDevelopment,
            "themes": analysis.themes
        ]
        
        // Convert to JSON string
        if let jsonData = try? JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            
            // Copy to clipboard
            #if os(iOS)
            UIPasteboard.general.string = jsonString
            #endif
            // Show feedback
        }
    }
}

/// Preview
struct StoryAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        StoryAnalysisView()
    }
}
