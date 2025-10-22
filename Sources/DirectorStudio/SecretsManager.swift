import Foundation

public final class SecretsManager {
    public static let shared = SecretsManager()
    
    private var secrets: [String: String] = [:]
    
    private init() {
        loadSecrets()
    }
    
    public func getSecret(for key: String) -> String? {
        return secrets[key]
    }
    
    private func loadSecrets() {
        let fileManager = FileManager.default
        let currentDirectory = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        let configFile = currentDirectory.appendingPathComponent("secrets.config")

        do {
            let content = try String(contentsOf: configFile, encoding: .utf8)
            let lines = content.split(separator: "\n")
            for line in lines {
                let parts = line.split(separator: "=", maxSplits: 1)
                if parts.count == 2 {
                    let key = String(parts[0].trimmingCharacters(in: .whitespaces))
                    let value = String(parts[1].trimmingCharacters(in: .whitespaces))
                    secrets[key] = value
                }
            }
        } catch {
            // secrets.config not found. This is acceptable; keys may be in the environment.
        }
    }
}
