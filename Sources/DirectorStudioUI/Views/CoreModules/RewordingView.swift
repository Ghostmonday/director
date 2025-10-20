//
//  RewordingView.swift
//  DirectorStudioUI
//
//  Created by DirectorStudio on $(date)
//  Copyright © 2025 DirectorStudio. All rights reserved.
//

import SwiftUI

/// Rewording Module UI - Text transformation interface
struct RewordingView: View {
    @State private var inputText: String = ""
    @State private var selectedTransformationType: RewordingType = .modernizeOldEnglish
    @State private var isProcessing: Bool = false
    @State private var rewordedText: String = ""
    @State private var showComparison: Bool = false
    @State private var errorMessage: String?
    
    private let guiAbstraction = GUIAbstraction()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                headerSection
                
                // Input Section
                inputSection
                
                // Transformation Type Picker
                transformationPickerSection
                
                // Transform Button
                transformButtonSection
                
                // Loading State
                if isProcessing {
                    loadingSection
                }
                
                // Results Section
                if !rewordedText.isEmpty {
                    resultsSection
                }
                
                // Error Message
                if let errorMessage = errorMessage {
                    errorSection(errorMessage)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Text Rewording")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Transform your text")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Choose a transformation style to reword your text while preserving meaning")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Input Section
    
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Enter your text")
                .font(.headline)
            
            TextEditor(text: $inputText)
                .frame(minHeight: 120)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            
            if inputText.isEmpty {
                Text("Enter the text you want to transform...")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
    }
    
    // MARK: - Transformation Picker Section
    
    private var transformationPickerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Transformation Style")
                .font(.headline)
            
            Picker("Transformation Type", selection: $selectedTransformationType) {
                ForEach(RewordingType.allCases, id: \.self) { type in
                    Text(type.displayName).tag(type)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Style Description
            Text(selectedTransformationType.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
        }
    }
    
    // MARK: - Transform Button Section
    
    private var transformButtonSection: some View {
        Button(action: transformText) {
            HStack {
                if isProcessing {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "arrow.clockwise")
                }
                Text(isProcessing ? "Transforming..." : "Transform Text")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(inputText.isEmpty ? Color(.systemGray4) : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .disabled(inputText.isEmpty || isProcessing)
        .animation(.easeInOut(duration: 0.2), value: isProcessing)
    }
    
    // MARK: - Loading Section
    
    private var loadingSection: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Processing your text...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    // MARK: - Results Section
    
    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Transformed Text")
                    .font(.headline)
                
                Spacer()
                
                Button(action: copyResult) {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(.blue)
                }
                
                Button(action: { showComparison.toggle() }) {
                    Image(systemName: showComparison ? "eye.slash" : "eye")
                        .foregroundColor(.blue)
                }
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    if showComparison {
                        // Original Text
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Original")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            Text(inputText)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(6)
                                .font(.body)
                        }
                        
                        Divider()
                        
                        // Transformed Text
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Transformed")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            Text(rewordedText)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(6)
                                .font(.body)
                        }
                    } else {
                        // Only transformed text
                        Text(rewordedText)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(6)
                            .font(.body)
                    }
                }
            }
            .frame(maxHeight: 300)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.systemGray4), lineWidth: 1)
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
    
    // MARK: - Actions
    
    private func transformText() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter some text to transform"
            return
        }
        
        isProcessing = true
        errorMessage = nil
        rewordedText = ""
        
        Task {
            do {
                let result = try await guiAbstraction.rewordText(
                    text: inputText,
                    type: selectedTransformationType
                )
                
                await MainActor.run {
                    rewordedText = result.rewordedText
                    isProcessing = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isProcessing = false
                }
            }
        }
    }
    
    private func copyResult() {
        UIPasteboard.general.string = rewordedText
        
        // Show brief feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
}

/// RewordingType enum with display names and descriptions
extension RewordingType {
    var displayName: String {
        switch self {
        case .modernizeOldEnglish:
            return "Modernize Old English"
        case .formalizeCasual:
            return "Formalize Casual Text"
        case .casualizeFormal:
            return "Make More Casual"
        case .simplifyComplex:
            return "Simplify Complex Text"
        case .enhanceDescriptive:
            return "Enhance Descriptions"
        case .professionalize:
            return "Professional Tone"
        case .creativeRewrite:
            return "Creative Rewrite"
        }
    }
    
    var description: String {
        switch self {
        case .modernizeOldEnglish:
            return "Converts archaic or old English text into contemporary, natural language"
        case .formalizeCasual:
            return "Transforms casual, conversational text into formal, professional language"
        case .casualizeFormal:
            return "Makes formal text more conversational and approachable"
        case .simplifyComplex:
            return "Simplifies complex sentences and vocabulary for better readability"
        case .enhanceDescriptive:
            return "Adds vivid descriptions and sensory details to enhance imagery"
        case .professionalize:
            return "Applies professional tone and business-appropriate language"
        case .creativeRewrite:
            return "Creatively rephrases content while maintaining the core message"
        }
    }
}

/// Preview
struct RewordingView_Previews: PreviewProvider {
    static var previews: some View {
        RewordingView()
    }
}
