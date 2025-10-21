//
//  DirectorStudioApp.swift
//  DirectorStudio
//
//  iOS App Entry Point - Full App Store Ready
//

import SwiftUI
import DirectorStudioUI

@main
struct DirectorStudioApp: App {
    @StateObject private var appState = AppState()
    
    init() {
        // Configure app on launch
        setupAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(appState)
        }
    }
    
    private func setupAppearance() {
        // Configure iOS appearance
        UINavigationBar.appearance().tintColor = .systemBlue
    }
}

