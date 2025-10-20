//
//  PersistenceManager.swift
//  DirectorStudio
//
//  MODULE: PersistenceManager
//  VERSION: 1.0.0
//  PURPOSE: Data persistence and management system
//

import Foundation

// MARK: - Persistence Manager Protocol

public protocol PersistenceManagerProtocol {
    // Project Management
    func saveProject(_ project: Project) throws -> Project
    func getProject(id: UUID) throws -> Project?
    func getAllProjects() throws -> [Project]
    func deleteProject(id: UUID) throws -> Bool
    
    // Segment Management
    func saveSegments(_ segments: [PromptSegment], projectId: UUID) throws -> [PromptSegment]
    func getSegments(projectId: UUID) throws -> [PromptSegment]
    func deleteSegments(projectId: UUID) throws -> Bool
    
    // Video Management
    func saveVideoMetadata(_ metadata: VideoMetadata, projectId: UUID) throws -> VideoMetadata
    func getVideoMetadata(projectId: UUID) throws -> VideoMetadata?
    func deleteVideoMetadata(projectId: UUID) throws -> Bool
    
    // User Settings
    func saveUserSettings(_ settings: UserSettings) throws -> UserSettings
    func getUserSettings() throws -> UserSettings
    
    // Credits Management
    func saveCreditsBalance(_ credits: Int) throws -> Int
    func getCreditsBalance() throws -> Int
    func updateCreditsBalance(change: Int) throws -> Int
    
    // Export/Import
    func exportProject(id: UUID, to url: URL) throws -> URL
    func importProject(from url: URL) throws -> Project
    
    // Backup/Restore
    func createBackup() throws -> URL
    func restoreFromBackup(url: URL) throws -> Bool
}

// MARK: - User Settings

public struct UserSettings: Codable, Sendable {
    public var defaultVideoQuality: VideoQuality
    public var defaultVideoFormat: VideoFormat
    public var defaultVideoStyle: VideoStyle
    public var defaultOutputDirectory: String
    public var aiServiceEnabled: Bool
    public var telemetryEnabled: Bool
    public var theme: AppTheme
    public var lastOpenedProjectId: UUID?
    
    public init(
        defaultVideoQuality: VideoQuality = .high,
        defaultVideoFormat: VideoFormat = .mp4,
        defaultVideoStyle: VideoStyle = .cinematic,
        defaultOutputDirectory: String = "~/Movies/DirectorStudio",
        aiServiceEnabled: Bool = true,
        telemetryEnabled: Bool = true,
        theme: AppTheme = .system,
        lastOpenedProjectId: UUID? = nil
    ) {
        self.defaultVideoQuality = defaultVideoQuality
        self.defaultVideoFormat = defaultVideoFormat
        self.defaultVideoStyle = defaultVideoStyle
        self.defaultOutputDirectory = defaultOutputDirectory
        self.aiServiceEnabled = aiServiceEnabled
        self.telemetryEnabled = telemetryEnabled
        self.theme = theme
        self.lastOpenedProjectId = lastOpenedProjectId
    }
}

public enum AppTheme: String, Codable, Sendable, CaseIterable {
    case light
    case dark
    case system
}

// MARK: - File-Based Persistence Manager

public class FilePersistenceManager: PersistenceManagerProtocol {
    private let fileManager = FileManager.default
    private let baseDirectory: URL
    
    private let projectsDirectory: URL
    private let segmentsDirectory: URL
    private let videosDirectory: URL
    private let settingsDirectory: URL
    private let backupsDirectory: URL
    
    private let userSettingsFile: URL
    private let creditsFile: URL
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    public init() throws {
        // Set up base directory in Application Support
        let appSupportDirectory = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        
        baseDirectory = appSupportDirectory.appendingPathComponent("DirectorStudio")
        
        // Create subdirectories
        projectsDirectory = baseDirectory.appendingPathComponent("Projects")
        segmentsDirectory = baseDirectory.appendingPathComponent("Segments")
        videosDirectory = baseDirectory.appendingPathComponent("Videos")
        settingsDirectory = baseDirectory.appendingPathComponent("Settings")
        backupsDirectory = baseDirectory.appendingPathComponent("Backups")
        
        // Create settings files
        userSettingsFile = settingsDirectory.appendingPathComponent("UserSettings.json")
        creditsFile = settingsDirectory.appendingPathComponent("Credits.json")
        
        // Ensure directories exist
        try createDirectoryIfNeeded(baseDirectory)
        try createDirectoryIfNeeded(projectsDirectory)
        try createDirectoryIfNeeded(segmentsDirectory)
        try createDirectoryIfNeeded(videosDirectory)
        try createDirectoryIfNeeded(settingsDirectory)
        try createDirectoryIfNeeded(backupsDirectory)
        
        // Initialize settings if needed
        if !fileManager.fileExists(atPath: userSettingsFile.path) {
            try saveUserSettings(UserSettings())
        }
        
        if !fileManager.fileExists(atPath: creditsFile.path) {
            try saveCreditsBalance(100) // Default starting credits
        }
        
        // Configure JSON encoder/decoder
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Project Management
    
    public func saveProject(_ project: Project) throws -> Project {
        let projectFile = projectsDirectory.appendingPathComponent("\(project.id).json")
        let data = try encoder.encode(project)
        try data.write(to: projectFile)
        return project
    }
    
    public func getProject(id: UUID) throws -> Project? {
        let projectFile = projectsDirectory.appendingPathComponent("\(id).json")
        
        guard fileManager.fileExists(atPath: projectFile.path) else {
            return nil
        }
        
        let data = try Data(contentsOf: projectFile)
        return try decoder.decode(Project.self, from: data)
    }
    
    public func getAllProjects() throws -> [Project] {
        let projectFiles = try fileManager.contentsOfDirectory(
            at: projectsDirectory,
            includingPropertiesForKeys: nil
        ).filter { $0.pathExtension == "json" }
        
        var projects: [Project] = []
        
        for file in projectFiles {
            let data = try Data(contentsOf: file)
            let project = try decoder.decode(Project.self, from: data)
            projects.append(project)
        }
        
        return projects.sorted { $0.createdAt > $1.createdAt }
    }
    
    public func deleteProject(id: UUID) throws -> Bool {
        let projectFile = projectsDirectory.appendingPathComponent("\(id).json")
        
        guard fileManager.fileExists(atPath: projectFile.path) else {
            return false
        }
        
        try fileManager.removeItem(at: projectFile)
        
        // Also delete associated segments and video metadata
        try? deleteSegments(projectId: id)
        try? deleteVideoMetadata(projectId: id)
        
        return true
    }
    
    // MARK: - Segment Management
    
    public func saveSegments(_ segments: [PromptSegment], projectId: UUID) throws -> [PromptSegment] {
        let segmentsFile = segmentsDirectory.appendingPathComponent("\(projectId).json")
        let data = try encoder.encode(segments)
        try data.write(to: segmentsFile)
        return segments
    }
    
    public func getSegments(projectId: UUID) throws -> [PromptSegment] {
        let segmentsFile = segmentsDirectory.appendingPathComponent("\(projectId).json")
        
        guard fileManager.fileExists(atPath: segmentsFile.path) else {
            return []
        }
        
        let data = try Data(contentsOf: segmentsFile)
        return try decoder.decode([PromptSegment].self, from: data)
    }
    
    public func deleteSegments(projectId: UUID) throws -> Bool {
        let segmentsFile = segmentsDirectory.appendingPathComponent("\(projectId).json")
        
        guard fileManager.fileExists(atPath: segmentsFile.path) else {
            return false
        }
        
        try fileManager.removeItem(at: segmentsFile)
        return true
    }
    
    // MARK: - Video Management
    
    public func saveVideoMetadata(_ metadata: VideoMetadata, projectId: UUID) throws -> VideoMetadata {
        let videoFile = videosDirectory.appendingPathComponent("\(projectId).json")
        let data = try encoder.encode(metadata)
        try data.write(to: videoFile)
        return metadata
    }
    
    public func getVideoMetadata(projectId: UUID) throws -> VideoMetadata? {
        let videoFile = videosDirectory.appendingPathComponent("\(projectId).json")
        
        guard fileManager.fileExists(atPath: videoFile.path) else {
            return nil
        }
        
        let data = try Data(contentsOf: videoFile)
        return try decoder.decode(VideoMetadata.self, from: data)
    }
    
    public func deleteVideoMetadata(projectId: UUID) throws -> Bool {
        let videoFile = videosDirectory.appendingPathComponent("\(projectId).json")
        
        guard fileManager.fileExists(atPath: videoFile.path) else {
            return false
        }
        
        try fileManager.removeItem(at: videoFile)
        return true
    }
    
    // MARK: - User Settings
    
    public func saveUserSettings(_ settings: UserSettings) throws -> UserSettings {
        let data = try encoder.encode(settings)
        try data.write(to: userSettingsFile)
        return settings
    }
    
    public func getUserSettings() throws -> UserSettings {
        guard fileManager.fileExists(atPath: userSettingsFile.path) else {
            let defaultSettings = UserSettings()
            try saveUserSettings(defaultSettings)
            return defaultSettings
        }
        
        let data = try Data(contentsOf: userSettingsFile)
        return try decoder.decode(UserSettings.self, from: data)
    }
    
    // MARK: - Credits Management
    
    public func saveCreditsBalance(_ credits: Int) throws -> Int {
        let data = try encoder.encode(["credits": credits])
        try data.write(to: creditsFile)
        return credits
    }
    
    public func getCreditsBalance() throws -> Int {
        guard fileManager.fileExists(atPath: creditsFile.path) else {
            return try saveCreditsBalance(100) // Default starting credits
        }
        
        let data = try Data(contentsOf: creditsFile)
        let json = try decoder.decode([String: Int].self, from: data)
        return json["credits"] ?? 0
    }
    
    public func updateCreditsBalance(change: Int) throws -> Int {
        let currentBalance = try getCreditsBalance()
        let newBalance = currentBalance + change
        return try saveCreditsBalance(newBalance)
    }
    
    // MARK: - Export/Import
    
    public func exportProject(id: UUID, to url: URL) throws -> URL {
        let exportURL = url.appendingPathComponent("DirectorStudio_Project_\(id).dsproject")
        
        // Create temporary directory for export
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try createDirectoryIfNeeded(tempDir)
        
        // Copy project file
        if let project = try getProject(id: id) {
            let projectData = try encoder.encode(project)
            let projectFile = tempDir.appendingPathComponent("project.json")
            try projectData.write(to: projectFile)
        } else {
            throw PersistenceError.projectNotFound(id: id)
        }
        
        // Copy segments file
        let segments = try getSegments(projectId: id)
        let segmentsData = try encoder.encode(segments)
        let segmentsFile = tempDir.appendingPathComponent("segments.json")
        try segmentsData.write(to: segmentsFile)
        
        // Copy video metadata if available
        if let videoMetadata = try getVideoMetadata(projectId: id) {
            let videoData = try encoder.encode(videoMetadata)
            let videoFile = tempDir.appendingPathComponent("video.json")
            try videoData.write(to: videoFile)
        }
        
        // Create manifest
        let manifest = ExportManifest(
            version: "1.0.0",
            exportDate: Date(),
            projectId: id,
            hasSegments: !segments.isEmpty,
            hasVideoMetadata: try getVideoMetadata(projectId: id) != nil
        )
        
        let manifestData = try encoder.encode(manifest)
        let manifestFile = tempDir.appendingPathComponent("manifest.json")
        try manifestData.write(to: manifestFile)
        
        // Create zip archive
        try createZipArchive(at: exportURL, from: tempDir)
        
        // Clean up temporary directory
        try fileManager.removeItem(at: tempDir)
        
        return exportURL
    }
    
    public func importProject(from url: URL) throws -> Project {
        // Create temporary directory for import
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try createDirectoryIfNeeded(tempDir)
        
        // Extract zip archive
        try extractZipArchive(from: url, to: tempDir)
        
        // Read manifest
        let manifestFile = tempDir.appendingPathComponent("manifest.json")
        guard fileManager.fileExists(atPath: manifestFile.path) else {
            throw PersistenceError.invalidExportFile
        }
        
        let manifestData = try Data(contentsOf: manifestFile)
        let manifest = try decoder.decode(ExportManifest.self, from: manifestData)
        
        // Read project
        let projectFile = tempDir.appendingPathComponent("project.json")
        guard fileManager.fileExists(atPath: projectFile.path) else {
            throw PersistenceError.invalidExportFile
        }
        
        let projectData = try Data(contentsOf: projectFile)
        var project = try decoder.decode(Project.self, from: projectData)
        
        // Generate new UUID to avoid conflicts
        let originalId = project.id
        project.id = UUID()
        project.name += " (Imported)"
        
        // Save project
        try saveProject(project)
        
        // Import segments if available
        if manifest.hasSegments {
            let segmentsFile = tempDir.appendingPathComponent("segments.json")
            if fileManager.fileExists(atPath: segmentsFile.path) {
                let segmentsData = try Data(contentsOf: segmentsFile)
                let segments = try decoder.decode([PromptSegment].self, from: segmentsData)
                try saveSegments(segments, projectId: project.id)
            }
        }
        
        // Import video metadata if available
        if manifest.hasVideoMetadata {
            let videoFile = tempDir.appendingPathComponent("video.json")
            if fileManager.fileExists(atPath: videoFile.path) {
                let videoData = try Data(contentsOf: videoFile)
                let videoMetadata = try decoder.decode(VideoMetadata.self, from: videoData)
                try saveVideoMetadata(videoMetadata, projectId: project.id)
            }
        }
        
        // Clean up temporary directory
        try fileManager.removeItem(at: tempDir)
        
        return project
    }
    
    // MARK: - Backup/Restore
    
    public func createBackup() throws -> URL {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let backupURL = backupsDirectory.appendingPathComponent("DirectorStudio_Backup_\(timestamp).dsbackup")
        
        // Create temporary directory for backup
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try createDirectoryIfNeeded(tempDir)
        
        // Copy all projects
        let projectsBackupDir = tempDir.appendingPathComponent("Projects")
        try createDirectoryIfNeeded(projectsBackupDir)
        
        let projectFiles = try fileManager.contentsOfDirectory(
            at: projectsDirectory,
            includingPropertiesForKeys: nil
        ).filter { $0.pathExtension == "json" }
        
        for file in projectFiles {
            let destination = projectsBackupDir.appendingPathComponent(file.lastPathComponent)
            try fileManager.copyItem(at: file, to: destination)
        }
        
        // Copy all segments
        let segmentsBackupDir = tempDir.appendingPathComponent("Segments")
        try createDirectoryIfNeeded(segmentsBackupDir)
        
        let segmentFiles = try fileManager.contentsOfDirectory(
            at: segmentsDirectory,
            includingPropertiesForKeys: nil
        ).filter { $0.pathExtension == "json" }
        
        for file in segmentFiles {
            let destination = segmentsBackupDir.appendingPathComponent(file.lastPathComponent)
            try fileManager.copyItem(at: file, to: destination)
        }
        
        // Copy all video metadata
        let videosBackupDir = tempDir.appendingPathComponent("Videos")
        try createDirectoryIfNeeded(videosBackupDir)
        
        let videoFiles = try fileManager.contentsOfDirectory(
            at: videosDirectory,
            includingPropertiesForKeys: nil
        ).filter { $0.pathExtension == "json" }
        
        for file in videoFiles {
            let destination = videosBackupDir.appendingPathComponent(file.lastPathComponent)
            try fileManager.copyItem(at: file, to: destination)
        }
        
        // Copy settings
        let settingsBackupDir = tempDir.appendingPathComponent("Settings")
        try createDirectoryIfNeeded(settingsBackupDir)
        
        if fileManager.fileExists(atPath: userSettingsFile.path) {
            let destination = settingsBackupDir.appendingPathComponent(userSettingsFile.lastPathComponent)
            try fileManager.copyItem(at: userSettingsFile, to: destination)
        }
        
        if fileManager.fileExists(atPath: creditsFile.path) {
            let destination = settingsBackupDir.appendingPathComponent(creditsFile.lastPathComponent)
            try fileManager.copyItem(at: creditsFile, to: destination)
        }
        
        // Create manifest
        let manifest = BackupManifest(
            version: "1.0.0",
            backupDate: Date(),
            projectCount: projectFiles.count,
            segmentCount: segmentFiles.count,
            videoCount: videoFiles.count
        )
        
        let manifestData = try encoder.encode(manifest)
        let manifestFile = tempDir.appendingPathComponent("manifest.json")
        try manifestData.write(to: manifestFile)
        
        // Create zip archive
        try createZipArchive(at: backupURL, from: tempDir)
        
        // Clean up temporary directory
        try fileManager.removeItem(at: tempDir)
        
        return backupURL
    }
    
    public func restoreFromBackup(url: URL) throws -> Bool {
        // Create temporary directory for restore
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try createDirectoryIfNeeded(tempDir)
        
        // Extract zip archive
        try extractZipArchive(from: url, to: tempDir)
        
        // Read manifest
        let manifestFile = tempDir.appendingPathComponent("manifest.json")
        guard fileManager.fileExists(atPath: manifestFile.path) else {
            throw PersistenceError.invalidBackupFile
        }
        
        let manifestData = try Data(contentsOf: manifestFile)
        let manifest = try decoder.decode(BackupManifest.self, from: manifestData)
        
        // Verify backup structure
        let projectsBackupDir = tempDir.appendingPathComponent("Projects")
        let segmentsBackupDir = tempDir.appendingPathComponent("Segments")
        let videosBackupDir = tempDir.appendingPathComponent("Videos")
        let settingsBackupDir = tempDir.appendingPathComponent("Settings")
        
        guard fileManager.fileExists(atPath: projectsBackupDir.path) else {
            throw PersistenceError.invalidBackupFile
        }
        
        // Clear current data
        try clearDirectory(projectsDirectory)
        try clearDirectory(segmentsDirectory)
        try clearDirectory(videosDirectory)
        
        // Restore projects
        let projectFiles = try fileManager.contentsOfDirectory(
            at: projectsBackupDir,
            includingPropertiesForKeys: nil
        ).filter { $0.pathExtension == "json" }
        
        for file in projectFiles {
            let destination = projectsDirectory.appendingPathComponent(file.lastPathComponent)
            try fileManager.copyItem(at: file, to: destination)
        }
        
        // Restore segments if available
        if fileManager.fileExists(atPath: segmentsBackupDir.path) {
            let segmentFiles = try fileManager.contentsOfDirectory(
                at: segmentsBackupDir,
                includingPropertiesForKeys: nil
            ).filter { $0.pathExtension == "json" }
            
            for file in segmentFiles {
                let destination = segmentsDirectory.appendingPathComponent(file.lastPathComponent)
                try fileManager.copyItem(at: file, to: destination)
            }
        }
        
        // Restore video metadata if available
        if fileManager.fileExists(atPath: videosBackupDir.path) {
            let videoFiles = try fileManager.contentsOfDirectory(
                at: videosBackupDir,
                includingPropertiesForKeys: nil
            ).filter { $0.pathExtension == "json" }
            
            for file in videoFiles {
                let destination = videosDirectory.appendingPathComponent(file.lastPathComponent)
                try fileManager.copyItem(at: file, to: destination)
            }
        }
        
        // Restore settings if available
        if fileManager.fileExists(atPath: settingsBackupDir.path) {
            let userSettingsBackupFile = settingsBackupDir.appendingPathComponent(userSettingsFile.lastPathComponent)
            if fileManager.fileExists(atPath: userSettingsBackupFile.path) {
                try fileManager.removeItem(at: userSettingsFile)
                try fileManager.copyItem(at: userSettingsBackupFile, to: userSettingsFile)
            }
            
            let creditsBackupFile = settingsBackupDir.appendingPathComponent(creditsFile.lastPathComponent)
            if fileManager.fileExists(atPath: creditsBackupFile.path) {
                try fileManager.removeItem(at: creditsFile)
                try fileManager.copyItem(at: creditsBackupFile, to: creditsFile)
            }
        }
        
        // Clean up temporary directory
        try fileManager.removeItem(at: tempDir)
        
        return true
    }
    
    // MARK: - Helper Methods
    
    private func createDirectoryIfNeeded(_ url: URL) throws {
        if !fileManager.fileExists(atPath: url.path) {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }
    
    private func clearDirectory(_ url: URL) throws {
        let contents = try fileManager.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: nil
        )
        
        for item in contents {
            try fileManager.removeItem(at: item)
        }
    }
    
    private func createZipArchive(at destination: URL, from source: URL) throws {
        // This is a placeholder for actual zip creation
        // In a real implementation, you would use a zip library or process
        
        // For now, we'll just copy the directory
        if fileManager.fileExists(atPath: destination.path) {
            try fileManager.removeItem(at: destination)
        }
        
        try fileManager.copyItem(at: source, to: destination)
    }
    
    private func extractZipArchive(from source: URL, to destination: URL) throws {
        // This is a placeholder for actual zip extraction
        // In a real implementation, you would use a zip library or process
        
        // For now, we'll just copy the directory
        if fileManager.fileExists(atPath: destination.path) {
            try fileManager.removeItem(at: destination)
        }
        
        try fileManager.copyItem(at: source, to: destination)
    }
}

// MARK: - Supporting Types

public struct ExportManifest: Codable {
    public let version: String
    public let exportDate: Date
    public let projectId: UUID
    public let hasSegments: Bool
    public let hasVideoMetadata: Bool
}

public struct BackupManifest: Codable {
    public let version: String
    public let backupDate: Date
    public let projectCount: Int
    public let segmentCount: Int
    public let videoCount: Int
}

public enum PersistenceError: Error, LocalizedError {
    case projectNotFound(id: UUID)
    case invalidExportFile
    case invalidBackupFile
    case zipCreationFailed
    case zipExtractionFailed
    
    public var errorDescription: String? {
        switch self {
        case .projectNotFound(let id):
            return "Project not found with ID: \(id)"
        case .invalidExportFile:
            return "Invalid export file format"
        case .invalidBackupFile:
            return "Invalid backup file format"
        case .zipCreationFailed:
            return "Failed to create zip archive"
        case .zipExtractionFailed:
            return "Failed to extract zip archive"
        }
    }
}
