import Foundation
import UIKit

/// 🟢 POLISH: Enhanced analytics tracking system
class Analytics {
    static let shared = Analytics()
    
    private var sessionStartTime: Date?
    private var eventBuffer: [[String: Any]] = []
    
    private init() {
        sessionStartTime = Date()
        trackSessionStart()
    }
    
    // MARK: - Core Tracking
    
    func track(event: String, properties: [String: Any]? = nil) {
        var enrichedProperties = properties ?? [:]
        
        // Enrich with device context
        enrichedProperties["device_model"] = UIDevice.current.model
        enrichedProperties["os_version"] = UIDevice.current.systemVersion
        enrichedProperties["app_version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        enrichedProperties["session_duration"] = sessionDuration
        enrichedProperties["timestamp"] = Date().timeIntervalSince1970
        
        #if DEBUG
        print("📊 Analytics Event: \(event)")
        if !enrichedProperties.isEmpty {
            print("   Properties: \(enrichedProperties)")
        }
        #endif
        
        // Buffer events for batch upload
        eventBuffer.append([
            "event": event,
            "properties": enrichedProperties
        ])
        
        // In production, send to analytics service
        #if !DEBUG
        sendToAnalyticsBackend(event: event, properties: enrichedProperties)
        #endif
    }
    
    private var sessionDuration: TimeInterval {
        guard let start = sessionStartTime else { return 0 }
        return Date().timeIntervalSince(start)
    }
    
    private func sendToAnalyticsBackend(event: String, properties: [String: Any]) {
        // TODO: Integrate with analytics service (Firebase, Mixpanel, etc.)
        // For now, this is a placeholder
    }
    
    func trackExport(type: String, success: Bool, duration: TimeInterval) {
        track(event: "export_completed", properties: [
            "type": type,
            "success": success,
            "duration": duration,
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    func trackPipelineRun(modules: [String], duration: TimeInterval) {
        track(event: "pipeline_run", properties: [
            "modules": modules,
            "module_count": modules.count,
            "duration": duration,
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    func trackVideoGeneration(quality: String, duration: Double, success: Bool) {
        track(event: "video_generated", properties: [
            "quality": quality,
            "duration": duration,
            "success": success,
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    func trackUserAction(action: String, context: String? = nil) {
        track(event: "user_action", properties: [
            "action": action,
            "context": context ?? "unknown",
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    // MARK: - 🟢 POLISH: Enhanced Tracking Methods
    
    /// Track app session start
    func trackSessionStart() {
        track(event: "session_start", properties: [
            "device_type": UIDevice.current.userInterfaceIdiom == .pad ? "iPad" : "iPhone"
        ])
    }
    
    /// Track app session end
    func trackSessionEnd() {
        track(event: "session_end", properties: [
            "duration": sessionDuration
        ])
    }
    
    /// Track screen view
    func trackScreenView(screenName: String) {
        track(event: "screen_view", properties: [
            "screen_name": screenName
        ])
    }
    
    /// Track feature usage
    func trackFeatureUsed(feature: String, details: [String: Any]? = nil) {
        var props = details ?? [:]
        props["feature"] = feature
        track(event: "feature_used", properties: props)
    }
    
    /// Track error
    func trackError(error: Error, context: String) {
        track(event: "error_occurred", properties: [
            "error_description": error.localizedDescription,
            "context": context
        ])
    }
    
    /// Track purchase attempt
    func trackPurchaseAttempt(packageName: String, price: String) {
        track(event: "purchase_attempt", properties: [
            "package": packageName,
            "price": price
        ])
    }
    
    /// Track purchase complete
    func trackPurchaseComplete(packageName: String, credits: Int, price: String) {
        track(event: "purchase_complete", properties: [
            "package": packageName,
            "credits": credits,
            "price": price
        ])
    }
    
    /// Track module toggle
    func trackModuleToggled(moduleName: String, enabled: Bool) {
        track(event: "module_toggled", properties: [
            "module": moduleName,
            "enabled": enabled
        ])
    }
    
    /// Track segment action
    func trackSegmentAction(action: String, segmentCount: Int) {
        track(event: "segment_action", properties: [
            "action": action,
            "segment_count": segmentCount
        ])
    }
    
    /// Flush event buffer (call on app background)
    func flush() {
        #if !DEBUG
        // Send buffered events
        for event in eventBuffer {
            // Send to backend
        }
        #endif
        eventBuffer.removeAll()
    }
}