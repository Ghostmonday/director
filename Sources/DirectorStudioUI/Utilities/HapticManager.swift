//
//  HapticManager.swift
//  DirectorStudioUI
//
//  🟢 POLISH: Haptic feedback for key interactions
//  Provides rich haptic feedback throughout the app
//

import SwiftUI

#if os(iOS)
import UIKit
#endif

/// Centralized haptic feedback manager for DirectorStudio
public final class HapticManager {
    public static let shared = HapticManager()
    
    #if os(iOS)
    private let impact = UIImpactFeedbackGenerator()
    private let selection = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()
    #endif
    
    private init() {
        #if os(iOS)
        // Prepare generators for lower latency
        impact.prepare()
        selection.prepare()
        notification.prepare()
        #endif
    }
    
    // MARK: - Impact Feedback
    
    /// Light impact (button taps, toggle switches)
    public func light() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }
    
    /// Medium impact (segmentlist operations, reordering)
    public func medium() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
    }
    
    /// Heavy impact (pipeline run, major actions)
    public func heavy() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        #endif
    }
    
    /// Soft impact (iOS 13+, gentle feedback)
    @available(iOS 13.0, *)
    public func soft() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
        #endif
    }
    
    /// Rigid impact (iOS 13+, firm feedback)
    @available(iOS 13.0, *)
    public func rigid() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
        #endif
    }
    
    // MARK: - Selection Feedback
    
    /// Selection changed (picker, segmented control)
    public func selectionChanged() {
        #if os(iOS)
        selection.selectionChanged()
        #endif
    }
    
    // MARK: - Notification Feedback
    
    /// Success feedback (pipeline complete, video generated)
    public func success() {
        #if os(iOS)
        notification.notificationOccurred(.success)
        #endif
    }
    
    /// Warning feedback (insufficient credits, validation warnings)
    public func warning() {
        #if os(iOS)
        notification.notificationOccurred(.warning)
        #endif
    }
    
    /// Error feedback (pipeline failed, export error)
    public func error() {
        #if os(iOS)
        notification.notificationOccurred(.error)
        #endif
    }
    
    // MARK: - Context-Specific Feedback
    
    /// Pipeline started
    public func pipelineStarted() {
        heavy()
    }
    
    /// Pipeline completed successfully
    public func pipelineCompleted() {
        success()
    }
    
    /// Pipeline failed
    public func pipelineFailed() {
        error()
    }
    
    /// Segment selected
    public func segmentSelected() {
        light()
    }
    
    /// Segment reordered
    public func segmentReordered() {
        medium()
    }
    
    /// Module toggled
    public func moduleToggled() {
        light()
    }
    
    /// Credit purchased
    public func creditPurchased() {
        success()
    }
    
    /// Insufficient credits
    public func insufficientCredits() {
        warning()
    }
    
    /// Export completed
    public func exportCompleted() {
        success()
    }
    
    /// Text cleared
    public func textCleared() {
        if #available(iOS 13.0, *) {
            soft()
        } else {
            light()
        }
    }
    
    /// Bulk action applied
    public func bulkActionApplied() {
        medium()
    }
    
    /// Delete action
    public func deleteAction() {
        if #available(iOS 13.0, *) {
            rigid()
        } else {
            heavy()
        }
    }
}

// MARK: - SwiftUI View Extension

extension View {
    /// Adds haptic feedback to a button action
    public func hapticFeedback(_ style: HapticStyle = .light, perform action: @escaping () -> Void) -> some View {
        self.modifier(HapticFeedbackModifier(style: style, action: action))
    }
}

/// Haptic feedback styles
public enum HapticStyle {
    case light
    case medium
    case heavy
    case soft
    case rigid
    case selection
    case success
    case warning
    case error
}

/// Modifier to add haptic feedback to view actions
struct HapticFeedbackModifier: ViewModifier {
    let style: HapticStyle
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        triggerHaptic()
                        action()
                    }
            )
    }
    
    private func triggerHaptic() {
        let haptic = HapticManager.shared
        switch style {
        case .light:
            haptic.light()
        case .medium:
            haptic.medium()
        case .heavy:
            haptic.heavy()
        case .soft:
            if #available(iOS 13.0, *) {
                haptic.soft()
            } else {
                haptic.light()
            }
        case .rigid:
            if #available(iOS 13.0, *) {
                haptic.rigid()
            } else {
                haptic.heavy()
            }
        case .selection:
            haptic.selectionChanged()
        case .success:
            haptic.success()
        case .warning:
            haptic.warning()
        case .error:
            haptic.error()
        }
    }
}

