import SwiftUI
import DirectorStudio

struct PromptCardView: View {
    let prompt: DirectorStudio.PromptSegment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Prompt \(prompt.index)")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(Int(prompt.duration))s")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
            }
            
            Text(prompt.content)
                .font(.body)
                .foregroundColor(.primary)
            
            if !prompt.characters.isEmpty {
                HStack {
                    Text("Characters:")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Text(prompt.characters.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Text("Setting:")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(prompt.setting)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Action:")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(prompt.action)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}
