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
    @State private var showingCreateProject = false
    @State private var sortOrder: ProjectSortOrder = .dateDescending
    @State private var searchText = ""
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack {
                // Search and Sort Controls
                projectControls
                
                // Project Grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 250))], spacing: 20) {
                        ForEach(filteredProjects) { project in
                            NavigationLink(destination: ProjectDetailView(project: project)) {
                                ProjectCard(project: project)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Projects")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingCreateProject = true } label: {
                        Image(systemName: "plus")
                    }
                }
                #else
                ToolbarItem(placement: .primaryAction) {
                    Button { showingCreateProject = true } label: {
                        Image(systemName: "plus")
                    }
                }
                #endif
            }
            .sheet(isPresented: $showingCreateProject) {
                CreateProjectView { projectName, projectDescription in
                    appState.createProject(name: projectName, description: projectDescription)
                }
            }
        }
    }
    
    private var projectControls: some View {
        HStack {
            TextField("Search Projects", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.leading)
            
            Picker("Sort Order", selection: $sortOrder) {
                ForEach(ProjectSortOrder.allCases) { order in
                    Text(order.rawValue).tag(order)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding(.trailing)
        }
        .padding(.top)
    }
    
    private var filteredProjects: [Project] {
        let sortedProjects = appState.projects.sorted(by: sortOrder.sortFunction)
        
        if searchText.isEmpty {
            return sortedProjects
        } else {
            return sortedProjects.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
}
