//
//  TimelineViews.swift
//  DirectorStudioUI
//
//  🚨 UX Fix #14: Timeline and Storyboard view modes for segments
//

import SwiftUI
import DirectorStudio

/// View mode for segment display
public enum SegmentViewMode {
    case list
    case timeline
    case storyboard
}

/// Timeline view with horizontal bars
public struct TimelineView: View {
    let segments: [GUISegment]
    @Binding var selectedSegment: GUISegment?
    let onSegmentTap: (GUISegment) -> Void
    
    public init(
        segments: [GUISegment],
        selectedSegment: Binding<GUISegment?>,
        onSegmentTap: @escaping (GUISegment) -> Void
    ) {
        self.segments = segments
        self._selectedSegment = selectedSegment
        self.onSegmentTap = onSegmentTap
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(spacing: 0) {
                ForEach(segments, id: \.id) { segment in
                    TimelineSegmentBar(
                        segment: segment,
                        isSelected: selectedSegment?.id == segment.id,
                        onTap: { onSegmentTap(segment) }
                    )
                    .frame(width: CGFloat(segment.duration) * 5) // 5pts per second
                }
            }
            .padding()
        }
        .frame(height: 120)
        #if os(iOS)
        .background(Color(UIColor.systemGray6).opacity(0.3))
        #else
        .background(Color(.controlBackgroundColor).opacity(0.3))
        #endif
    }
}

/// Individual timeline segment bar
struct TimelineSegmentBar: View {
    let segment: GUISegment
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                Text("S\(segment.index)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Rectangle()
                    .fill(segmentColor)
                    .frame(height: 50)
                    .cornerRadius(4)
                
                Text("\(segment.duration)s")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 4)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
            .cornerRadius(4)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Segment \(segment.index), duration \(segment.duration) seconds")
    }
    
    private var segmentColor: Color {
        if isSelected {
            return .blue
        } else if segment.hasCinematicTags {
            return Color.blue.opacity(0.6)
        } else {
            #if os(iOS)
            return Color(UIColor.systemGray4)
            #else
            return Color(.separatorColor)
            #endif
        }
    }
}

/// Storyboard view with card grid
public struct StoryboardView: View {
    let segments: [GUISegment]
    @Binding var selectedSegment: GUISegment?
    let onSegmentTap: (GUISegment) -> Void
    
    public init(
        segments: [GUISegment],
        selectedSegment: Binding<GUISegment?>,
        onSegmentTap: @escaping (GUISegment) -> Void
    ) {
        self.segments = segments
        self._selectedSegment = selectedSegment
        self.onSegmentTap = onSegmentTap
    }
    
    public var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 12)
            ], spacing: 12) {
                ForEach(segments, id: \.id) { segment in
                    StoryboardCard(
                        segment: segment,
                        isSelected: selectedSegment?.id == segment.id,
                        onTap: { onSegmentTap(segment) }
                    )
                }
            }
            .padding()
        }
    }
}

/// Individual storyboard card
struct StoryboardCard: View {
    let segment: GUISegment
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Thumbnail placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        #if os(iOS)
                        .fill(Color(UIColor.systemGray5))
                        #else
                        .fill(Color(.quaternaryLabelColor))
                        #endif
                        .frame(height: 100)
                    
                    VStack(spacing: 4) {
                        Image(systemName: "film")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("S\(segment.index)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Content preview
                Text(segment.content)
                    .font(.caption)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                // Metadata
                HStack {
                    Text("\(segment.duration)s")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if segment.hasCinematicTags {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            .padding(8)
            #if os(iOS)
            .background(Color(UIColor.systemGray6))
            #else
            .background(Color(.controlBackgroundColor))
            #endif
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Segment \(segment.index)")
        .accessibilityValue(segment.content.prefix(50) + "...")
    }
}

/// View mode picker
public struct ViewModePicker: View {
    @Binding var selectedMode: SegmentViewMode
    
    public init(selectedMode: Binding<SegmentViewMode>) {
        self._selectedMode = selectedMode
    }
    
    public var body: some View {
        Picker("View Mode", selection: $selectedMode) {
            Label("List", systemImage: "list.bullet").tag(SegmentViewMode.list)
            Label("Timeline", systemImage: "chart.bar.xaxis").tag(SegmentViewMode.timeline)
            Label("Storyboard", systemImage: "square.grid.2x2").tag(SegmentViewMode.storyboard)
        }
        .pickerStyle(.segmented)
    }
}

// MARK: - Preview
struct TimelineViews_Previews: PreviewProvider {
    @State static var selectedSegment: GUISegment? = nil
    @State static var viewMode: SegmentViewMode = .timeline
    
    static let sampleSegments: [GUISegment] = [
        GUISegment(
            id: UUID(),
            index: 1,
            duration: 30,
            content: "A young hero discovers a hidden portal to another world.",
            characters: ["Hero"],
            setting: "Forest",
            action: "Discovery",
            continuityNotes: "Introduce protagonist",
            hasCinematicTags: true
        ),
        GUISegment(
            id: UUID(),
            index: 2,
            duration: 45,
            content: "The hero steps through and finds themselves in a magical realm.",
            characters: ["Hero"],
            setting: "Magical Realm",
            action: "Entry",
            continuityNotes: "Transition scene",
            hasCinematicTags: false
        ),
        GUISegment(
            id: UUID(),
            index: 3,
            duration: 60,
            content: "An ancient guardian appears and challenges the hero.",
            characters: ["Hero", "Guardian"],
            setting: "Magical Realm",
            action: "Confrontation",
            continuityNotes: "First conflict",
            hasCinematicTags: true
        )
    ]
    
    static var previews: some View {
        VStack(spacing: 20) {
            ViewModePicker(selectedMode: $viewMode)
                .padding()
            
            switch viewMode {
            case .timeline:
                TimelineView(
                    segments: sampleSegments,
                    selectedSegment: $selectedSegment,
                    onSegmentTap: { selectedSegment = $0 }
                )
            case .storyboard:
                StoryboardView(
                    segments: sampleSegments,
                    selectedSegment: $selectedSegment,
                    onSegmentTap: { selectedSegment = $0 }
                )
            case .list:
                Text("List view (existing)")
            }
        }
    }
}

