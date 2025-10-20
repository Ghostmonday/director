//
//  ProjectsView.swift
//  DirectorStudioUI
//
//  Created by DirectorStudio on $(date)
//  Copyright © 2025 DirectorStudio. All rights reserved.
//

import SwiftUI

/// Project Management UI - Project library with cards and search
struct ProjectsView: View {
    @State private var projects: [GUIProject] = []
    @State private var searchText: String = ""
    @State private var showingCreateProject: Bool = false
    @State private var selectedSortOption: SortOption = .lastModified
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    private let guiAbstraction = GUIAbstraction()
    
    enum SortOption: String, CaseIterable {
        case name = "Name"
        case lastModified = "Last Modified"
        case dateCreated = "Date Created"
        case status = "Status"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                searchSection
                
                // Content
                if isLoading {
                    loadingView
                } else if filteredProjects.isEmpty {
                    emptyStateView
                } else {
                    projectListView
                }
            }
            .navigationTitle("Projects")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreateProject = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateProject) {
                CreateProjectView { project in
                    projects.append(project)
                }
            }
            .onAppear {
                loadProjects()
            }
        }
    }
    
    // MARK: - Search Section
    
    private var searchSection: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search projects...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // Sort Options
            HStack {
                Text("Sort by:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("Sort", selection: $selectedSortOption) {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    // MARK: - Project List View
    
    private var projectListView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 300), spacing: 16)
            ], spacing: 16) {
                ForEach(sortedProjects, id: \.id) { project in
                    ProjectCardView(project: project)
                }
            }
            .padding()
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading projects...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Projects Found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(searchText.isEmpty ? 
                 "Create your first project to get started" : 
                 "No projects match your search")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if searchText.isEmpty {
                Button(action: { showingCreateProject = true }) {
                    Text("Create Project")
                        .fontWeight(.semibold)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - Computed Properties
    
    private var filteredProjects: [GUIProject] {
        if searchText.isEmpty {
            return projects
        } else {
            return projects.filter { project in
                project.name.localizedCaseInsensitiveContains(searchText) ||
                project.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private var sortedProjects: [GUIProject] {
        filteredProjects.sorted { project1, project2 in
            switch selectedSortOption {
            case .name:
                return project1.name < project2.name
            case .lastModified:
                return project1.lastModified > project2.lastModified
            case .dateCreated:
                return project1.createdAt > project2.createdAt
            case .status:
                return project1.status.rawValue < project2.status.rawValue
            }
        }
    }
    
    // MARK: - Actions
    
    private func loadProjects() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let loadedProjects = try await guiAbstraction.getProjects()
                
                await MainActor.run {
                    projects = loadedProjects
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

/// Project Card View
struct ProjectCardView: View {
    let project: GUIProject
    @State private var showingProjectDetail: Bool = false
    
    var body: some View {
        Button(action: { showingProjectDetail = true }) {
            VStack(alignment: .leading, spacing: 12) {
                // Project Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(project.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        
                        Text(project.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                    }
                    
                    Spacer()
                    
                    // Status Badge
                    statusBadge
                }
                
                // Project Stats
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(project.segmentCount) segments")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if project.hasVideo {
                            HStack(spacing: 4) {
                                Image(systemName: "video.fill")
                                    .font(.caption)
                                Text("Video generated")
                                    .font(.caption)
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Last modified")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(project.lastModified, style: .relative)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Preview Thumbnail Placeholder
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                    .frame(height: 100)
                    .overlay(
                        VStack {
                            Image(systemName: "photo")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            
                            Text("Preview")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    )
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingProjectDetail) {
            ProjectDetailView(project: project)
        }
    }
    
    private var statusBadge: some View {
        Text(project.status.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(6)
    }
    
    private var statusColor: Color {
        switch project.status {
        case .draft:
            return .orange
        case .processing:
            return .blue
        case .complete:
            return .green
        case .failed:
            return .red
        }
    }
}

/// Create Project View
struct CreateProjectView: View {
    @State private var projectName: String = ""
    @State private var projectDescription: String = ""
    @Environment(\.dismiss) private var dismiss
    let onProjectCreated: (GUIProject) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Project Name")
                        .font(.headline)
                    
                    TextField("Enter project name", text: $projectName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)
                    
                    TextField("Enter project description", text: $projectDescription, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Create Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createProject()
                    }
                    .disabled(projectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func createProject() {
        let newProject = GUIProject(
            id: UUID(),
            name: projectName,
            description: projectDescription,
            createdAt: Date(),
            lastModified: Date(),
            status: .draft,
            segmentCount: 0,
            hasVideo: false
        )
        
        onProjectCreated(newProject)
        dismiss()
    }
}

/// Project Detail View
struct ProjectDetailView: View {
    let project: GUIProject
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Project Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(project.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(project.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text("Status: \(project.status.rawValue)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("Created: \(project.createdAt, style: .date)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Project Actions
                    VStack(spacing: 12) {
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                Text("Run Pipeline")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Edit Project")
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Project Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

/// Preview
struct ProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectsView()
    }
}
