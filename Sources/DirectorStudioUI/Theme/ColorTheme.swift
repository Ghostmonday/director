//
//  ColorTheme.swift
//  DirectorStudioUI
//
//  🟢 POLISH: Dark Mode optimization with adaptive colors
//  Ensures beautiful appearance in both light and dark modes
//

import SwiftUI

/// DirectorStudio adaptive color theme
public struct DSColors {
    
    // MARK: - Primary Brand Colors
    
    /// Primary brand color (adapts to dark mode)
    public static let primary = Color.blue
    
    /// Secondary brand color
    public static let secondary = Color.purple
    
    /// Accent color for highlights
    public static let accent = Color.orange
    
    // MARK: - Background Colors
    
    /// Primary background (pure white/black in light/dark)
    public static let background = Color(uiColor: .systemBackground)
    
    /// Secondary background (slightly darker/lighter)
    public static let backgroundSecondary = Color(uiColor: .secondarySystemBackground)
    
    /// Tertiary background (even more contrast)
    public static let backgroundTertiary = Color(uiColor: .tertiarySystemBackground)
    
    /// Grouped background (for lists)
    public static let backgroundGrouped = Color(uiColor: .systemGroupedBackground)
    
    // MARK: - Content Colors
    
    /// Primary text color
    public static let text = Color(uiColor: .label)
    
    /// Secondary text color (less emphasis)
    public static let textSecondary = Color(uiColor: .secondaryLabel)
    
    /// Tertiary text color (even less emphasis)
    public static let textTertiary = Color(uiColor: .tertiaryLabel)
    
    /// Quaternary text color (disabled states)
    public static let textQuaternary = Color(uiColor: .quaternaryLabel)
    
    // MARK: - Separator Colors
    
    /// Standard separator line
    public static let separator = Color(uiColor: .separator)
    
    /// Opaque separator (always visible)
    public static let separatorOpaque = Color(uiColor: .opaqueSeparator)
    
    // MARK: - System Grays (Adaptive)
    
    public static let gray1 = Color(uiColor: .systemGray)
    public static let gray2 = Color(uiColor: .systemGray2)
    public static let gray3 = Color(uiColor: .systemGray3)
    public static let gray4 = Color(uiColor: .systemGray4)
    public static let gray5 = Color(uiColor: .systemGray5)
    public static let gray6 = Color(uiColor: .systemGray6)
    
    // MARK: - Semantic Colors
    
    /// Success/positive state
    public static let success = Color.green
    
    /// Warning/caution state
    public static let warning = Color.orange
    
    /// Error/destructive state
    public static let error = Color.red
    
    /// Info/neutral state
    public static let info = Color.blue
    
    // MARK: - Component-Specific Colors
    
    /// Card background
    public static let cardBackground = Color(uiColor: .systemGray6)
    
    /// Input field background
    public static let inputBackground = Color(uiColor: .systemGray6)
    
    /// Button primary background
    public static let buttonPrimary = Color.blue
    
    /// Button secondary background
    public static let buttonSecondary = Color(uiColor: .systemGray4)
    
    // MARK: - Gradient Colors
    
    /// Primary gradient (for floating buttons, etc.)
    public static let gradientStart = Color.blue
    public static let gradientEnd = Color.blue.opacity(0.8)
    
    /// Success gradient
    public static let gradientSuccessStart = Color.green
    public static let gradientSuccessEnd = Color.green.opacity(0.8)
    
    /// Warning gradient
    public static let gradientWarningStart = Color.orange
    public static let gradientWarningEnd = Color.orange.opacity(0.8)
}

// MARK: - Gradient Extensions

public extension LinearGradient {
    /// Primary gradient for buttons
    static let primaryButton = LinearGradient(
        gradient: Gradient(colors: [DSColors.gradientStart, DSColors.gradientEnd]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Success gradient
    static let success = LinearGradient(
        gradient: Gradient(colors: [DSColors.gradientSuccessStart, DSColors.gradientSuccessEnd]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Warning gradient
    static let warning = LinearGradient(
        gradient: Gradient(colors: [DSColors.gradientWarningStart, DSColors.gradientWarningEnd]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - View Extension for Themed Backgrounds

public extension View {
    /// Applies adaptive card background
    func cardBackground() -> some View {
        self.background(DSColors.cardBackground)
    }
    
    /// Applies adaptive input background
    func inputBackground() -> some View {
        self.background(DSColors.inputBackground)
    }
    
    /// Applies primary background
    func primaryBackground() -> some View {
        self.background(DSColors.background)
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

