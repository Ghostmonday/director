import SwiftUI
import DirectorStudioUI

struct DirectorStudioApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(AppState())
        }
    }
}

// Entry point
DirectorStudioApp.main()
