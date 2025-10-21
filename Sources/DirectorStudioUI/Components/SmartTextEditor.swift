//
//  SmartTextEditor.swift
//  DirectorStudioUI
//
//  🚨 UX FIX #7: Smart text editor with read/edit modes and expand toggle
//

import SwiftUI

/// Advanced text editor with read/edit mode toggle and expand/collapse
public struct SmartTextEditor: View {
    @Binding var text: String
    let title: String
    let placeholder: String
    var minHeight: CGFloat = 200
    var maxHeight: CGFloat = 500
    
    @State private var isExpanded = false
    @State private var isReadMode = false
    @State private var debounceTask: Task<Void, Never>?
    
    public init(
        text: Binding<String>,
        title: String,
        placeholder: String = "Enter text...",
        minHeight: CGFloat = 200,
        maxHeight: CGFloat = 500
    ) {
        self._text = text
        self.title = title
        self.placeholder = placeholder
        self.minHeight = minHeight
        self.maxHeight = maxHeight
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with controls
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Read/Edit toggle
                Button(action: { withAnimation { isReadMode.toggle() } }) {
                    HStack(spacing: 4) {
                        Image(systemName: isReadMode ? "pencil.circle.fill" : "book.circle.fill")
                        Text(isReadMode ? "Edit" : "Read")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }
                .frame(minWidth: 44, minHeight: 44)
                .accessibilityLabel(isReadMode ? "Switch to edit mode" : "Switch to read mode")
                
                // Expand/Collapse toggle
                Button(action: { withAnimation(.spring(response: 0.3)) { isExpanded.toggle() } }) {
                    Image(systemName: isExpanded ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                        .foregroundColor(.blue)
                }
                .frame(minWidth: 44, minHeight: 44)
                .accessibilityLabel(isExpanded ? "Collapse editor" : "Expand editor")
            }
            
            // Content area
            Group {
                if isReadMode {
                    // Read-only scrollable view
                    ScrollView {
                        Text(text.isEmpty ? placeholder : text)
                            .font(.body)
                            .foregroundColor(text.isEmpty ? .secondary : .primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .textSelection(.enabled)
                    }
                    .frame(height: isExpanded ? maxHeight : minHeight)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                } else {
                    // Editable text editor
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
                            .frame(height: isExpanded ? maxHeight : minHeight)
                            .background(Color.clear)
                    }
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                }
            }
            
            // Stats bar
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "doc.text")
                        .font(.caption2)
                    Text("\(characterCount) chars")
                }
                
                Text("•")
                
                HStack(spacing: 4) {
                    Image(systemName: "textformat")
                        .font(.caption2)
                    Text("\(wordCount) words")
                }
                
                Text("•")
                
                HStack(spacing: 4) {
                    Image(systemName: "list.bullet")
                        .font(.caption2)
                    Text("\(lineCount) lines")
                }
                
                Spacer()
                
                if !text.isEmpty {
                    Button(action: { text = "" }) {
                        HStack(spacing: 4) {
                            Image(systemName: "trash")
                            Text("Clear")
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                    }
                    .frame(minWidth: 44, minHeight: 44)
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Computed Properties
    
    private var characterCount: Int {
        text.count
    }
    
    private var wordCount: Int {
        text.split(separator: " ").filter { !$0.isEmpty }.count
    }
    
    private var lineCount: Int {
        text.components(separatedBy: .newlines).count
    }
}

// MARK: - Preview
struct SmartTextEditor_Previews: PreviewProvider {
    @State static var sampleText = "A young hero discovers a hidden portal to another world and must save both realms from an ancient evil."
    
    static var previews: some View {
        VStack(spacing: 20) {
            SmartTextEditor(
                text: $sampleText,
                title: "Story Content",
                placeholder: "Enter your story here..."
            )
            
            Spacer()
        }
        .padding()
    }
}

