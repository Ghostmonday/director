import SwiftUI
import DirectorStudio

struct ProjectCard: View {
    let project: Project
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(project.name)
                .font(.headline)
            Text(project.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            HStack {
                Text("Last Modified: \(project.lastModified, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        #if os(iOS)
        .background(Color(.secondarySystemBackground))
        #else
        .background(Color(.controlBackgroundColor))
        #endif
        .cornerRadius(10)
    }
}
