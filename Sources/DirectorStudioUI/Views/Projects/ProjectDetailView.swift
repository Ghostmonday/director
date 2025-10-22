import SwiftUI
import DirectorStudio

struct ProjectDetailView: View {
    @EnvironmentObject private var appState: AppState
    let project: Project
    
    var body: some View {
        VStack {
            Text(project.name)
                .font(.largeTitle)
            Text(project.description)
                .font(.title3)
                .foregroundColor(.secondary)
            
            Spacer()
            
            NavigationLink(destination: PipelineView(project: project)) {
                Text("Go to Pipeline")
            }
            
            Spacer()
        }
        .onAppear {
            appState.setCurrentProject(project)
        }
    }
}
