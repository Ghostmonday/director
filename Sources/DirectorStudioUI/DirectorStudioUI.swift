//
//  DirectorStudioUI.swift
//  DirectorStudioUI
//
//  Created by DirectorStudio on $(date)
//  Copyright © 2025 DirectorStudio. All rights reserved.
//

import SwiftUI

/// Main DirectorStudio UI Application
@main
struct DirectorStudioApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

/// Main content view with navigation
struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Pipeline View
            PipelineView()
                .tabItem {
                    Image(systemName: "play.circle.fill")
                    Text("Pipeline")
                }
                .tag(0)
            
            // Projects View
            ProjectsView()
                .tabItem {
                    Image(systemName: "folder.fill")
                    Text("Projects")
                }
                .tag(1)
            
            // Video Library
            VideoLibraryView()
                .tabItem {
                    Image(systemName: "video.fill")
                    Text("Library")
                }
                .tag(2)
            
            // Credits & Store
            CreditsStoreView()
                .tabItem {
                    Image(systemName: "creditcard.fill")
                    Text("Credits")
                }
                .tag(3)
            
            // Settings
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(4)
        }
        .accentColor(.blue)
    }
}

/// Preview for development
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
