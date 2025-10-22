//
//  ContextBar.swift
//  DirectorStudioUI
//
//  Persistent context bar showing current story/project across all views
//  UX FIX #3: Solves the "lost context" problem when navigating between modules
//

import SwiftUI

/// Shows persistent context about the current story/project
public struct ContextBar: View {
    let storyPreview: String?
    let segmentCount: Int
    let projectName: String?
    let onShowDetails: () -> Void
    @State private var isExpanded = false
    
    public init(
        storyPreview: String?,
        segmentCount: Int,
        projectName: String?,
        onShowDetails: @escaping () -> Void
    ) {
        self.storyPreview = storyPreview
        self.segmentCount = segmentCount
        self.projectName = projectName
        self.onShowDetails = onShowDetails
    }
    
    public var body: some View {
        if shouldShow {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    // Project indicator icon
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(.blue)
                        .font(.body)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        // Project name
                        Text(projectName ?? "Current Session")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        // Story preview (first 50 chars)
                        if let preview = storyPreview, !preview.isEmpty {
                            Text(previewText(preview))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .lineLimit(isExpanded ? 3 : 1)
                        }
                    }
                    
                    Spacer()
                    
                    // Segment count badge
                    if segmentCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "film")
                                .font(.caption2)
                            Text("\(segmentCount)")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.15))
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                    }
                    
                    // Expand/Details button
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            isExpanded.toggle()
                        }
                    }) {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 44, height: 44) // Apple HIG minimum tap target
                    }
                    .accessibilityLabel(isExpanded ? "Collapse context" : "Expand context")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                #if os(iOS)
                .background(Color(UIColor.systemGray6))
                #else
                .background(Color(.windowBackgroundColor))
                #endif
                
                Divider()
            }
        }
    }
    
    // MARK: - Helpers
    
    private var shouldShow: Bool {
        storyPreview != nil || segmentCount > 0
    }
    
    private func previewText(_ text: String) -> String {
        let maxLength = isExpanded ? 150 : 50
        if text.count > maxLength {
            return text.prefix(maxLength) + "..."
        }
        return text
    }
}

// MARK: - Preview
struct ContextBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ContextBar(
                storyPreview: "A young hero discovers a hidden portal to another world and must save both realms from an ancient evil.",
                segmentCount: 5,
                projectName: "Portal Quest",
                onShowDetails: {}
            )
            
            ContextBar(
                storyPreview: nil,
                segmentCount: 0,
                projectName: "New Project",
                onShowDetails: {}
            )
            
            Spacer()
        }
    }
}

