#if canImport(UIKit)
import UIKit

public class HapticManager {
    public static let shared = HapticManager()
    
    private init() {}
    
    public func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    public func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    public func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}
#else
// macOS fallback - no haptic feedback available
public class HapticManager {
    public static let shared = HapticManager()
    
    private init() {}
    
    public func impact(_ style: Any) {
        // No-op on macOS
    }
    
    public func notification(_ type: Any) {
        // No-op on macOS
    }
    
    public func selection() {
        // No-op on macOS
    }
}
#endif