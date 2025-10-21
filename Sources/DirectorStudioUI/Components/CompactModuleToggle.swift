//
//  CompactModuleToggle.swift
//  DirectorStudioUI
//
//  🚨 UX FIX #10: Compact module configuration with grid layout
//

import SwiftUI

/// Compact module toggle for grid layout
public struct CompactModuleToggle: View {
    let icon: String
    let title: String
    @Binding var isEnabled: Bool
    
    public init(icon: String, title: String, isEnabled: Binding<Bool>) {
        self.icon = icon
        self.title = title
        self._isEnabled = isEnabled
    }
    
    public var body: some View {
        Button(action: { isEnabled.toggle() }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isEnabled ? .white : .secondary)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isEnabled ? .white : .primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isEnabled ? Color.blue : Color(UIColor.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isEnabled ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(title) module")
        .accessibilityValue(isEnabled ? "enabled" : "disabled")
        .accessibilityAddTraits(.isButton)
    }
}

/// Grid configuration view for modules
public struct ModuleConfigurationGrid: View {
    @Binding var settings: ModuleSettings
    
    public init(settings: Binding<ModuleSettings>) {
        self._settings = settings
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Enabled Modules")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                CompactModuleToggle(
                    icon: "scissors",
                    title: "Segment",
                    isEnabled: $settings.segmentationEnabled
                )
                
                CompactModuleToggle(
                    icon: "chart.bar.doc.horizontal",
                    title: "Analysis",
                    isEnabled: $settings.storyAnalysisEnabled
                )
                
                CompactModuleToggle(
                    icon: "text.bubble",
                    title: "Reword",
                    isEnabled: $settings.rewordingEnabled
                )
                
                CompactModuleToggle(
                    icon: "film",
                    title: "Taxonomy",
                    isEnabled: $settings.taxonomyEnabled
                )
                
                CompactModuleToggle(
                    icon: "checkmark.circle",
                    title: "Continuity",
                    isEnabled: $settings.continuityEnabled
                )
                
                CompactModuleToggle(
                    icon: "video",
                    title: "Video Gen",
                    isEnabled: $settings.videoGenerationEnabled
                )
                
                CompactModuleToggle(
                    icon: "play.rectangle",
                    title: "Assembly",
                    isEnabled: $settings.videoAssemblyEnabled
                )
            }
        }
    }
}

// MARK: - Preview
struct CompactModuleToggle_Previews: PreviewProvider {
    @State static var isEnabled = true
    @State static var settings = ModuleSettings()
    
    static var previews: some View {
        VStack(spacing: 20) {
            CompactModuleToggle(
                icon: "scissors",
                title: "Segmentation",
                isEnabled: $isEnabled
            )
            .frame(width: 100)
            
            ModuleConfigurationGrid(settings: $settings)
            
            Spacer()
        }
        .padding()
    }
}

