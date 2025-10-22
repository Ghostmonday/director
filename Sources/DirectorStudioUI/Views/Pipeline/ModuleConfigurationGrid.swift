import SwiftUI
import DirectorStudio

public struct ModuleConfigurationGrid: View {
    @Binding var settings: ModuleSettings
    
    public init(settings: Binding<ModuleSettings>) {
        self._settings = settings
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Pipeline Configuration")
                .font(.headline)
            
            VStack(spacing: 12) {
                ModuleToggleView(
                    title: "Story Segmentation",
                    description: "Break story into video segments",
                    isEnabled: $settings.segmentationEnabled
                )
                ModuleToggleView(
                    title: "Story Analysis",
                    description: "Analyze narrative structure and themes",
                    isEnabled: $settings.storyAnalysisEnabled
                )
                ModuleToggleView(
                    title: "Text Rewording",
                    description: "Transform text for video narration",
                    isEnabled: $settings.rewordingEnabled
                )
                ModuleToggleView(
                    title: "Cinematic Enrichment",
                    description: "Add cinematic metadata and shot types",
                    isEnabled: $settings.taxonomyEnabled
                )
                ModuleToggleView(
                    title: "Continuity Validation",
                    description: "Ensure visual and narrative continuity",
                    isEnabled: $settings.continuityEnabled
                )
            }
        }
        .padding()
        #if os(iOS)
        .background(Color(UIColor.systemBackground))
        #else
        .background(Color(.windowBackgroundColor))
        #endif
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                #if os(iOS)
                .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                #else
                .stroke(Color(.separatorColor), lineWidth: 1)
                #endif
        )
    }
}

struct ModuleToggleView: View {
    let title: String
    let description: String
    @Binding var isEnabled: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
        }
    }
}
