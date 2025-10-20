//
//  SettingsView.swift
//  DirectorStudioUI
//
//  Created by DirectorStudio on $(date)
//  Copyright © 2025 DirectorStudio. All rights reserved.
//

import SwiftUI

/// Settings View
struct SettingsView: View {
    @State private var showingAISettings: Bool = false
    @State private var showingAbout: Bool = false
    @State private var showingHelp: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                // AI Services Section
                Section("AI Services") {
                    NavigationLink(destination: AIServiceSettingsView()) {
                        Label("AI Service Settings", systemImage: "brain.head.profile")
                    }
                }
                
                // Video Settings Section
                Section("Video Generation") {
                    NavigationLink(destination: VideoGenerationSettingsView()) {
                        Label("Video Generation Settings", systemImage: "video.fill")
                    }
                    
                    NavigationLink(destination: VideoAssemblySettingsView()) {
                        Label("Video Assembly Settings", systemImage: "scissors")
                    }
                }
                
                // App Settings Section
                Section("Application") {
                    NavigationLink(destination: Text("Notifications Settings")) {
                        Label("Notifications", systemImage: "bell")
                    }
                    
                    NavigationLink(destination: Text("Storage Settings")) {
                        Label("Storage", systemImage: "externaldrive")
                    }
                    
                    NavigationLink(destination: Text("Privacy Settings")) {
                        Label("Privacy", systemImage: "hand.raised")
                    }
                }
                
                // Support Section
                Section("Support") {
                    Button { showingHelp = true } label: {
                        Label("Help & Support", systemImage: "questionmark.circle")
                    }
                    
                    Button { showingAbout = true } label: {
                        Label("About DirectorStudio", systemImage: "info.circle")
                    }
                }
                
                // Version Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .sheet(isPresented: $showingHelp) {
                HelpView()
            }
        }
    }
}

/// About View
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // App Icon
                Image(systemName: "video.badge.plus")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("DirectorStudio")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Transform your stories into cinematic videos")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 8) {
                    Text("Version 1.0.0")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Built with SwiftUI")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("About")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

/// Help View
struct HelpView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Getting Started")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("DirectorStudio helps you transform your stories into cinematic videos using AI-powered analysis and generation.")
                        .font(.body)
                    
                    Text("How to Use")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HelpStepView(
                            number: "1",
                            title: "Enter Your Story",
                            description: "Start by entering your story text in the Pipeline tab."
                        )
                        
                        HelpStepView(
                            number: "2",
                            title: "Configure Pipeline",
                            description: "Choose which modules to run and adjust settings as needed."
                        )
                        
                        HelpStepView(
                            number: "3",
                            title: "Run Pipeline",
                            description: "Execute the pipeline to analyze and process your story."
                        )
                        
                        HelpStepView(
                            number: "4",
                            title: "Generate Video",
                            description: "Create video clips and assemble them into your final video."
                        )
                    }
                    
                    Text("Need More Help?")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("Contact our support team at support@directorstudio.com")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationTitle("Help & Support")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

/// Help Step View
struct HelpStepView: View {
    let number: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color.blue)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

/// AI Service Settings View (Placeholder)
struct AIServiceSettingsView: View {
    var body: some View {
        Text("AI Service Settings")
            .navigationTitle("AI Settings")
    }
}

/// Video Generation Settings View (Placeholder)
struct VideoGenerationSettingsView: View {
    var body: some View {
        Text("Video Generation Settings")
            .navigationTitle("Video Settings")
    }
}

/// Video Assembly Settings View (Placeholder)
struct VideoAssemblySettingsView: View {
    var body: some View {
        Text("Video Assembly Settings")
            .navigationTitle("Assembly Settings")
    }
}

/// Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
