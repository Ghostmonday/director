//
//  UIGUIAbstraction.swift
//  DirectorStudioUI
//
//  MODULE: UIGUIAbstraction
//  VERSION: 1.0.0
//  PURPOSE: Dependency layer for ViewFactory
//

import Foundation
import SwiftUI
import DirectorStudio

public enum GUIFactory {
    public static func makeStoryView(for scene: SceneModel) -> some View {
        StoryView(scene: scene)
    }
    
    public static func makeVideoExportSheet() -> some View {
        VideoExportSheet()
    }
    
    public static func makeSceneEditor(for scene: SceneModel) -> some View {
        SceneEditorView(scene: scene)
    }
    
    public static func makeProjectListView() -> some View {
        ProjectListView()
    }
    
    public static func makePipelineView() -> some View {
        PipelineView()
    }
}

public struct StoryView: View {
    let scene: SceneModel
    @EnvironmentObject private var appState: AppState
    @StateObject private var exportManager = ExportManager()
    
    public init(scene: SceneModel) {
        self.scene = scene
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Scene Header
            HStack {
                VStack(alignment: .leading) {
                    Text("Scene \(scene.id)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Location: \(scene.location)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Export") {
                    Task {
                        await exportVideo()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(exportManager.isExporting)
            }
            
            // Scene Content
            ScrollView {
                Text(scene.prompt)
                    .font(.body)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Export Progress
            if exportManager.isExporting {
                VStack {
                    ProgressView(value: exportManager.exportProgress)
                    Text("Exporting video...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .navigationTitle("Story")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func exportVideo() async {
        // Create mock clips for export
        let clips = [
            ClipModel(
                url: URL(fileURLWithPath: "/tmp/clip1.mp4"),
                duration: 30.0, // Default duration
                title: "Scene \(scene.id)"
            )
        ]
        
        do {
            try await exportManager.exportClips(clips)
            appState.telemetry.logEvent("story_exported", properties: ["scene_id": String(scene.id)])
        } catch {
            appState.telemetry.logEvent("story_export_failed", properties: [
                "scene_id": String(scene.id),
                "error": error.localizedDescription
            ])
        }
    }
}

public struct VideoExportSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var exportManager = ExportManager()
    @EnvironmentObject private var appState: AppState
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Export Video")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                if exportManager.isExporting {
                    VStack(spacing: 16) {
                        ProgressView(value: exportManager.exportProgress)
                            .progressViewStyle(LinearProgressViewStyle())
                        
                        Text("Exporting... \(Int(exportManager.exportProgress * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("Ready to export your video")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Export") {
                        Task {
                            await performExport()
                        }
                    }
                    .disabled(exportManager.isExporting)
                }
            }
        }
    }
    
    private func performExport() async {
        // Mock export implementation
        let clips = [
            ClipModel(
                url: URL(fileURLWithPath: "/tmp/export_clip.mp4"),
                duration: 30.0,
                title: "Exported Video"
            )
        ]
        
        do {
            try await exportManager.exportClips(clips)
            appState.telemetry.logEvent("video_exported")
            dismiss()
        } catch {
            appState.telemetry.logEvent("video_export_failed", properties: ["error": error.localizedDescription])
        }
    }
}

public struct SceneEditorView: View {
    let scene: SceneModel
    @State private var editedTitle: String
    @State private var editedContent: String
    @EnvironmentObject private var appState: AppState
    
    public init(scene: SceneModel) {
        self.scene = scene
        self._editedTitle = State(initialValue: "Scene \(scene.id)")
        self._editedContent = State(initialValue: scene.prompt)
    }
    
    public var body: some View {
        Form {
            Section("Scene Details") {
                TextField("Title", text: $editedTitle)
                TextField("Content", text: $editedContent)
                    .lineLimit(5)
            }
            
            Section("Location") {
                Text(scene.location)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Edit Scene")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveChanges()
                }
            }
        }
    }
    
    private func saveChanges() {
        appState.telemetry.logEvent("scene_edited", properties: [
            "scene_id": String(scene.id),
            "title_changed": editedTitle != "Scene \(scene.id)",
            "content_changed": editedContent != scene.prompt
        ])
    }
}

public struct ProjectListView: View {
    @EnvironmentObject private var appState: AppState
    @State private var projects: [Project] = []
    
    public var body: some View {
        List(projects) { project in
            ProjectRowView(project: project)
                .onTapGesture {
                    appState.setCurrentProject(project)
                }
        }
        .navigationTitle("Projects")
        .onAppear {
            loadProjects()
        }
    }
    
    private func loadProjects() {
        // Mock project loading
        projects = [
            Project(name: "Sample Project 1", description: "A sample project"),
            Project(name: "Sample Project 2", description: "Another sample project")
        ]
        
        appState.telemetry.logEvent("projects_loaded", properties: ["count": projects.count])
    }
}

public struct ProjectRowView: View {
    let project: Project
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(project.name)
                .font(.headline)
            
            Text(project.description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
