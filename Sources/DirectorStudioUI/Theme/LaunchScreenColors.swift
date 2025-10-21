//
//  LaunchScreenColors.swift
//  DirectorStudioUI
//
//  🟢 POLISH: Launch screen color configuration for Info.plist
//

import Foundation

/// Launch screen color names for Info.plist configuration
/// These should be added to Assets.xcassets as Color Sets
public enum LaunchScreenColors {
    /// Background color for launch screen (should be dark blue)
    public static let backgroundColorName = "LaunchScreenBackground"
    
    /// Icon tint color for launch screen
    public static let iconColorName = "LaunchScreenIcon"
    
    // Suggested hex values:
    // LaunchScreenBackground - Light: #F5F5F7, Dark: #000000
    // LaunchScreenIcon - Light: #007AFF, Dark: #0A84FF
}

