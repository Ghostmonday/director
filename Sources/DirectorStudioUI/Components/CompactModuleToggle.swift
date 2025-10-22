//
//  CompactModuleToggle.swift
//  DirectorStudioUI
//
//  🚨 UX FIX #10: Compact module configuration with grid layout
//

import SwiftUI
import DirectorStudio

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
                    #if os(iOS)
                    .fill(isEnabled ? Color.blue : Color(UIColor.systemGray6))
                    #else
                    .fill(isEnabled ? Color.blue : Color(.controlBackgroundColor))
                    #endif
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
// Now defined in Sources/DirectorStudioUI/Views/Pipeline/ModuleConfigurationGrid.swift

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

