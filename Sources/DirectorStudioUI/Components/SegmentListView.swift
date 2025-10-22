//
//  SegmentListView.swift
//  DirectorStudioUI
//
//  🚨 UX Fix #11 & #12: Drag-and-drop reordering + Bulk operations
//

import SwiftUI
import DirectorStudio

/// Enhanced segment list with drag-drop and bulk operations
public struct SegmentListView: View {
    @Binding var segments: [GUISegment]
    @Binding var selectedSegmentIDs: Set<UUID>
    @Binding var isSelectionMode: Bool
    
    let onSegmentTap: (GUISegment) -> Void
    let onApplyTaxonomy: ([UUID]) -> Void
    let onReword: ([UUID]) -> Void
    let onDelete: ([UUID]) -> Void
    
    public init(
        segments: Binding<[GUISegment]>,
        selectedSegmentIDs: Binding<Set<UUID>>,
        isSelectionMode: Binding<Bool>,
        onSegmentTap: @escaping (GUISegment) -> Void,
        onApplyTaxonomy: @escaping ([UUID]) -> Void,
        onReword: @escaping ([UUID]) -> Void,
        onDelete: @escaping ([UUID]) -> Void
    ) {
        self._segments = segments
        self._selectedSegmentIDs = selectedSegmentIDs
        self._isSelectionMode = isSelectionMode
        self.onSegmentTap = onSegmentTap
        self.onApplyTaxonomy = onApplyTaxonomy
        self.onReword = onReword
        self.onDelete = onDelete
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Bulk action bar (shows when items selected)
            if isSelectionMode && !selectedSegmentIDs.isEmpty {
                bulkActionBar
            }
            
            // Segment list with drag-drop
            List {
                ForEach(segments, id: \.id) { segment in
                    segmentRow(segment)
                }
                .onMove { fromOffsets, toOffset in
                    segments.move(fromOffsets: fromOffsets, toOffset: toOffset)
                    updateSegmentIndices()
                }
            }
            .listStyle(.plain)
            #if os(iOS)
            .environment(\.editMode, .constant(isSelectionMode ? .active : .inactive))
            #endif
        }
    }
    
    // MARK: - Segment Row
    
    @ViewBuilder
    private func segmentRow(_ segment: GUISegment) -> some View {
        Button(action: {
            if isSelectionMode {
                toggleSelection(segment.id)
            } else {
                onSegmentTap(segment)
            }
        }) {
            HStack(spacing: 12) {
                // Selection checkbox (in selection mode)
                if isSelectionMode {
                    Image(systemName: selectedSegmentIDs.contains(segment.id) ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(.blue)
                        .font(.title3)
                        .frame(minWidth: 44, minHeight: 44)
                }
                
                // Drag handle
                Image(systemName: "line.3.horizontal")
                    .foregroundColor(.secondary)
                    .font(.caption)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Segment \(segment.index)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(segment.content.prefix(60) + "...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Duration badge
                Text("\(segment.duration)s")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    #if os(iOS)
                    .background(Color(UIColor.systemGray5))
                    #else
                    .background(Color(.quaternaryLabelColor))
                    #endif
                    .cornerRadius(6)
                
                // Cinematic tag indicator
                if segment.hasCinematicTags {
                    Image(systemName: "film.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Segment \(segment.index)")
        .accessibilityValue(isSelectionMode && selectedSegmentIDs.contains(segment.id) ? "selected" : "not selected")
    }
    
    // MARK: - Bulk Action Bar
    
    private var bulkActionBar: some View {
        HStack(spacing: 16) {
            Text("\(selectedSegmentIDs.count) selected")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: { onApplyTaxonomy(Array(selectedSegmentIDs)) }) {
                Label("Taxonomy", systemImage: "film")
                    .font(.caption)
            }
            .buttonStyle(.bordered)
            .frame(minHeight: 44)
            
            Button(action: { onReword(Array(selectedSegmentIDs)) }) {
                Label("Reword", systemImage: "text.bubble")
                    .font(.caption)
            }
            .buttonStyle(.bordered)
            .frame(minHeight: 44)
            
            Button(action: { onDelete(Array(selectedSegmentIDs)) }) {
                Label("Delete", systemImage: "trash")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            .buttonStyle(.bordered)
            .frame(minHeight: 44)
        }
        .padding()
        #if os(iOS)
        .background(Color(UIColor.systemGray6))
        #else
        .background(Color(.controlBackgroundColor))
        #endif
    }
    
    // MARK: - Helper Methods
    
    private func toggleSelection(_ id: UUID) {
        if selectedSegmentIDs.contains(id) {
            selectedSegmentIDs.remove(id)
        } else {
            selectedSegmentIDs.insert(id)
        }
    }
    
    private func updateSegmentIndices() {
        for (index, _) in segments.enumerated() {
            // In a real implementation, update the segment index
            // segments[index].index = index
        }
    }
}

// MARK: - Preview
struct SegmentListView_Previews: PreviewProvider {
    @State static var segments: [GUISegment] = [
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
        )
    ]
    @State static var selectedIDs: Set<UUID> = []
    @State static var isSelectionMode = false
    
    static var previews: some View {
        SegmentListView(
            segments: $segments,
            selectedSegmentIDs: $selectedIDs,
            isSelectionMode: $isSelectionMode,
            onSegmentTap: { _ in },
            onApplyTaxonomy: { _ in },
            onReword: { _ in },
            onDelete: { _ in }
        )
    }
}

