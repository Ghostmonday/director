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
    
    public init(
        text: Binding<String>,
        placeholder: String,
        minHeight: CGFloat = 200,
        onAIEnhance: (() -> Void)? = nil,
        showClearButton: Bool = true
    ) {
        self._text = text
        self.placeholder = placeholder
        self.minHeight = minHeight
        self.onAIEnhance = onAIEnhance
        self.showClearButton = showClearButton
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
                }
                
                // Clear button
                if showClearButton && !text.isEmpty {
                    Button(action: { text = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(UIColor.systemGray6).opacity(0.5))
            
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
            }
            .background(Color(UIColor.systemGray6))
        }
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(UIColor.systemGray4), lineWidth: 1)
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
                    print("AI Enhance tapped")
                }
            )
            .padding()
        }
    }
}

