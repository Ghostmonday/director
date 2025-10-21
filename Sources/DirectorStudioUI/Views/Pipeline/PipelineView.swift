//
//  PipelineView.swift
//  DirectorStudioUI
//
//  Created by DirectorStudio on $(date)
//  Copyright © 2025 DirectorStudio. All rights reserved.
//

import SwiftUI
import DirectorStudio

/// Pipeline Orchestrator UI - Complete pipeline configuration and execution
struct PipelineView: View {
    @State private var storyInput: String = ""
    @State private var isProcessing: Bool = false
    @State private var currentModule: String = ""
    @State private var pipelineProgress: Double = 0.0
    @State private var estimatedTimeRemaining: String = ""
    @State private var liveResults: [String: Any] = [:]
    @State private var showResults: Bool = false
    @State private var errorMessage: String?
    @State private var moduleSettings: ModuleSettings = ModuleSettings()
    @State private var showAdvancedSettings: Bool = false
    
    private let guiAbstraction = GUIAbstraction()
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    // 🚨 UX FIX #3: Context Bar - Shows current story/project context
                    ContextBar(
                        storyPreview: storyInput,
                        segmentCount: 0, // Placeholder: Will integrate with AppState
                        projectName: nil, // Placeholder: Will integrate with AppState
                        onShowDetails: { /* Future: Show project details sheet */ }
                    )
                    
                    if !isProcessing {
                        // Configuration View
                        configurationView
                    } else {
                        // Processing View
                        processingView
                    }
                }
                
                // 🚨 UX FIX #1: Floating Action Button
                floatingActionButton
            }
            .navigationTitle("Pipeline Orchestrator")
            .toolbar {
                // 🚨 UX FIX #4: Credits Indicator
                ToolbarItem(placement: .topBarTrailing) {
                    CreditsIndicator(
                        currentBalance: 100, // Placeholder: Will integrate with MonetizationManager
                        estimatedCost: calculateEstimatedCost(),
                        onTap: { /* Future: Navigate to credits store tab */ }
                    )
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    if isProcessing {
                        Button("Cancel") {
                            cancelProcessing()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
    }
    
    // MARK: - Configuration View
    
    private var configurationView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection
                
                // Story Input
                storyInputSection
                
                // Module Configuration
                moduleConfigurationSection
                
                // Advanced Settings
                if showAdvancedSettings {
                    advancedSettingsSection
                }
                
                // Run Pipeline Button
                runPipelineButtonSection
                
                // Export Options
                exportOptionsSection
            }
            .padding()
        }
    }
    
    // MARK: - Processing View
    
    private var processingView: some View {
        VStack(spacing: 20) {
            // Progress Overview
            progressOverviewSection
            
            // Current Module
            currentModuleSection
            
            // Live Results Preview
            if !liveResults.isEmpty {
                liveResultsSection
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Story-to-Video Pipeline")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Configure and run the complete pipeline to transform your story into a video")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Story Input Section
    
    // 🚨 UX FIX #2: Enhanced Text Editor with character/word count
    private var storyInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Story Input")
                .font(.headline)
            
            EnhancedTextEditor(
                text: $storyInput,
                placeholder: "Enter your story here to begin the pipeline...",
                minHeight: 200,
                    onAIEnhance: {
                        // Future: AI enhancement integration
                        // TODO: Implement AI story enhancement
                    }
            )
        }
    }
    
    // MARK: - Module Configuration Section
    
    private var moduleConfigurationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Pipeline Configuration")
                    .font(.headline)
                
                Spacer()
                
                Button("Advanced") {
                    showAdvancedSettings.toggle()
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            VStack(spacing: 12) {
                // Segmentation Module
                ModuleToggleView(
                    title: "Story Segmentation",
                    description: "Break story into video segments",
                    isEnabled: $moduleSettings.segmentationEnabled
                )
                
                // Story Analysis Module
                ModuleToggleView(
                    title: "Story Analysis",
                    description: "Analyze narrative structure and themes",
                    isEnabled: $moduleSettings.storyAnalysisEnabled
                )
                
                // Rewording Module
                ModuleToggleView(
                    title: "Text Rewording",
                    description: "Transform text for video narration",
                    isEnabled: $moduleSettings.rewordingEnabled
                )
                
                // Taxonomy Module
                ModuleToggleView(
                    title: "Cinematic Enrichment",
                    description: "Add cinematic metadata and shot types",
                    isEnabled: $moduleSettings.taxonomyEnabled
                )
                
                // Continuity Module
                ModuleToggleView(
                    title: "Continuity Validation",
                    description: "Ensure visual and narrative continuity",
                    isEnabled: $moduleSettings.continuityEnabled
                )
                
                // Video Generation Module
                ModuleToggleView(
                    title: "Video Generation",
                    description: "Generate video clips from segments",
                    isEnabled: $moduleSettings.videoGenerationEnabled
                )
                
                // Video Assembly Module
                ModuleToggleView(
                    title: "Video Assembly",
                    description: "Combine clips into final video",
                    isEnabled: $moduleSettings.videoAssemblyEnabled
                )
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(UIColor.systemGray4), lineWidth: 1)
        )
    }
    
    // MARK: - Advanced Settings Section
    
    private var advancedSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Advanced Settings")
                .font(.headline)
            
            VStack(spacing: 12) {
                // Target Duration
                VStack(alignment: .leading, spacing: 8) {
                    Text("Target Duration: \(Int(moduleSettings.targetDuration)) seconds")
                        .font(.subheadline)
                    
                    Slider(value: $moduleSettings.targetDuration, in: 30...600, step: 30)
                        .accentColor(.blue)
                }
                
                // Video Quality
                VStack(alignment: .leading, spacing: 8) {
                    Text("Video Quality")
                        .font(.subheadline)
                    
                    Picker("Quality", selection: $moduleSettings.videoQuality) {
                        Text("Low").tag(VideoQuality.low)
                        Text("Medium").tag(VideoQuality.medium)
                        Text("High").tag(VideoQuality.high)
                        Text("Ultra").tag(VideoQuality.ultra)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Processing Mode
                VStack(alignment: .leading, spacing: 8) {
                    Text("Processing Mode")
                        .font(.subheadline)
                    
                    Picker("Mode", selection: $moduleSettings.processingMode) {
                        Text("Fast").tag(ProcessingMode.fast)
                        Text("Balanced").tag(ProcessingMode.balanced)
                        Text("Quality").tag(ProcessingMode.quality)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(8)
    }
    
    // MARK: - Run Pipeline Button Section
    
    private var runPipelineButtonSection: some View {
        VStack(spacing: 12) {
            Button(action: runPipeline) {
                HStack {
                    Image(systemName: "play.circle.fill")
                    Text("Run Pipeline")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(canRunPipeline ? Color.blue : Color(UIColor.systemGray4))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(!canRunPipeline)
            
            if !canRunPipeline {
                Text("Please enter a story and enable at least one module")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Export Options Section
    
    private var exportOptionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Export Options")
                .font(.headline)
            
            HStack(spacing: 12) {
                Button(action: exportAsJSON) {
                    HStack {
                        Image(systemName: "doc.text")
                        Text("Export JSON")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .foregroundColor(.primary)
                    .cornerRadius(8)
                }
                
                Button(action: exportAsPDF) {
                    HStack {
                        Image(systemName: "doc.richtext")
                        Text("Export PDF")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .foregroundColor(.primary)
                    .cornerRadius(8)
                }
            }
        }
    }
    
    // MARK: - Progress Overview Section
    
    private var progressOverviewSection: some View {
        VStack(spacing: 16) {
            Text("Pipeline Progress")
                .font(.title2)
                .fontWeight(.semibold)
            
            // Overall Progress Bar
            VStack(spacing: 8) {
                ProgressView(value: pipelineProgress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .scaleEffect(1.2, anchor: .center)
                
                Text("\(Int(pipelineProgress * 100))% Complete")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            
            // Estimated Time
            if !estimatedTimeRemaining.isEmpty {
                Text("Estimated time remaining: \(estimatedTimeRemaining)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(8)
    }
    
    // MARK: - Current Module Section
    
    private var currentModuleSection: some View {
        VStack(spacing: 12) {
            Text("Current Module")
                .font(.headline)
            
            if !currentModule.isEmpty {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    
                    Text(currentModule)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(8)
            }
        }
    }
    
    // MARK: - Live Results Section
    
    private var liveResultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Live Results")
                .font(.headline)
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(liveResults.keys.sorted(), id: \.self) { key in
                        if let value = liveResults[key] {
                            HStack {
                                Text(key)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                Text(String(describing: value))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(6)
                        }
                    }
                }
            }
            .frame(maxHeight: 200)
        }
    }
    
    // MARK: - Computed Properties
    
    private var canRunPipeline: Bool {
        !storyInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (moduleSettings.segmentationEnabled ||
         moduleSettings.storyAnalysisEnabled ||
         moduleSettings.rewordingEnabled ||
         moduleSettings.taxonomyEnabled ||
         moduleSettings.continuityEnabled ||
         moduleSettings.videoGenerationEnabled ||
         moduleSettings.videoAssemblyEnabled)
    }
    
    // MARK: - Actions
    
    private func runPipeline() {
        guard canRunPipeline else { return }
        
        // 🎉 Haptic: Pipeline started
        HapticManager.shared.pipelineStarted()
        
        isProcessing = true
        errorMessage = nil
        pipelineProgress = 0.0
        currentModule = ""
        liveResults = [:]
        
        Task {
            do {
                // Simulate pipeline execution with progress updates
                let modules = getEnabledModules()
                
                for (index, module) in modules.enumerated() {
                    await MainActor.run {
                        currentModule = module
                        pipelineProgress = Double(index) / Double(modules.count)
                    }
                    
                    // Simulate module processing time
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    
                    // Update live results
                    await MainActor.run {
                        liveResults[module] = "Completed"
                    }
                }
                
                await MainActor.run {
                    pipelineProgress = 1.0
                    currentModule = "Pipeline Complete"
                    isProcessing = false
                    
                    // 🎉 Haptic: Pipeline completed successfully
                    HapticManager.shared.pipelineCompleted()
                }
                
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isProcessing = false
                    
                    // 🎉 Haptic: Pipeline failed
                    HapticManager.shared.pipelineFailed()
                }
            }
        }
    }
    
    private func cancelProcessing() {
        isProcessing = false
        pipelineProgress = 0.0
        currentModule = ""
        liveResults = [:]
    }
    
    private func getEnabledModules() -> [String] {
        var modules: [String] = []
        
        if moduleSettings.segmentationEnabled { modules.append("Story Segmentation") }
        if moduleSettings.storyAnalysisEnabled { modules.append("Story Analysis") }
        if moduleSettings.rewordingEnabled { modules.append("Text Rewording") }
        if moduleSettings.taxonomyEnabled { modules.append("Cinematic Enrichment") }
        if moduleSettings.continuityEnabled { modules.append("Continuity Validation") }
        if moduleSettings.videoGenerationEnabled { modules.append("Video Generation") }
        if moduleSettings.videoAssemblyEnabled { modules.append("Video Assembly") }
        
        return modules
    }
    
    private func exportAsJSON() {
        // Export pipeline results as JSON
        let exportData: [String: Any] = [
            "story": storyInput,
            "settings": [
                "targetDuration": moduleSettings.targetDuration,
                "videoQuality": moduleSettings.videoQuality.rawValue,
                "processingMode": moduleSettings.processingMode.rawValue
            ],
            "results": liveResults
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            #if os(iOS)
            UIPasteboard.general.string = jsonString
            // 🎉 Haptic: Export completed
            HapticManager.shared.exportCompleted()
            #endif
        }
    }
    
    private func exportAsPDF() {
        // Export pipeline results as PDF (placeholder)
        // TODO: Implement PDF export functionality
    }
    
    // 🚨 UX FIX #5: Calculate estimated cost for credits preview
    private func calculateEstimatedCost() -> Int? {
        guard !storyInput.isEmpty else { return nil }
        
        var cost = 0
        
        // Base segmentation cost
        if moduleSettings.segmentationEnabled {
            cost += 5
        }
        
        // Story analysis
        if moduleSettings.storyAnalysisEnabled {
            cost += 10
        }
        
        // Rewording (per 1000 chars)
        if moduleSettings.rewordingEnabled {
            cost += (storyInput.count / 1000) * 3
        }
        
        // Taxonomy tagging
        if moduleSettings.taxonomyEnabled {
            cost += 15
        }
        
        // Continuity checking
        if moduleSettings.continuityEnabled {
            cost += 8
        }
        
        // Video generation (most expensive)
        if moduleSettings.videoGenerationEnabled {
            cost += 50
        }
        
        // Video assembly
        if moduleSettings.videoAssemblyEnabled {
            cost += 20
        }
        
        return cost > 0 ? cost : nil
    }
    
    // MARK: - 🚨 UX FIX #1: Floating Action Button
    
    @ViewBuilder
    private var floatingActionButton: some View {
        if !isProcessing && canRunPipeline {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: runPipeline) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.circle.fill")
                                .font(.title3)
                            Text("Run Pipeline")
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(28)
                        .shadow(color: Color.blue.opacity(0.4), radius: 12, x: 0, y: 6)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    .accessibilityLabel("Run pipeline")
                    .accessibilityHint("Processes your story through all enabled modules")
                    .accessibilityAddTraits(.isButton)
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

/// Module Toggle View
struct ModuleToggleView: View {
    let title: String
    let description: String
    @Binding var isEnabled: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
                .onChange(of: isEnabled) { _ in
                    // 🎉 Haptic: Module toggled
                    HapticManager.shared.moduleToggled()
                }
        }
        .padding(.vertical, 4)
    }
}

/// Module Settings
public struct ModuleSettings {
    // Module toggles
    public var segmentationEnabled: Bool = true
    public var storyAnalysisEnabled: Bool = true
    public var rewordingEnabled: Bool = false
    public var taxonomyEnabled: Bool = true
    public var continuityEnabled: Bool = true
    public var videoGenerationEnabled: Bool = true
    public var videoAssemblyEnabled: Bool = true
    
    // Advanced settings
    public var targetDuration: Double = 120.0
    public var videoQuality: VideoQuality = .high
    public var processingMode: ProcessingMode = .balanced
    
    public init() {}
}

/// Video Quality Enum (using DirectorStudio.VideoQuality from VideoGenerationModule)
// Removed duplicate - use DirectorStudio.VideoQuality instead

/// Processing Mode Enum
public enum ProcessingMode: String, CaseIterable {
    case fast = "Fast"
    case balanced = "Balanced"
    case quality = "Quality"
}

/// Preview
struct PipelineView_Previews: PreviewProvider {
    static var previews: some View {
        PipelineView()
    }
}
