//
//  ExportManager.swift
//  DirectorStudio
//
//  MODULE: ExportManager
//  VERSION: 1.0.0
//  PURPOSE: Clean, testable export orchestrator for video clips
//

import Foundation
import AVFoundation
import Combine

@available(iOS 15.0, *)
@MainActor
public class ExportManager: ObservableObject {
    @Published public var exportProgress: Double = 0.0
    @Published public var isExporting: Bool = false
    @Published public var exportStatus: ExportStatus = .idle
    
    private let telemetry = Telemetry.shared
    private var cancellables = Set<AnyCancellable>()
    
    public enum ExportStatus {
        case idle
        case preparing
        case exporting
        case completed
        case failed(Error)
    }
    
    public init() {}
    
    @available(iOS 15.0, *)
    public func exportClips(_ clips: [ClipModel]) async throws {
        guard !clips.isEmpty else {
            throw ExportError.noClipsToExport
        }
        
        await MainActor.run {
            isExporting = true
            exportProgress = 0.0
            exportStatus = .preparing
        }
        
        telemetry.logEvent("export_started", properties: ["clip_count": clips.count])
        
        do {
            let exportURL = try await performExport(clips)
            
            await MainActor.run {
                exportProgress = 1.0
                exportStatus = .completed
                isExporting = false
            }
            
            telemetry.logEvent("export_completed", properties: [
                "clip_count": clips.count,
                "output_url": exportURL.absoluteString
            ])
            
        } catch {
            await MainActor.run {
                exportStatus = .failed(error)
                isExporting = false
            }
            
            telemetry.logEvent("export_failed", properties: [
                "error": error.localizedDescription,
                "clip_count": clips.count
            ])
            
            throw error
        }
    }
    
    @available(iOS 15.0, *)
    private func performExport(_ clips: [ClipModel]) async throws -> URL {
        let composition = AVMutableComposition()
        let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        var currentTime = CMTime.zero
        let totalClips = clips.count
        
        for (index, clip) in clips.enumerated() {
            let asset = AVAsset(url: clip.url)
            
            guard let videoAssetTrack = try await asset.loadTracks(withMediaType: .video).first,
                  let audioAssetTrack = try await asset.loadTracks(withMediaType: .audio).first else {
                throw ExportError.invalidClip(clip.id)
            }
            
            let timeRange = CMTimeRange(start: .zero, duration: try await asset.load(.duration))
            
            try videoTrack?.insertTimeRange(timeRange, of: videoAssetTrack, at: currentTime)
            try audioTrack?.insertTimeRange(timeRange, of: audioAssetTrack, at: currentTime)
            
            currentTime = CMTimeAdd(currentTime, timeRange.duration)
            
            let progress = Double(index + 1) / Double(totalClips)
            await MainActor.run {
                exportProgress = progress
                exportStatus = .exporting
            }
        }
        
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("exported_video_\(UUID().uuidString).mp4")
        
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            throw ExportError.exportSessionCreationFailed
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        
        return try await withCheckedThrowingContinuation { continuation in
            exportSession.exportAsynchronously {
                switch exportSession.status {
                case .completed:
                    continuation.resume(returning: outputURL)
                case .failed:
                    continuation.resume(throwing: exportSession.error ?? ExportError.exportFailed)
                case .cancelled:
                    continuation.resume(throwing: ExportError.exportCancelled)
                default:
                    continuation.resume(throwing: ExportError.exportFailed)
                }
            }
        }
    }
}

public struct ClipModel: Identifiable, Sendable {
    public let id: UUID
    public let url: URL
    public let duration: TimeInterval
    public let title: String
    
    public init(id: UUID = UUID(), url: URL, duration: TimeInterval, title: String) {
        self.id = id
        self.url = url
        self.duration = duration
        self.title = title
    }
}

public enum ExportError: LocalizedError {
    case noClipsToExport
    case invalidClip(UUID)
    case exportSessionCreationFailed
    case exportFailed
    case exportCancelled
    
    public var errorDescription: String? {
        switch self {
        case .noClipsToExport:
            return "No clips to export"
        case .invalidClip(let id):
            return "Invalid clip: \(id)"
        case .exportSessionCreationFailed:
            return "Failed to create export session"
        case .exportFailed:
            return "Export failed"
        case .exportCancelled:
            return "Export cancelled"
        }
    }
}
