//
//  DirectorStudioApp.swift
//  DirectorStudio
//
//  iOS App Entry Point - Full App Store Ready
//

import SwiftUI

@main
struct DirectorStudioApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ProjectsView()
                .environmentObject(appState)
        }
    }
}

