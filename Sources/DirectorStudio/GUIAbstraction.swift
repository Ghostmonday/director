//
//  GUIAbstraction.swift
//  DirectorStudio
//
//  MODULE: GUIAbstraction
//  VERSION: 1.0.0
//  PURPOSE: Abstract GUI dependencies from core modules
//

import Foundation

// MARK: - GUI Abstraction Protocols

public protocol AlertPrompterProtocol {
    func showAlert(title: String, message: String, completion: @escaping () -> Void)
    func showConfirmation(title: String, message: String, completion: @escaping (Bool) -> Void)
    func showError(_ error: Error, completion: @escaping () -> Void)
}

public protocol NavigationCoordinatorProtocol {
    func navigateToModule(_ moduleId: String)
    func navigateBack()
    func navigateToRoot()
    func canNavigateBack() -> Bool
}

public protocol ProgressIndicatorProtocol {
    func showProgress(_ progress: Double, message: String?)
    func hideProgress()
    func updateProgress(_ progress: Double, message: String?)
}

public protocol FilePickerProtocol {
    func pickFile(completion: @escaping (URL?) -> Void)
    func pickMultipleFiles(completion: @escaping ([URL]) -> Void)
    func saveFile(data: Data, suggestedName: String, completion: @escaping (URL?) -> Void)
}

// MARK: - CLI-Compatible Implementations

public final class CLIAlertPrompter: AlertPrompterProtocol {
    public init() {}
    
    public func showAlert(title: String, message: String, completion: @escaping () -> Void) {
        print("🚨 \(title)")
        print("   \(message)")
        completion()
    }
    
    public func showConfirmation(title: String, message: String, completion: @escaping (Bool) -> Void) {
        print("❓ \(title)")
        print("   \(message)")
        print("   Type 'yes' to confirm, anything else to cancel:")
        
        if let input = readLine()?.lowercased(), input == "yes" {
            completion(true)
        } else {
            completion(false)
        }
    }
    
    public func showError(_ error: Error, completion: @escaping () -> Void) {
        print("❌ Error: \(error.localizedDescription)")
        completion()
    }
}

public final class CLINavigationCoordinator: NavigationCoordinatorProtocol {
    private var navigationStack: [String] = []
    
    public init() {}
    
    public func navigateToModule(_ moduleId: String) {
        navigationStack.append(moduleId)
        print("🧭 Navigating to module: \(moduleId)")
    }
    
    public func navigateBack() {
        if !navigationStack.isEmpty {
            let _ = navigationStack.popLast()
            if let current = navigationStack.last {
                print("🧭 Navigated back to: \(current)")
            } else {
                print("🧭 Navigated back to root")
            }
        }
    }
    
    public func navigateToRoot() {
        navigationStack.removeAll()
        print("🧭 Navigated to root")
    }
    
    public func canNavigateBack() -> Bool {
        return !navigationStack.isEmpty
    }
}

public final class CLIProgressIndicator: ProgressIndicatorProtocol {
    private var isShowing = false
    
    public init() {}
    
    public func showProgress(_ progress: Double, message: String?) {
        isShowing = true
        updateProgress(progress, message: message)
    }
    
    public func hideProgress() {
        isShowing = false
        print() // Clear line
    }
    
    public func updateProgress(_ progress: Double, message: String?) {
        guard isShowing else { return }
        
        let percentage = Int(progress * 100)
        let barLength = 20
        let filledLength = Int(progress * Double(barLength))
        let bar = String(repeating: "█", count: filledLength) + String(repeating: "░", count: barLength - filledLength)
        
        var output = "📊 [\(bar)] \(percentage)%"
        if let message = message {
            output += " - \(message)"
        }
        
        print("\r\(output)", terminator: "")
        fflush(stdout)
    }
}

public final class CLIFilePicker: FilePickerProtocol {
    public init() {}
    
    public func pickFile(completion: @escaping (URL?) -> Void) {
        print("📁 Please enter the path to a file:")
        if let input = readLine(), !input.isEmpty {
            let url = URL(fileURLWithPath: input)
            if FileManager.default.fileExists(atPath: url.path) {
                completion(url)
            } else {
                print("❌ File not found: \(input)")
                completion(nil)
            }
        } else {
            completion(nil)
        }
    }
    
    public func pickMultipleFiles(completion: @escaping ([URL]) -> Void) {
        print("📁 Please enter file paths separated by commas:")
        if let input = readLine(), !input.isEmpty {
            let paths = input.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            let urls = paths.compactMap { path -> URL? in
                let url = URL(fileURLWithPath: path)
                return FileManager.default.fileExists(atPath: url.path) ? url : nil
            }
            completion(urls)
        } else {
            completion([])
        }
    }
    
    public func saveFile(data: Data, suggestedName: String, completion: @escaping (URL?) -> Void) {
        print("💾 Please enter the path to save the file (suggested: \(suggestedName)):")
        if let input = readLine(), !input.isEmpty {
            let url = URL(fileURLWithPath: input)
            do {
                try data.write(to: url)
                completion(url)
            } catch {
                print("❌ Failed to save file: \(error.localizedDescription)")
                completion(nil)
            }
        } else {
            completion(nil)
        }
    }
}

// MARK: - GUI Dependency Injector

public final class GUIDependencyInjector {
    private var alertPrompter: AlertPrompterProtocol?
    private var navigationCoordinator: NavigationCoordinatorProtocol?
    private var progressIndicator: ProgressIndicatorProtocol?
    private var filePicker: FilePickerProtocol?
    
    public init() {
        // Default to CLI implementations
        self.alertPrompter = CLIAlertPrompter()
        self.navigationCoordinator = CLINavigationCoordinator()
        self.progressIndicator = CLIProgressIndicator()
        self.filePicker = CLIFilePicker()
    }
    
    // MARK: - Dependency Injection
    
    public func injectAlertPrompter(_ prompter: AlertPrompterProtocol) {
        self.alertPrompter = prompter
    }
    
    public func injectNavigationCoordinator(_ coordinator: NavigationCoordinatorProtocol) {
        self.navigationCoordinator = coordinator
    }
    
    public func injectProgressIndicator(_ indicator: ProgressIndicatorProtocol) {
        self.progressIndicator = indicator
    }
    
    public func injectFilePicker(_ picker: FilePickerProtocol) {
        self.filePicker = picker
    }
    
    // MARK: - Dependency Access
    
    public func getAlertPrompter() -> AlertPrompterProtocol {
        return alertPrompter ?? CLIAlertPrompter()
    }
    
    public func getNavigationCoordinator() -> NavigationCoordinatorProtocol {
        return navigationCoordinator ?? CLINavigationCoordinator()
    }
    
    public func getProgressIndicator() -> ProgressIndicatorProtocol {
        return progressIndicator ?? CLIProgressIndicator()
    }
    
    public func getFilePicker() -> FilePickerProtocol {
        return filePicker ?? CLIFilePicker()
    }
}

// MARK: - Global Dependency Injector

public let guiDependencyInjector = GUIDependencyInjector()

// MARK: - Convenience Accessors

public func getAlertPrompter() -> AlertPrompterProtocol {
    return guiDependencyInjector.getAlertPrompter()
}

public func getNavigationCoordinator() -> NavigationCoordinatorProtocol {
    return guiDependencyInjector.getNavigationCoordinator()
}

public func getProgressIndicator() -> ProgressIndicatorProtocol {
    return guiDependencyInjector.getProgressIndicator()
}

public func getFilePicker() -> FilePickerProtocol {
    return guiDependencyInjector.getFilePicker()
}
