//
//  ColorTheme.swift
//  DirectorStudioUI
//
//  🟢 POLISH: Dark Mode optimization with adaptive colors
//  Ensures beautiful appearance in both light and dark modes
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

public enum DirectorStudioColor {
    // MARK: - Brand Colors
    
    /// The primary brand color
    public static let brandPrimary = Color("BrandPrimary")
    
    /// A secondary accent color
    public static let accent = Color("AccentColor")
    
    // MARK: - Background Colors
    
    /// Primary background (pure white/black in light/dark)
    #if os(iOS)
    public static let background = Color(uiColor: .systemBackground)
    #else
    public static let background = Color(.windowBackgroundColor)
    #endif
    
    /// Secondary background (slightly darker/lighter)
    #if os(iOS)
    public static let backgroundSecondary = Color(uiColor: .secondarySystemBackground)
    #else
    public static let backgroundSecondary = Color(.controlBackgroundColor)
    #endif
    
    /// Tertiary background (even more contrast)
    #if os(iOS)
    public static let backgroundTertiary = Color(uiColor: .tertiarySystemBackground)
    #else
    public static let backgroundTertiary = Color(.underPageBackgroundColor)
    #endif
    
    /// Grouped background (for lists)
    #if os(iOS)
    public static let backgroundGrouped = Color(uiColor: .systemGroupedBackground)
    #else
    public static let backgroundGrouped = Color(.controlBackgroundColor)
    #endif
    
    // MARK: - Content Colors
    
    /// Primary text color
    #if os(iOS)
    public static let text = Color(uiColor: .label)
    #else
    public static let text = Color(.labelColor)
    #endif
    
    /// Secondary text color (less emphasis)
    #if os(iOS)
    public static let textSecondary = Color(uiColor: .secondaryLabel)
    #else
    public static let textSecondary = Color(.secondaryLabelColor)
    #endif
    
    /// Tertiary text color (even less emphasis)
    #if os(iOS)
    public static let textTertiary = Color(uiColor: .tertiaryLabel)
    #else
    public static let textTertiary = Color(.tertiaryLabelColor)
    #endif
    
    /// Quaternary text color (disabled states)
    #if os(iOS)
    public static let textQuaternary = Color(uiColor: .quaternaryLabel)
    #else
    public static let textQuaternary = Color(.quaternaryLabelColor)
    #endif
    
    // MARK: - Separator Colors
    
    /// Standard separator line
    #if os(iOS)
    public static let separator = Color(uiColor: .separator)
    #else
    public static let separator = Color(.separatorColor)
    #endif
    
    /// Opaque separator (always visible)
    #if os(iOS)
    public static let separatorOpaque = Color(uiColor: .opaqueSeparator)
    #else
    public static let separatorOpaque = Color(.separatorColor)
    #endif
    
    // MARK: - System Grays (Adaptive)
    
    public static let gray1 = Color.gray
    #if os(iOS)
    public static let gray2 = Color(uiColor: .systemGray2)
    public static let gray3 = Color(uiColor: .systemGray3)
    public static let gray4 = Color(uiColor: .systemGray4)
    public static let gray5 = Color(uiColor: .systemGray5)
    public static let gray6 = Color(uiColor: .systemGray6)
    #else
    public static let gray2 = Color(.systemGray)
    public static let gray3 = Color(.systemGray)
    public static let gray4 = Color(.systemGray)
    public static let gray5 = Color(.systemGray)
    public static let gray6 = Color(.systemGray)
    #endif
    
    // MARK: - Semantic Colors
    
    /// A color for links
    public static let link = Color.blue
    
    /// A color for interactive elements
    public static let interactive = Color.blue
    
    /// A color for indicating success
    public static let success = Color.green
    
    /// A color for indicating warnings
    public static let warning = Color.orange
    
    /// A color for indicating errors
    public static let error = Color.red
    
    /// Card background
    #if os(iOS)
    public static let cardBackground = Color(uiColor: .systemGray6)
    #else
    public static let cardBackground = Color(.controlBackgroundColor)
    #endif
    
    /// Input field background
    #if os(iOS)
    public static let inputBackground = Color(uiColor: .systemGray6)
    #else
    public static let inputBackground = Color(.textBackgroundColor)
    #endif
    
    /// Button primary background
    public static let buttonPrimary = Color.blue
    
    /// Button secondary background
    #if os(iOS)
    public static let buttonSecondary = Color(uiColor: .systemGray4)
    #else
    public static let buttonSecondary = Color(.separatorColor)
    #endif
    
    // MARK: - Gradient Colors
    
    /// A sample gradient
    public static let primaryGradient = LinearGradient(
        gradient: Gradient(colors: [brandPrimary, accent]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Gradient Extensions

public extension LinearGradient {
    /// Primary gradient for buttons
    static let primaryButton = LinearGradient(
        gradient: Gradient(colors: [DirectorStudioColor.brandPrimary, DirectorStudioColor.accent]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Success gradient
    static let success = LinearGradient(
        gradient: Gradient(colors: [Color.green, Color.green.opacity(0.7)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Warning gradient
    static let warning = LinearGradient(
        gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.7)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - View Extension for Themed Backgrounds

public extension View {
    /// Applies adaptive card background
    func cardBackground() -> some View {
        self.background(DirectorStudioColor.cardBackground)
    }
    
    /// Applies adaptive input background
    func inputBackground() -> some View {
        self.background(DirectorStudioColor.inputBackground)
    }
    
    /// Applies primary background
    func primaryBackground() -> some View {
        self.background(DirectorStudioColor.background)
    }
}

// MARK: - Color Scheme Detector

/// Helper to detect and respond to color scheme changes
public struct ColorSchemeHelper {
    @Environment(\.colorScheme) private var colorScheme
    
    public var isDarkMode: Bool {
        colorScheme == .dark
    }
    
    public var isLightMode: Bool {
        colorScheme == .light
    }
}

// MARK: - Shadow Modifiers (Adaptive)

public extension View {
    /// Applies adaptive shadow (adjusts for dark mode)
    func adaptiveShadow(radius: CGFloat = 8, x: CGFloat = 0, y: CGFloat = 4) -> some View {
        self.modifier(AdaptiveShadowModifier(radius: radius, x: x, y: y))
    }
}

struct AdaptiveShadowModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(
                color: colorScheme == .dark ? Color.black.opacity(0.5) : Color.black.opacity(0.15),
                radius: radius,
                x: x,
                y: y
            )
    }
}

// MARK: - Elevation Levels

/// Material Design-inspired elevation system
public enum Elevation {
    case flat
    case low
    case medium
    case high
    case veryHigh
    
    var shadowRadius: CGFloat {
        switch self {
        case .flat: return 0
        case .low: return 4
        case .medium: return 8
        case .high: return 16
        case .veryHigh: return 24
        }
    }
    
    var shadowOffset: CGSize {
        switch self {
        case .flat: return .zero
        case .low: return CGSize(width: 0, height: 2)
        case .medium: return CGSize(width: 0, height: 4)
        case .high: return CGSize(width: 0, height: 8)
        case .veryHigh: return CGSize(width: 0, height: 12)
        }
    }
}

public extension View {
    /// Applies elevation-based shadow
    func elevation(_ level: Elevation) -> some View {
        self.modifier(ElevationModifier(level: level))
    }
}

struct ElevationModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    let level: Elevation
    
    func body(content: Content) -> some View {
        content
            .shadow(
                color: colorScheme == .dark ? Color.black.opacity(0.5) : Color.black.opacity(0.15),
                radius: level.shadowRadius,
                x: level.shadowOffset.width,
                y: level.shadowOffset.height
            )
    }
}

