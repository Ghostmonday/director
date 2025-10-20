//
//  VideoLibraryView.swift
//  DirectorStudioUI
//
//  Created by DirectorStudio on $(date)
//  Copyright © 2025 DirectorStudio. All rights reserved.
//

import SwiftUI

/// Video Library & Management UI
struct VideoLibraryView: View {
    @State private var videos: [GUIVideo] = []
    @State private var searchText: String = ""
    @State private var selectedSortOption: SortOption = .dateCreated
    @State private var viewMode: ViewMode = .grid
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var selectedVideo: GUIVideo?
    @State private var showingVideoPlayer: Bool = false
    
    enum SortOption: String, CaseIterable {
        case name = "Name"
        case dateCreated = "Date Created"
        case size = "File Size"
        case duration = "Duration"
    }
    
    enum ViewMode: String, CaseIterable {
        case grid = "Grid"
        case list = "List"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Toolbar
                toolbarSection
                
                // Content
                if isLoading {
                    loadingView
                } else if filteredVideos.isEmpty {
                    emptyStateView
                } else {
                    videoContentView
                }
            }
            .navigationTitle("Video Library")
            .sheet(isPresented: $showingVideoPlayer) {
                if let video = selectedVideo {
                    VideoPlayerView(video: video)
                }
            }
            .onAppear {
                loadVideos()
            }
        }
    }
    
    // MARK: - Toolbar Section
    
    private var toolbarSection: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search videos...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button { searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color.systemGray6)
            .cornerRadius(10)
            
            // Controls
            HStack {
                // Sort Options
                Picker("Sort", selection: $selectedSortOption) {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                Spacer()
                
                // View Mode Toggle
                Picker("View", selection: $viewMode) {
                    ForEach(ViewMode.allCases, id: \.self) { mode in
                        Image(systemName: mode == .grid ? "square.grid.2x2" : "list.bullet").tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 100)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    // MARK: - Video Content View
    
    private var videoContentView: some View {
        ScrollView {
            if viewMode == .grid {
                gridView
            } else {
                listView
            }
        }
    }
    
    // MARK: - Grid View
    
    private var gridView: some View {
        LazyVGrid(columns: [
            GridItem(.adaptive(minimum: 200), spacing: 16)
        ], spacing: 16) {
            ForEach(sortedVideos, id: \.id) { video in
                VideoGridItemView(video: video) {
                    selectedVideo = video
                    showingVideoPlayer = true
                }
            }
        }
        .padding()
    }
    
    // MARK: - List View
    
    private var listView: some View {
        LazyVStack(spacing: 8) {
            ForEach(sortedVideos, id: \.id) { video in
                VideoListItemView(video: video) {
                    selectedVideo = video
                    showingVideoPlayer = true
                }
            }
        }
        .padding()
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading videos...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "video.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Videos Found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(searchText.isEmpty ? 
                 "Generate your first video to see it here" : 
                 "No videos match your search")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - Computed Properties
    
    private var filteredVideos: [GUIVideo] {
        if searchText.isEmpty {
            return videos
        } else {
            return videos.filter { video in
                video.title.localizedCaseInsensitiveContains(searchText) ||
                video.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private var sortedVideos: [GUIVideo] {
        filteredVideos.sorted { video1, video2 in
            switch selectedSortOption {
            case .name:
                return video1.title < video2.title
            case .dateCreated:
                return video1.createdAt > video2.createdAt
            case .size:
                return video1.fileSize > video2.fileSize
            case .duration:
                return video1.duration > video2.duration
            }
        }
    }
    
    // MARK: - Actions
    
    private func loadVideos() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Simulate loading videos
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                
                // Mock data for now
                let mockVideos = [
                    GUIVideo(
                        id: UUID(),
                        title: "Sample Video 1",
                        description: "A sample video generated from a story",
                        url: URL(string: "https://example.com/video1.mp4")!,
                        thumbnailURL: URL(string: "https://example.com/thumb1.jpg")!,
                        duration: 120.0,
                        fileSize: 15_000_000,
                        resolution: CGSize(width: 1920, height: 1080),
                        createdAt: Date().addingTimeInterval(-86400),
                        tags: ["cinematic", "drama"]
                    ),
                    GUIVideo(
                        id: UUID(),
                        title: "Sample Video 2",
                        description: "Another sample video with different style",
                        url: URL(string: "https://example.com/video2.mp4")!,
                        thumbnailURL: URL(string: "https://example.com/thumb2.jpg")!,
                        duration: 90.0,
                        fileSize: 12_000_000,
                        resolution: CGSize(width: 1920, height: 1080),
                        createdAt: Date().addingTimeInterval(-172800),
                        tags: ["action", "thriller"]
                    )
                ]
                
                await MainActor.run {
                    videos = mockVideos
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

/// Video Grid Item View
struct VideoGridItemView: View {
    let video: GUIVideo
    let onTap: () -> Void
    @State private var showingActionSheet: Bool = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Thumbnail
                AsyncImage(url: video.thumbnailURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .overlay(
                            VStack {
                                Image(systemName: "video.fill")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                                Text("Loading...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        )
                }
                .frame(height: 120)
                .clipped()
                .cornerRadius(8)
                .overlay(
                    // Duration Badge
                    VStack {
                        HStack {
                            Spacer()
                            Text(formatDuration(video.duration))
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.black.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(4)
                                .padding(8)
                        }
                        Spacer()
                    }
                )
                
                // Video Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(video.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text(video.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Text(video.createdAt, style: .relative)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(formatFileSize(video.fileSize))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Tags
                if !video.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(video.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(4)
                            }
                        }
                        .padding(.horizontal, 1)
                    }
                }
            }
            .padding()
            .background(Color.systemBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.systemGray4, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button(action: {}) {
                Label("Play", systemImage: "play.fill")
            }
            
            Button(action: {}) {
                Label("Export", systemImage: "square.and.arrow.up")
            }
            
            Button(action: {}) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            
            Divider()
            
            Button(role: .destructive, action: {}) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private func formatDuration(_ duration: Double) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func formatFileSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

/// Video List Item View
struct VideoListItemView: View {
    let video: GUIVideo
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Thumbnail
                AsyncImage(url: video.thumbnailURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray5))
                        .overlay(
                            Image(systemName: "video.fill")
                                .foregroundColor(.secondary)
                        )
                }
                .frame(width: 80, height: 60)
                .clipped()
                .cornerRadius(6)
                
                // Video Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(video.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(video.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Text(formatDuration(video.duration))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(formatFileSize(video.fileSize))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(video.createdAt, style: .relative)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Play Button
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color.systemBackground)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.systemGray4, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDuration(_ duration: Double) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func formatFileSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

/// Video Player View
struct VideoPlayerView: View {
    let video: GUIVideo
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Video Player Placeholder
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.black)
                    .frame(height: 250)
                    .overlay(
                        VStack {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                            
                            Text("Video Player")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    )
                
                // Video Info
                VStack(alignment: .leading, spacing: 12) {
                    Text(video.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(video.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("Duration: \(formatDuration(video.duration))")
                        Spacer()
                        Text("Size: \(formatFileSize(video.fileSize))")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                    HStack {
                        Text("Resolution: \(Int(video.resolution.width))x\(Int(video.resolution.height))")
                        Spacer()
                        Text("Created: \(video.createdAt, style: .date)")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Export Video")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.systemGray6)
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Video Player")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func formatDuration(_ duration: Double) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func formatFileSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

/// Preview
struct VideoLibraryView_Previews: PreviewProvider {
    static var previews: some View {
        VideoLibraryView()
    }
}
