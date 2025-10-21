//
//  SegmentationView.swift
//  DirectorStudioUI
//
//  Created by DirectorStudio on $(date)
//  Copyright © 2025 DirectorStudio. All rights reserved.
//

import SwiftUI
import DirectorStudio

/// Segmentation Module UI - Story segmentation with timeline
struct SegmentationView: View {
    @State private var storyText: String = ""
    @State private var targetDuration: Double = 60.0
    @State private var isProcessing: Bool = false
    @State private var segments: [GUISegment] = []
    @State private var selectedSegment: GUISegment?
    @State private var showSegmentDetails: Bool = false
    @State private var errorMessage: String?
    @State private var processingProgress: Double = 0.0
    
    // ✅ Warning cleaned: Removed unused UIGUIAbstraction reference
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Story Input Section
                    storyInputSection
                    
                    // Duration Settings
                    durationSection
                    
                    // Segment Button
                    segmentButtonSection
                    
                    // Loading State
                    if isProcessing {
                        loadingSection
                    }
                    
                    // Timeline of Segments
                    if !segments.isEmpty {
                        timelineSection
                    }
                    
                    // Error Message
                    if let errorMessage = errorMessage {
                        errorSection(errorMessage)
                    }
                    
                    Spacer()
                }
                .padding()
                
                // 🚨 UX FIX #1: Floating Action Button
                floatingActionButton
            }
            .navigationTitle("Story Segmentation")
            .sheet(isPresented: $showSegmentDetails) {
                if let selectedSegment = selectedSegment {
                    SegmentDetailView(segment: selectedSegment)
                }
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Segment your story")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Break your story into manageable segments optimized for video generation")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Story Input Section
    
    private var storyInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Story")
                .font(.headline)
            
            TextEditor(text: $storyText)
                .frame(minHeight: 200)
                .padding(8)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                )
            
            if storyText.isEmpty {
                Text("Enter your story here...")
                    .foregroundColor(.secondary)
                    .font(.caption)
            } else {
                Text("\(storyText.count) characters")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
    }
    
    // MARK: - Duration Section
    
    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Target Duration")
                .font(.headline)
            
            VStack(spacing: 8) {
                HStack {
                    Text("30 seconds")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(targetDuration)) seconds")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("300 seconds")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Slider(value: $targetDuration, in: 30...300, step: 15)
                    .accentColor(.blue)
            }
            
            Text("Each segment will be approximately \(estimatedSegmentDuration) seconds long")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Segment Button Section
    
    private var segmentButtonSection: some View {
        VStack(spacing: 12) {
            Button(action: segmentStory) {
                HStack {
                    if isProcessing {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "scissors")
                    }
                    Text(isProcessing ? "Segmenting..." : "Segment Story")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(canSegment ? Color.blue : Color(UIColor.systemGray4))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(!canSegment || isProcessing)
            .animation(.easeInOut(duration: 0.2), value: isProcessing)
            
            if !segments.isEmpty {
                Button(action: resegmentStory) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Re-segment with New Duration")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
                }
            }
        }
    }
    
    // MARK: - Loading Section
    
    private var loadingSection: some View {
        VStack(spacing: 12) {
            ProgressView(value: processingProgress, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle())
                .scaleEffect(1.0, anchor: .center)
            
            Text("Analyzing story structure and creating segments...")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(8)
    }
    
    // MARK: - Timeline Section
    
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Story Timeline")
                    .font(.headline)
                
                Spacer()
                
                Text("\(segments.count) segments")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(segments, id: \.id) { segment in
                        SegmentCardView(
                            segment: segment,
                            onTap: {
                                selectedSegment = segment
                                showSegmentDetails = true
                            }
                        )
                    }
                }
            }
            .frame(maxHeight: 400)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(UIColor.systemGray4), lineWidth: 1)
        )
    }
    
    // MARK: - Error Section
    
    private func errorSection(_ message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.red)
            
            Spacer()
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
    
    // MARK: - Computed Properties
    
    private var canSegment: Bool {
        !storyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var estimatedSegmentDuration: String {
        let estimated = targetDuration / 3.0 // Rough estimate
        return String(format: "%.0f", estimated)
    }
    
    // MARK: - Actions
    
    private func segmentStory() {
        guard canSegment else {
            errorMessage = "Please enter a story to segment"
            return
        }
        
        isProcessing = true
        errorMessage = nil
        segments = []
        processingProgress = 0.0
        
        Task {
            do {
                // Simulate progress updates
                await updateProgress(0.2)
                
                // ✅ Warning cleaned: Use GUIAbstraction directly since instance was removed
                let gui = GUIAbstraction()
                let result = try await gui.segmentStory(
                    story: storyText,
                    maxDuration: Int(targetDuration)
                )
                
                await updateProgress(0.8)
                
                await MainActor.run {
                    segments = result
                    isProcessing = false
                    processingProgress = 1.0
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isProcessing = false
                    processingProgress = 0.0
                }
            }
        }
    }
    
    private func resegmentStory() {
        segmentStory()
    }
    
    private func updateProgress(_ progress: Double) async {
        await MainActor.run {
            processingProgress = progress
        }
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
    }
    
    // MARK: - 🚨 UX FIX #1: Floating Action Button
    
    @ViewBuilder
    private var floatingActionButton: some View {
        if !isProcessing && canSegment {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: segmentStory) {
                        HStack(spacing: 8) {
                            Image(systemName: "scissors.circle.fill")
                                .font(.title3)
                            Text("Segment Story")
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(28)
                        .shadow(color: Color.blue.opacity(0.4), radius: 12, x: 0, y: 6)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

/// Segment Card View for timeline display
struct SegmentCardView: View {
    let segment: GUISegment
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Segment \(segment.index)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(segment.duration)s")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray5))
                        .cornerRadius(6)
                }
                
                Text(segment.content)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                if !segment.characters.isEmpty {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                        
                        Text(segment.characters.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(UIColor.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Segment Detail View for detailed segment information
struct SegmentDetailView: View {
    let segment: GUISegment
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Segment \(segment.index)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        HStack {
                            Text("\(segment.duration) seconds")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            Spacer()
                            
                            Text(segment.setting)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Content
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Content")
                            .font(.headline)
                        
                        Text(segment.content)
                            .font(.body)
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    // Characters
                    if !segment.characters.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Characters")
                                .font(.headline)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                                ForEach(segment.characters, id: \.self) { character in
                                    Text(character)
                                        .font(.subheadline)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(6)
                                }
                            }
                        }
                    }
                    
                    // Setting & Action
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Setting")
                                .font(.headline)
                            
                            Text(segment.setting)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Action")
                                .font(.headline)
                            
                            Text(segment.action)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Continuity Notes
                    if !segment.continuityNotes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Continuity Notes")
                                .font(.headline)
                            
                            Text(segment.continuityNotes)
                                .font(.body)
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Segment Details")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

/// Preview
struct SegmentationView_Previews: PreviewProvider {
    static var previews: some View {
        SegmentationView()
    }
}
