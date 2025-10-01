//
//  ConfigManager.swift
//  Prism
//
//  Created by okooo5km(十里) on 2025/9/30.
//

import Foundation

@Observable
class ConfigManager {
    private let claudeConfigPath: String
    private let backupPath: String

    init() {
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        claudeConfigPath = homeDirectory.appendingPathComponent(".claude/settings.json").path
        backupPath = homeDirectory.appendingPathComponent(".claude/settings.json.backup").path
    }

    // Use raw JSON dictionary to preserve all config keys
    typealias ClaudeConfig = [String: Any]

    func readConfig() -> ClaudeConfig? {
        guard FileManager.default.fileExists(atPath: claudeConfigPath) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: claudeConfigPath))
            let config = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            return config
        } catch {
            print("Failed to read Claude config: \(error)")
            return nil
        }
    }

    func writeConfig(_ config: ClaudeConfig) -> Bool {
        // Create backup before writing
        createBackup()

        do {
            let data = try JSONSerialization.data(
                withJSONObject: config,
                options: [.prettyPrinted, .withoutEscapingSlashes]
            )

            // Ensure directory exists
            let directory = (claudeConfigPath as NSString).deletingLastPathComponent
            try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true)

            try data.write(to: URL(fileURLWithPath: claudeConfigPath))
            return true
        } catch {
            print("Failed to write Claude config: \(error)")
            // Restore backup if write failed
            restoreBackup()
            return false
        }
    }

    func updateEnvVariables(_ envVars: [String: String]) -> Bool {
        // Debug: Print what we're about to write
        print("🔧 Writing env variables to Claude config:")
        for (key, value) in envVars {
            let displayValue = key == "ANTHROPIC_AUTH_TOKEN" ?
                "\(String(value.prefix(10)))..." : value
            print("  \(key): \(displayValue)")
        }

        // Read existing config to preserve all fields
        var config = readConfig() ?? [:]

        // Get existing env or create new one
        var existingEnv = (config["env"] as? [String: String]) ?? [:]

        // Define the keys we manage
        let managedKeys: Set<String> = [
            "ANTHROPIC_BASE_URL",
            "ANTHROPIC_AUTH_TOKEN",
            "ANTHROPIC_DEFAULT_HAIKU_MODEL",
            "ANTHROPIC_DEFAULT_SONNET_MODEL",
            "ANTHROPIC_DEFAULT_OPUS_MODEL"
        ]

        // Remove our managed keys from existing env (we'll set them fresh)
        for key in managedKeys {
            existingEnv.removeValue(forKey: key)
        }

        // Merge: keep non-managed env vars, add our managed ones
        for (key, value) in envVars {
            existingEnv[key] = value
        }

        // Update config with merged env
        config["env"] = existingEnv

        return writeConfig(config)
    }

    func getCurrentEnvVariables() -> [String: String] {
        guard let config = readConfig() else { return [:] }
        return (config["env"] as? [String: String]) ?? [:]
    }

    func removeManagedEnvVariables() -> Bool {
        // Read existing config to preserve all fields
        var config = readConfig() ?? [:]

        // Get existing env or create new one
        var existingEnv = (config["env"] as? [String: String]) ?? [:]

        // Define the keys we manage
        let managedKeys: Set<String> = [
            "ANTHROPIC_BASE_URL",
            "ANTHROPIC_AUTH_TOKEN",
            "ANTHROPIC_DEFAULT_HAIKU_MODEL",
            "ANTHROPIC_DEFAULT_SONNET_MODEL",
            "ANTHROPIC_DEFAULT_OPUS_MODEL"
        ]

        // Remove only our managed keys, keep others
        for key in managedKeys {
            existingEnv.removeValue(forKey: key)
        }

        print("🧹 Removing managed env variables, keeping other env vars")

        // Update config with cleaned env
        config["env"] = existingEnv

        return writeConfig(config)
    }

    private func createBackup() {
        if FileManager.default.fileExists(atPath: claudeConfigPath) {
            do {
                // Remove existing backup if it exists
                if FileManager.default.fileExists(atPath: backupPath) {
                    try FileManager.default.removeItem(atPath: backupPath)
                }
                // Create new backup
                try FileManager.default.copyItem(atPath: claudeConfigPath, toPath: backupPath)
            } catch {
                print("Failed to create backup: \(error)")
            }
        }
    }

    private func restoreBackup() {
        if FileManager.default.fileExists(atPath: backupPath) {
            do {
                try FileManager.default.removeItem(atPath: claudeConfigPath)
                try FileManager.default.copyItem(atPath: backupPath, toPath: claudeConfigPath)
                try FileManager.default.removeItem(atPath: backupPath)
            } catch {
                print("Failed to restore backup: \(error)")
            }
        }
    }
}