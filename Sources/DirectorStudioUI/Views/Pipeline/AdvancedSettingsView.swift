import SwiftUI
import DirectorStudio

public struct AdvancedSettingsView: View {
    @Binding var settings: ModuleSettings
    
    public init(settings: Binding<ModuleSettings>) {
        self._settings = settings
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Advanced Settings")
                .font(.headline)
            
            VStack(spacing: 12) {
                // Target Duration
                VStack(alignment: .leading, spacing: 8) {
                    Text("Target Duration: \(Int(settings.targetDuration)) seconds")
                        .font(.subheadline)
                    
                    Slider(value: $settings.targetDuration, in: 30...600, step: 30)
                        .accentColor(.blue)
                }
                
                // Video Quality
                VStack(alignment: .leading, spacing: 8) {
                    Text("Video Quality")
                        .font(.subheadline)
                    
                    Picker("Quality", selection: $settings.videoQuality) {
                        Text("Low").tag(VideoQuality.low)
                        Text("Medium").tag(VideoQuality.medium)
                        Text("High").tag(VideoQuality.high)
                        Text("Ultra").tag(VideoQuality.ultra)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Processing Mode
                VStack(alignment: .leading, spacing: 8) {
                    Text("Processing Mode")
                        .font(.subheadline)
                    
                    Picker("Mode", selection: $settings.processingMode) {
                        Text("Fast").tag(ProcessingMode.fast)
                        Text("Balanced").tag(ProcessingMode.balanced)
                        Text("Quality").tag(ProcessingMode.quality)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
        }
        .padding()
        #if os(iOS)
        .background(Color(UIColor.systemGray6))
        #else
        .background(Color(.controlBackgroundColor))
        #endif
        .cornerRadius(8)
    }
}
