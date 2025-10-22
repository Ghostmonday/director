//
//  DirectorStudioUI.swift
//  DirectorStudioUI
//
//  MODULE: DirectorStudioUI
//  VERSION: 1.0.0
//  PURPOSE: Main iOS SwiftUI application entry point
//

import SwiftUI
import DirectorStudio

public struct AppRootView: View {
    @EnvironmentObject private var appState: AppState
    
    public init() {}
    
    public var body: some View {
        ProjectsView()
    }
}

public struct MainTabView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedTab = 0
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            PipelineView(project: appState.projects.first ?? Project(name: "Placeholder", description: ""))
                .tabItem {
                    Image(systemName: "play.circle.fill")
                    Text("Pipeline")
                }
                .tag(0)
            
            VideoLibraryView()
                .tabItem {
                    Image(systemName: "film.stack.fill")
                    Text("Library")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(2)
        }
        .accentColor(.blue)
    }
}

public struct UserSession: Identifiable, Sendable {
    public let id: UUID
    public let userId: String
    public let createdAt: Date
    public let lastActiveAt: Date
    
    public init(id: UUID = UUID(), userId: String, createdAt: Date = Date(), lastActiveAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.createdAt = createdAt
        self.lastActiveAt = lastActiveAt
    }
}