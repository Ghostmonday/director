import SwiftUI
import DirectorStudio

struct ProjectCard: View {
    let project: Project
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(project.name)
                .font(.system(.headline, design: .rounded))
                .fontWeight(.bold)
            
            Text(project.description)
                .font(.system(.body, design: .rounded))
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
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
