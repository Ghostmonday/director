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

@main
struct DirectorStudioApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(appState)
        }
    }
}

@MainActor
public class AppState: ObservableObject {
    @Published public var isOnboardingComplete: Bool = false
    @Published public var currentProject: Project?
    @Published public var userSession: UserSession?
    @Published public var telemetryEnabled: Bool = true
    
    public let telemetry = Telemetry.shared
    
    public init() {
        loadUserPreferences()
        telemetry.logEvent("app_launched")
    }
    
    public func completeOnboarding() {
        isOnboardingComplete = true
        telemetry.logEvent("onboarding_completed")
    }
    
    public func setCurrentProject(_ project: Project) {
        currentProject = project
        telemetry.logEvent("project_selected", properties: ["project_id": project.id.uuidString])
    }
    
    public func updateUserSession(_ session: UserSession) {
        userSession = session
        telemetry.logEvent("session_updated", properties: ["user_id": session.userId])
    }
    
    public func toggleTelemetry() {
        telemetryEnabled.toggle()
        telemetry.logEvent("telemetry_toggled", properties: ["enabled": telemetryEnabled])
    }
    
    private func loadUserPreferences() {
        // Load from UserDefaults or other persistence
        isOnboardingComplete = UserDefaults.standard.bool(forKey: "onboarding_complete")
        telemetryEnabled = UserDefaults.standard.object(forKey: "telemetry_enabled") as? Bool ?? true
    }
    
    public func saveUserPreferences() {
        UserDefaults.standard.set(isOnboardingComplete, forKey: "onboarding_complete")
        UserDefaults.standard.set(telemetryEnabled, forKey: "telemetry_enabled")
    }
}

public struct AppRootView: View {
    @EnvironmentObject private var appState: AppState
    
    public init() {}
    
    public var body: some View {
        Group {
            if appState.isOnboardingComplete {
                MainTabView()
            } else {
                OnboardingView(hasCompletedOnboarding: $appState.isOnboardingComplete)
            }
        }
        .onAppear {
            appState.telemetry.logEvent("app_root_view_appeared")
        }
    }
}

public struct MainTabView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedTab = 0
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            PipelineView()
                .tabItem {
                    Image(systemName: "play.circle.fill")
                    Text("Pipeline")
                }
                .tag(0)
            
            ProjectsView()
                .tabItem {
                    Image(systemName: "folder.fill")
                    Text("Projects")
                }
                .tag(1)
            
            VideoLibraryView()
                .tabItem {
                    Image(systemName: "video.fill")
                    Text("Library")
                }
                .tag(2)
            
            CreditsStoreView()
                .tabItem {
                    Image(systemName: "creditcard.fill")
                    Text("Credits")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(4)
        }
        .accentColor(.blue)
        .onAppear {
            appState.telemetry.logEvent("main_tab_view_appeared")
        }
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