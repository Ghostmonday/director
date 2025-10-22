//
//  PipelinePresets.swift
//  DirectorStudioUI
//
//  🚨 UX Fix #13: Pipeline presets system for quick configuration
//

import SwiftUI
import DirectorStudio

/// Pipeline preset with predefined settings
public struct PipelinePreset: Identifiable {
    public let id: UUID
    public let name: String
    public let description: String
    public let icon: String
    public let settings: ModuleSettings
    
    public init(id: UUID = UUID(), name: String, description: String, icon: String, settings: ModuleSettings) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.settings = settings
    }
}

/// Predefined pipeline presets
public struct PipelinePresets {
    public static let all: [PipelinePreset] = [
        PipelinePreset(
            name: "Quick Draft",
            description: "Fast processing for early drafts",
            icon: "hare.fill",
            settings: ModuleSettings(
                segmentationEnabled: true,
                storyAnalysisEnabled: false,
                rewordingEnabled: false,
                taxonomyEnabled: false,
                continuityEnabled: false,
                targetDuration: 60,
                videoQuality: .low,
                processingMode: .fast
            )
        ),
        PipelinePreset(
            name: "Story Analysis",
            description: "Deep analysis without video generation",
            icon: "chart.bar.fill",
            settings: ModuleSettings(
                segmentationEnabled: true,
                storyAnalysisEnabled: true,
                rewordingEnabled: true,
                taxonomyEnabled: true,
                continuityEnabled: true,
                targetDuration: 120,
                videoQuality: .medium,
                processingMode: .balanced
            )
        ),
        PipelinePreset(
            name: "Full Production",
            description: "Complete pipeline with all features",
            icon: "crown.fill",
            settings: ModuleSettings(
                segmentationEnabled: true,
                storyAnalysisEnabled: true,
                rewordingEnabled: true,
                taxonomyEnabled: true,
                continuityEnabled: true,
                targetDuration: 180,
                videoQuality: .high,
                processingMode: .quality
            )
        ),
        PipelinePreset(
            name: "Minimal Pipeline",
            description: "Essential modules only",
            icon: "play.rectangle.fill",
            settings: ModuleSettings(
                segmentationEnabled: true,
                storyAnalysisEnabled: false,
                rewordingEnabled: false,
                taxonomyEnabled: true,
                continuityEnabled: false,
                targetDuration: 120,
                videoQuality: .high,
                processingMode: .fast
            )
        )
    ]
}

/// Preset selector view
public struct PresetSelectorView: View {
    @Binding var selectedSettings: ModuleSettings
    let onPresetSelected: () -> Void
    
    public init(selectedSettings: Binding<ModuleSettings>, onPresetSelected: @escaping () -> Void) {
        self._selectedSettings = selectedSettings
        self.onPresetSelected = onPresetSelected
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pipeline Presets")
                .font(.headline)
                .foregroundColor(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(PipelinePresets.all) { preset in
                        PresetCard(preset: preset) {
                            selectedSettings = preset.settings
                            onPresetSelected()
                        }
                    }
                    
                    // Custom preset button
                    Button(action: {}) {
                        VStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                            
                            Text("Custom")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .frame(width: 140, height: 100)
                        #if os(iOS)
                        .background(Color(UIColor.systemGray6))
                        #else
                        .background(Color(.controlBackgroundColor))
                        #endif
                        .cornerRadius(12)
                    }
                    .accessibilityLabel("Create custom preset")
                }
                .padding(.horizontal, 1)
            }
        }
    }
}

/// Individual preset card
struct PresetCard: View {
    let preset: PipelinePreset
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: preset.icon)
                        .foregroundColor(.blue)
                        .font(.title3)
                    Spacer()
                }
                
                Text(preset.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(preset.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .frame(height: 30, alignment: .top)
            }
            .padding()
            .frame(width: 140, height: 100)
            #if os(iOS)
            .background(Color(UIColor.systemGray6))
            #else
            .background(Color(.controlBackgroundColor))
            #endif
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(preset.name)
        .accessibilityHint(preset.description)
    }
}

// Extension to help with initializers
extension ModuleSettings {
    public init(
        segmentationEnabled: Bool,
        storyAnalysisEnabled: Bool,
        rewordingEnabled: Bool,
        taxonomyEnabled: Bool,
        continuityEnabled: Bool,
        targetDuration: Double,
        videoQuality: VideoQuality,
        processingMode: ProcessingMode
    ) {
        self.init()
        self.segmentationEnabled = segmentationEnabled
        self.storyAnalysisEnabled = storyAnalysisEnabled
        self.rewordingEnabled = rewordingEnabled
        self.taxonomyEnabled = taxonomyEnabled
        self.continuityEnabled = continuityEnabled
        self.targetDuration = targetDuration
        self.videoQuality = videoQuality
        self.processingMode = processingMode
    }
}

// MARK: - Preview
struct PresetSelectorView_Previews: PreviewProvider {
    @State static var settings = ModuleSettings()
    
    static var previews: some View {
        VStack {
            PresetSelectorView(selectedSettings: $settings, onPresetSelected: {})
            Spacer()
        }
        .padding()
    }
}

