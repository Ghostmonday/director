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
    
    public init(project: Project) {
        self.project = project
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Story Input
                EnhancedTextEditor(
                    text: $appState.storyInput,
                    placeholder: "Enter your story here...",
                    minHeight: 200
                )
                
                // Module Configuration
                ModuleConfigurationGrid(settings: $appState.moduleSettings)
                
                // Advanced Settings
                AdvancedSettingsView(settings: $appState.moduleSettings)
                
                // Run Pipeline Button
                Button(action: appState.runPipeline) {
                    Text("Run Pipeline")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(appState.isProcessingPipeline)
                
                // Processing View
                if appState.isProcessingPipeline {
                    VStack {
                        ProgressView(value: appState.pipelineProgress)
                        Text("Processing: \(appState.currentPipelineModule)")
                    }
                }
                
                // Results
                if !appState.generatedPromptSegments.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Generated Prompts")
                            .font(.headline)
                        
                        ForEach(appState.generatedPromptSegments) { segment in
                            PromptCardView(prompt: segment)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(project.name)
    }
}
