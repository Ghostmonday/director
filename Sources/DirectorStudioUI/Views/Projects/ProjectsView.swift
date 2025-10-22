//
//  ProjectsView.swift
//  DirectorStudioUI
//
//  Created by DirectorStudio on $(date)
//  Copyright © 2025 DirectorStudio. All rights reserved.
//

import SwiftUI
import DirectorStudio

public struct ProjectsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showingCreateSheet = false
    @State private var sortOrder: ProjectSortOrder = .dateDescending
    @State private var searchText = ""
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            Group {
                if appState.isLoading {
                    ProgressView()
                } else if appState.projects.isEmpty {
                    emptyStateView
                } else {
                    projectListView
                }
            }
            .navigationTitle("Projects")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingCreateSheet = true } label: {
                        Image(systemName: "plus")
                    }
                }
                #else
                ToolbarItem(placement: .primaryAction) {
                    Button { showingCreateSheet = true } label: {
                        Image(systemName: "plus")
                    }
                }
                #endif
            }
            .sheet(isPresented: $showingCreateSheet) {
                CreateProjectView { projectName, projectDescription in
                    appState.createProject(name: projectName, description: projectDescription)
                }
            }
        }
        .errorAlert(errorMessage: $appState.errorMessage)
    }
    
    private var projectListView: some View {
        List {
            ForEach(appState.projects) { project in
                NavigationLink(destination: ProjectDetailView(project: project)) {
                    ProjectCard(project: project)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack {
            Text("No Projects Yet")
                .font(.headline)
            Text("Tap the '+' button to create your first project.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}
