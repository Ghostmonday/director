//
//  DraftRecoveryManager.swift
//  DirectorStudioUI
//
//  🚨 UX FIX #8: Auto-save and draft recovery system
//

import SwiftUI

/// Manages auto-save and draft recovery for text content
public class DraftRecoveryManager: ObservableObject {
    @Published public var showRecoveryAlert = false
    @Published public var recoveredDraft: String?
    
    private var autoSaveTask: Task<Void, Never>?
    private let draftKey: String
    
    public init(draftKey: String) {
        self.draftKey = draftKey
    }
    
    /// Check for existing draft on app launch
    public func checkForDraft() {
        if let draft = UserDefaults.standard.string(forKey: draftKey), !draft.isEmpty {
            recoveredDraft = draft
            showRecoveryAlert = true
        }
    }
    
    /// Auto-save text with debouncing
    public func autoSave(text: String) {
        autoSaveTask?.cancel()
        autoSaveTask = Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            if !Task.isCancelled {
                UserDefaults.standard.set(text, forKey: draftKey)
            }
        }
    }
    
    /// Clear saved draft
    public func clearDraft() {
        UserDefaults.standard.removeObject(forKey: draftKey)
        recoveredDraft = nil
    }
    
    /// Recover draft
    public func recoverDraft() -> String? {
        return recoveredDraft
    }
}

/// View modifier for draft recovery
public struct DraftRecoveryModifier: ViewModifier {
    @Binding var text: String
    @StateObject private var manager: DraftRecoveryManager
    let draftKey: String
    
    public init(text: Binding<String>, draftKey: String) {
        self._text = text
        self.draftKey = draftKey
        self._manager = StateObject(wrappedValue: DraftRecoveryManager(draftKey: draftKey))
    }
    
    public func body(content: Content) -> some View {
        content
            .onAppear {
                manager.checkForDraft()
            }
            .onChange(of: text) { newValue in
                if !newValue.isEmpty {
                    manager.autoSave(text: newValue)
                }
            }
            .alert("Recover Draft?", isPresented: $manager.showRecoveryAlert) {
                Button("Recover") {
                    if let draft = manager.recoverDraft() {
                        text = draft
                    }
                }
                Button("Discard", role: .destructive) {
                    manager.clearDraft()
                }
            } message: {
                Text("We found an unsaved draft from your last session. Would you like to recover it?")
            }
    }
}

extension View {
    /// Add draft recovery to any view with text binding
    public func draftRecovery(text: Binding<String>, key: String) -> some View {
        modifier(DraftRecoveryModifier(text: text, draftKey: key))
    }
}

