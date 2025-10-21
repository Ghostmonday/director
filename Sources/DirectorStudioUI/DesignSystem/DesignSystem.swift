//
//  DesignSystem.swift
//  DirectorStudioUI
//
//  🚨 UX Fix #15: Custom Design System with brand colors and components
//

import SwiftUI

/// DirectorStudio Design System - Colors, Typography, Spacing, and Styles
public enum DesignSystem {
    
    // MARK: - Colors
    
    public enum Colors {
        // Primary brand colors
        public static let primary = Color(hex: "2D5BFF")
        public static let primaryDark = Color(hex: "1A3FCC")
        public static let primaryLight = Color(hex: "5B8CFF")
        
        // Secondary colors
        public static let secondary = Color(hex: "7F8C9F")
        public static let accent = Color(hex: "FF6B6B")
        
        // Status colors
        public static let success = Color(hex: "51CF66")
        public static let warning = Color(hex: "FFA94D")
        public static let error = Color(hex: "FF6B6B")
        public static let info = Color(hex: "4DABF7")
        
        // Neutral colors
        public static let background = Color(hex: "F8F9FA")
        public static let surface = Color.white
        public static let surfaceElevated = Color(hex: "FFFFFF")
        
        // Cinematic theme colors
        public static let cinematicGold = Color(hex: "FFD700")
        public static let cinematicBlack = Color(hex: "1A1A1A")
        public static let directorChair = Color(hex: "FDB813")
    }
    
    // MARK: - Typography
    
    public enum Typography {
        public static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        public static let title = Font.system(size: 28, weight: .bold, design: .rounded)
        public static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
        public static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
        public static let subheadline = Font.system(size: 15, weight: .medium, design: .rounded)
        public static let body = Font.system(size: 17, design: .default)
        public static let callout = Font.system(size: 16, design: .default)
        public static let caption = Font.system(size: 12, design: .default)
        public static let caption2 = Font.system(size: 11, design: .default)
    }
    
    // MARK: - Spacing
    
    public enum Spacing {
        public static let xs: CGFloat = 4
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 16
        public static let lg: CGFloat = 24
        public static let xl: CGFloat = 32
        public static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    
    public enum Radius {
        public static let sm: CGFloat = 6
        public static let md: CGFloat = 12
        public static let lg: CGFloat = 16
        public static let xl: CGFloat = 24
        public static let round: CGFloat = 999
    }
    
    // MARK: - Shadows
    
    public enum Shadow {
        public static let sm = (color: Color.black.opacity(0.05), radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
        public static let md = (color: Color.black.opacity(0.1), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
        public static let lg = (color: Color.black.opacity(0.15), radius: CGFloat(12), x: CGFloat(0), y: CGFloat(6))
    }
}

// MARK: - Color Extension for Hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Custom Button Styles

public struct PrimaryButtonStyle: ButtonStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.headline)
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                    .fill(DesignSystem.Colors.primary)
                    .shadow(
                        color: DesignSystem.Colors.primary.opacity(0.3),
                        radius: configuration.isPressed ? 4 : 8,
                        y: configuration.isPressed ? 2 : 4
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
    }
}

public struct SecondaryButtonStyle: ButtonStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.headline)
            .foregroundColor(DesignSystem.Colors.primary)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                    .stroke(DesignSystem.Colors.primary, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
    }
}

// MARK: - View Modifiers

public struct CardModifier: ViewModifier {
    public init() {}
    
    public func body(content: Content) -> some View {
        content
            .padding(DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.surface)
            .cornerRadius(DesignSystem.Radius.md)
            .shadow(
                color: DesignSystem.Shadow.md.color,
                radius: DesignSystem.Shadow.md.radius,
                x: DesignSystem.Shadow.md.x,
                y: DesignSystem.Shadow.md.y
            )
    }
}

public struct ElevatedCardModifier: ViewModifier {
    public init() {}
    
    public func body(content: Content) -> some View {
        content
            .padding(DesignSystem.Spacing.lg)
            .background(DesignSystem.Colors.surfaceElevated)
            .cornerRadius(DesignSystem.Radius.lg)
            .shadow(
                color: DesignSystem.Shadow.lg.color,
                radius: DesignSystem.Shadow.lg.radius,
                x: DesignSystem.Shadow.lg.x,
                y: DesignSystem.Shadow.lg.y
            )
    }
}

// MARK: - View Extensions

extension View {
    /// Apply card style
    public func cardStyle() -> some View {
        modifier(CardModifier())
    }
    
    /// Apply elevated card style
    public func elevatedCardStyle() -> some View {
        modifier(ElevatedCardModifier())
    }
    
    /// Apply primary button style
    public func primaryButtonStyle() -> some View {
        buttonStyle(PrimaryButtonStyle())
    }
    
    /// Apply secondary button style
    public func secondaryButtonStyle() -> some View {
        buttonStyle(SecondaryButtonStyle())
    }
}

// MARK: - Cinematic Components

/// Cinematic-themed section header
public struct CinematicHeader: View {
    let title: String
    let subtitle: String?
    
    public init(title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                Image(systemName: "film.fill")
                    .foregroundColor(DesignSystem.Colors.cinematicGold)
                Text(title)
                    .font(DesignSystem.Typography.title2)
                    .fontWeight(.bold)
            }
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Status badge component
public struct StatusBadge: View {
    let text: String
    let type: BadgeType
    
    public enum BadgeType {
        case success, warning, error, info, neutral
        
        var color: Color {
            switch self {
            case .success: return DesignSystem.Colors.success
            case .warning: return DesignSystem.Colors.warning
            case .error: return DesignSystem.Colors.error
            case .info: return DesignSystem.Colors.info
            case .neutral: return DesignSystem.Colors.secondary
            }
        }
    }
    
    public init(text: String, type: BadgeType) {
        self.text = text
        self.type = type
    }
    
    public var body: some View {
        Text(text)
            .font(DesignSystem.Typography.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(type.color.opacity(0.15))
            .foregroundColor(type.color)
            .cornerRadius(DesignSystem.Radius.sm)
    }
}

// MARK: - Preview
struct DesignSystem_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                CinematicHeader(
                    title: "Design System",
                    subtitle: "DirectorStudio brand components"
                )
                
                VStack(spacing: DesignSystem.Spacing.md) {
                    Text("Primary Colors")
                        .font(DesignSystem.Typography.headline)
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        DesignSystem.Colors.primary.frame(width: 50, height: 50).cornerRadius(DesignSystem.Radius.sm)
                        DesignSystem.Colors.accent.frame(width: 50, height: 50).cornerRadius(DesignSystem.Radius.sm)
                        DesignSystem.Colors.success.frame(width: 50, height: 50).cornerRadius(DesignSystem.Radius.sm)
                    }
                }
                .cardStyle()
                
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Button("Primary Button") {}
                        .primaryButtonStyle()
                    
                    Button("Secondary Button") {}
                        .secondaryButtonStyle()
                }
                
                HStack(spacing: DesignSystem.Spacing.sm) {
                    StatusBadge(text: "Success", type: .success)
                    StatusBadge(text: "Warning", type: .warning)
                    StatusBadge(text: "Error", type: .error)
                }
                
                VStack {
                    Text("Elevated Card")
                        .font(DesignSystem.Typography.headline)
                    Text("This card has more prominent elevation")
                        .font(DesignSystem.Typography.caption)
                }
                .elevatedCardStyle()
            }
            .padding()
        }
    }
}

