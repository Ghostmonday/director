import SwiftUI
import DirectorStudio

public struct PromptCardView: View {
    @EnvironmentObject private var appState: AppState
    
    public var prompt: PromptSegment
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Segment \(prompt.index)")
                .font(.headline)
            Text(prompt.content)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        
        Button(action: {
            appState.generateVideo(for: prompt)
        }) {
            Text("Generate Video")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}
