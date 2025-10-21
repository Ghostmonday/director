//
//  BreadcrumbBar.swift
//  DirectorStudioUI
//
//  🚨 UX FIX #9: Breadcrumb navigation component for workflow clarity
//

import SwiftUI

/// Represents a single breadcrumb item
public struct BreadcrumbItem: Identifiable {
    public let id = UUID()
    public let title: String
    public let icon: String
    public let action: () -> Void
    
    public init(title: String, icon: String, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
}

/// Horizontal breadcrumb navigation bar
public struct BreadcrumbBar: View {
    let items: [BreadcrumbItem]
    
    public init(items: [BreadcrumbItem]) {
        self.items = items
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    Button(action: item.action) {
                        HStack(spacing: 4) {
                            Image(systemName: item.icon)
                                .font(.caption)
                            Text(item.title)
                                .font(.caption)
                                .fontWeight(index == items.count - 1 ? .semibold : .regular)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(index == items.count - 1 ? Color.blue.opacity(0.15) : Color.clear)
                        .foregroundColor(index == items.count - 1 ? .blue : .secondary)
                        .cornerRadius(6)
                    }
                    .accessibilityLabel("Navigate to \(item.title)")
                    .frame(minWidth: 44, minHeight: 44)
                    
                    if index < items.count - 1 {
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 44)
        .background(Color(UIColor.systemGray6).opacity(0.5))
    }
}

// MARK: - Preview
struct BreadcrumbBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            BreadcrumbBar(items: [
                BreadcrumbItem(title: "Pipeline", icon: "play.circle", action: {}),
                BreadcrumbItem(title: "Segmentation", icon: "scissors", action: {}),
                BreadcrumbItem(title: "Segment 3", icon: "doc.text", action: {})
            ])
            
            BreadcrumbBar(items: [
                BreadcrumbItem(title: "Projects", icon: "folder", action: {}),
                BreadcrumbItem(title: "Portal Quest", icon: "doc.text.fill", action: {})
            ])
            
            Spacer()
        }
    }
}

