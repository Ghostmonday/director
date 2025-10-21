//
//  AccessibilityHelpers.swift
//  DirectorStudioUI
//
//  🟠 HIGH PRIORITY: Comprehensive VoiceOver accessibility support
//  App Store Requirement: All interactive elements must be accessible
//

import SwiftUI

/// Accessibility enhancement helpers for DirectorStudio
public enum AccessibilityHelpers {
    
    /// Standard minimum tap target size per Apple HIG
    public static let minimumTapTarget: CGFloat = 44
    
    /// Creates an accessible button with proper sizing
    public static func accessibleButton(
        label: String,
        hint: String? = nil,
        traits: AccessibilityTraits = .isButton,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> some View
    ) -> some View {
        Button(action: action) {
            content()
                .frame(minWidth: minimumTapTarget, minHeight: minimumTapTarget)
        }
        .accessibilityLabel(label)
        .if(hint != nil) { view in
            view.accessibilityHint(hint!)
        }
        .accessibilityAddTraits(traits)
    }
}

/// View extension for conditional modifiers
extension View {
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

/// Accessibility labels for common UI elements
public enum AccessibilityLabels {
    // Navigation
    public static let backButton = "Go back"
    public static let closeButton = "Close"
    public static let doneButton = "Done"
    public static let cancelButton = "Cancel"
    
    // Actions
    public static let playButton = "Play"
    public static let pauseButton = "Pause"
    public static let stopButton = "Stop"
    public static let deleteButton = "Delete"
    public static let editButton = "Edit"
    public static let saveButton = "Save"
    public static let exportButton = "Export"
    public static let shareButton = "Share"
    
    // Pipeline
    public static let runPipeline = "Run pipeline"
    public static let segmentStory = "Segment story"
    public static let analyzeStory = "Analyze story"
    public static let generateVideo = "Generate video"
    
    // Credits
    public static let creditsBalance = "Credits balance"
    public static let buyCredits = "Buy credits"
    public static let viewPurchaseHistory = "View purchase history"
}

/// Accessibility hints for complex actions
public enum AccessibilityHints {
    // Pipeline
    public static let runPipeline = "Processes your story through all enabled modules"
    public static let segmentStory = "Breaks your story into manageable video segments"
    public static let moduleToggle = "Double tap to enable or disable this module"
    
    // Credits
    public static let creditsIndicator = "Shows your current credit balance and estimated cost"
    public static let purchasePackage = "Double tap to purchase this credit package"
    
    // Editing
    public static let textEditor = "Enter your story text here"
    public static let clearText = "Removes all text from the editor"
    public static let expandEditor = "Expands the editor to full screen"
}

/// Accessibility identifiers for UI testing
public enum AccessibilityIdentifiers {
    public static let pipelineRunButton = "pipeline.run.button"
    public static let storyTextEditor = "story.text.editor"
    public static let segmentList = "segment.list"
    public static let creditsBalance = "credits.balance"
    public static let moduleTogglePrefix = "module.toggle."
}

