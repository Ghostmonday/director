//
//  EnhancedTextEditor.swift
//  DirectorStudioUI
//
//  🚨 UX FIX #2: Enhanced text editor with character count, word count, and toolbar
//

import SwiftUI

/// Enhanced text editor with statistics, toolbar, and optional AI enhancement
public struct EnhancedTextEditor: View {
    @Binding var text: String
    let placeholder: String
    let minHeight: CGFloat
    var onAIEnhance: (() -> Void)? = nil
    var showClearButton: Bool = true
    var onTextChanged: ((String) -> Void)? = nil // 🚨 UX FIX #6: Callback for debounced changes
    
    @State private var debounceTask: Task<Void, Never>?
    
    public init(
        text: Binding<String>,
        placeholder: String,
        minHeight: CGFloat = 200,
        onAIEnhance: (() -> Void)? = nil,
        showClearButton: Bool = true,
        onTextChanged: ((String) -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.minHeight = minHeight
        self.onAIEnhance = onAIEnhance
        self.showClearButton = showClearButton
        self.onTextChanged = onTextChanged
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack(spacing: 12) {
                // Statistics
                HStack(spacing: 4) {
                    Image(systemName: "doc.text")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(characterCount) chars")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(wordCount) words")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // AI Enhance button
                if let enhance = onAIEnhance, !text.isEmpty {
                    Button(action: enhance) {
                        HStack(spacing: 4) {
                            Image(systemName: "wand.and.stars")
                            Text("AI Enhance")
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                    }
                    .accessibilityLabel("Enhance text with AI")
                    .accessibilityHint("Improves your text using artificial intelligence")
                }
                
                // Clear button
                if showClearButton && !text.isEmpty {
                    Button(action: {
                        // 🎉 Haptic: Text cleared
                        HapticManager.shared.textCleared()
                        text = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .accessibilityLabel("Clear text")
                    .accessibilityHint("Removes all text from the editor")
                    .frame(minWidth: 44, minHeight: 44) // Apple HIG minimum tap target
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            #if os(iOS)
            .background(Color(UIColor.systemGray6).opacity(0.5))
            #else
            .background(Color(.windowBackgroundColor).opacity(0.5))
            #endif
            
            // Editor
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .allowsHitTesting(false)
                }
                
                TextEditor(text: $text)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .frame(minHeight: minHeight)
                    .background(Color.clear)
                    .onChange(of: text) { newValue in
                        // 🚨 UX FIX #6: Debounce text changes to prevent excessive callbacks
                        debounceTask?.cancel()
                        debounceTask = Task {
                            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
                            if !Task.isCancelled {
                                onTextChanged?(newValue)
                            }
                        }
                    }
            }
            #if os(iOS)
            .background(Color(UIColor.systemGray6))
            #else
            .background(Color(.controlBackgroundColor))
            #endif
        }
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                #if os(iOS)
                .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                #else
                .stroke(Color(.separatorColor), lineWidth: 1)
                #endif
        )
    }
    
    private var characterCount: Int {
        text.count
    }
    
    private var wordCount: Int {
        let words = text.split(separator: " ").filter { !$0.isEmpty }
        return words.count
    }
}

// Preview
struct EnhancedTextEditor_Previews: PreviewProvider {
    @State static var sampleText = "Enter your story here..."
    
    static var previews: some View {
        VStack {
            EnhancedTextEditor(
                text: $sampleText,
                placeholder: "Enter your story here...",
                minHeight: 200,
                onAIEnhance: {
                    // TODO: Implement AI enhancement
                }
            )
            .padding()
        }
    }
}

