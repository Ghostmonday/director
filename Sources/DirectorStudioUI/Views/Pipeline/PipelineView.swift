//
//  PipelineView.swift
//  DirectorStudioUI
//
//  Created by DirectorStudio on $(date)
//  Copyright © 2025 DirectorStudio. All rights reserved.
//

import SwiftUI
import DirectorStudio

public struct PipelineView: View {
    @EnvironmentObject private var appState: AppState
    let project: Project
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                storyInputSection
                
                moduleConfigurationSection
                
                advancedSettingsSection
                
                runPipelineButtonSection
                
                if appState.isProcessingPipeline {
                    processingView
                }
                
                if !appState.generatedPromptSegments.isEmpty {
                    resultsSection
                }
            }
            .padding()
        }
        .navigationTitle("Pipeline for \"\(project.name)\"")
    }
    
    private var storyInputSection: some View {
        Section(header: Text("Story Input").font(.title2).fontWeight(.bold)) {
            TextEditor(text: $appState.storyInput)
                .frame(minHeight: 150)
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
        }
    }
    
    private var moduleConfigurationSection: some View {
        Section(header: Text("Modules").font(.title2).fontWeight(.bold)) {
            ModuleConfigurationGrid(settings: $appState.moduleSettings)
        }
    }
    
    private var advancedSettingsSection: some View {
        Section(header: Text("Advanced").font(.title2).fontWeight(.bold)) {
            AdvancedSettingsView(settings: $appState.moduleSettings)
        }
    }
    
    private var runPipelineButtonSection: some View {
        Button(action: {
            appState.runPipeline()
        }) {
            Text("Run Pipeline")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(appState.isProcessingPipeline ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .disabled(appState.isProcessingPipeline)
    }
    
    private var processingView: some View {
        Section(header: Text("Processing").font(.title2).fontWeight(.bold)) {
            VStack(spacing: 8) {
                ProgressView(value: appState.pipelineProgress)
                Text(appState.currentPipelineModule)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
    
    private var resultsSection: some View {
        Section(header: Text("Generated Prompts").font(.title2).fontWeight(.bold)) {
            VStack(spacing: 16) {
                ForEach(appState.generatedPromptSegments) { segment in
                    PromptCardView(prompt: segment)
                }
            }
        }
    }
}
