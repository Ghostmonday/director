import Foundation

class Analytics {
    static let shared = Analytics()
    
    private init() {}
    
    func track(event: String, properties: [String: Any]? = nil) {
        #if DEBUG
        print("📊 Analytics Event: \(event)")
        if let properties = properties {
            print("   Properties: \(properties)")
        }
        #endif
        
        // In production, send to analytics service
        #if !DEBUG
        // Send to analytics backend
        #endif
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
}