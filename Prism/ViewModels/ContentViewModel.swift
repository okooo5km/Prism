//
//  ContentViewModel.swift
//  Prism
//
//  Created by okooo5km(十里) on 2025/9/30.
//

import SwiftUI
import AppKit

@Observable
class ContentViewModel {
    // App Navigation State
    var currentView: AppView = .main

    enum AppView: Equatable {
        case main
        case add
        case edit(Provider)

        static func == (lhs: AppView, rhs: AppView) -> Bool {
            switch (lhs, rhs) {
            case (.main, .main), (.add, .add):
                return true
            case (.edit(let lhsProvider), .edit(let rhsProvider)):
                return lhsProvider.id == rhsProvider.id
            default:
                return false
            }
        }
    }

    // Dependencies
    private let configManager = ConfigManager()
    private let providerStore = ProviderStore.shared
    private let configImportService = ConfigImportService.shared

    init() {}

    // Computed Properties
    var isDefaultActive: Bool {
        // Default is active when no provider is active
        return activeProvider == nil
    }

    var activeProvider: Provider? {
        providerStore.activeProvider
    }

    var providers: [Provider] {
        providerStore.providers
    }

    // MARK: - Navigation Actions
    func showAddProvider() {
        currentView = .add
    }

    func showEditProvider(_ provider: Provider) {
        currentView = .edit(provider)
    }

    func backToMain() {
        currentView = .main
    }

    // MARK: - Provider Actions
    func activateProvider(_ provider: Provider) {
        // Get old managed keys BEFORE activating new provider
        let oldManagedKeys = providerStore.activeManagedKeys
        providerStore.activateProvider(provider)
        applyProviderToConfig(provider, previousKeys: oldManagedKeys)
    }

    func activateDefault() {
        // Get old managed keys BEFORE deactivating
        let oldManagedKeys = providerStore.activeManagedKeys
        providerStore.deactivateAllProviders()
        clearManagedEnv(previousKeys: oldManagedKeys)
    }

    func addProvider(_ provider: Provider) {
        providerStore.addProvider(provider)
        // Don't update config file - only save data
    }

    func updateProvider(_ provider: Provider) {
        // Check if this is the active provider before updating
        let wasActive = provider.isActive
        let oldManagedKeys = providerStore.activeManagedKeys

        providerStore.updateProvider(provider)

        // If editing the currently active provider, sync changes to config file immediately
        if wasActive {
            print("📝 Updated active provider, syncing to config file")
            applyProviderToConfig(provider, previousKeys: oldManagedKeys)
        }
    }

    func deleteProvider(_ provider: Provider) {
        let wasActive = provider.isActive

        providerStore.deleteProvider(provider)

        // If deleted provider was active, activate default (clear env)
        if wasActive {
            print("🗑️ Deleted active provider, activating default")
            activateDefault()
        }
    }

    func checkTokenDuplicate(token: String, baseURL: String, excludingID: UUID?) -> TokenCheckResult {
        providerStore.checkTokenDuplicate(token: token, baseURL: baseURL, excludingID: excludingID)
    }

    func syncConfigurationState() {
        _ = configImportService.syncConfigurationState()
    }

    // MARK: - Import Actions
    
    /// Check clipboard for valid provider configuration
    /// Returns parsed environment variables if valid, nil otherwise
    func checkClipboardForConfig() -> [String: EnvValue]? {
        let pasteboard = NSPasteboard.general
        
        guard let clipboardString = pasteboard.string(forType: .string),
              !clipboardString.isEmpty else {
            return nil
        }
        
        guard let data = clipboardString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let envDict = json["env"] as? [String: Any] else {
            return nil
        }
        
        // Validate required fields: ANTHROPIC_AUTH_TOKEN and ANTHROPIC_BASE_URL
        guard let authToken = envDict["ANTHROPIC_AUTH_TOKEN"],
              let baseURL = envDict["ANTHROPIC_BASE_URL"] else {
            return nil
        }
        
        // Convert auth token to string and check if not empty
        let authTokenString: String
        if let str = authToken as? String {
            authTokenString = str
        } else {
            authTokenString = "\(authToken)"
        }
        
        // Convert base URL to string and check if not empty
        let baseURLString: String
        if let str = baseURL as? String {
            baseURLString = str
        } else {
            baseURLString = "\(baseURL)"
        }
        
        guard !authTokenString.isEmpty, !baseURLString.isEmpty else {
            return nil
        }
        
        // Parse all environment variables
        var result: [String: EnvValue] = [:]
        for (key, value) in envDict {
            let envValue: EnvValue
            
            // Determine type based on EnvKey enum, default to string
            let valueType: EnvValueType
            if let envKey = EnvKey(rawValue: key) {
                valueType = envKey.valueType
            } else if let claudeEnvVar = ClaudeEnvVariable.find(byName: key) {
                valueType = claudeEnvVar.type
            } else {
                // Infer type from value
                if value is Int {
                    valueType = .integer
                } else if value is Bool {
                    valueType = .boolean
                } else {
                    valueType = .string
                }
            }
            
            // Convert value to string
            let stringValue: String
            if let intValue = value as? Int {
                stringValue = String(intValue)
            } else if let boolValue = value as? Bool {
                stringValue = boolValue ? "1" : "0"
            } else if let strValue = value as? String {
                stringValue = strValue
            } else {
                stringValue = "\(value)"
            }
            
            envValue = EnvValue(value: stringValue, type: valueType)
            result[key] = envValue
        }
        
        return result
    }
    
    /// Create a provider from imported environment variables
    func createProviderFromImport(_ envVariables: [String: EnvValue]) -> Provider {
        // Try to match a template based on BASE_URL
        let baseURL = envVariables["ANTHROPIC_BASE_URL"]?.value ?? ""
        
        for template in ProviderTemplate.allTemplates {
            if let templateURL = template.envVariables["ANTHROPIC_BASE_URL"]?.value {
                // Exact match
                if templateURL == baseURL {
                    return Provider(name: template.name, envVariables: envVariables, icon: template.icon)
                }
                
                // Pattern matching for dynamic URLs (like StreamLake with ep-xxx-xxxxxxx)
                if templateURL.contains("ep-xxx-xxxxxxx") || templateURL.contains("xxx") {
                    let regex = try? NSRegularExpression(pattern: "ep-[a-z0-9-]+", options: [])
                    let normalizedURL = regex?.stringByReplacingMatches(
                        in: baseURL,
                        options: [],
                        range: NSRange(location: 0, length: baseURL.utf16.count),
                        withTemplate: "ep-xxx-xxxxxxx"
                    ) ?? baseURL
                    
                    if normalizedURL == templateURL {
                        return Provider(name: template.name, envVariables: envVariables, icon: template.icon)
                    }
                }
                
                // Partial domain matching
                if let templateHost = URL(string: templateURL)?.host,
                   let baseHost = URL(string: baseURL)?.host,
                   templateHost == baseHost {
                    return Provider(name: template.name, envVariables: envVariables, icon: template.icon)
                }
            }
        }
        
        // No template matched, create custom provider
        return Provider(name: String(localized: "Custom AI"), envVariables: envVariables, icon: "OtherLogo")
    }
    
    // MARK: - Copy/Paste Actions
    
    /// Copy a provider's environment variables to clipboard as JSON
    func copyProvider(_ provider: Provider) {
        // Build the export JSON structure
        var envDict: [String: Any] = [:]
        
        for (key, envValue) in provider.envVariables {
            switch envValue.type {
            case .string:
                envDict[key] = envValue.value
            case .integer:
                if let intValue = Int(envValue.value) {
                    envDict[key] = intValue
                } else {
                    envDict[key] = envValue.value
                }
            case .boolean:
                if envValue.value == "1" || envValue.value.lowercased() == "true" {
                    envDict[key] = "1"
                } else {
                    envDict[key] = "0"
                }
            }
        }
        
        let exportData: [String: Any] = ["env": envDict]
        
        // Serialize to formatted JSON
        guard let jsonData = try? JSONSerialization.data(
            withJSONObject: exportData,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        ),
        var jsonString = String(data: jsonData, encoding: .utf8) else {
            print("❌ Failed to serialize provider to JSON")
            return
        }
        
        // Convert 2-space indentation to 4-space indentation
        jsonString = jsonString
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { line in
                var spaces = 0
                for char in line {
                    if char == " " {
                        spaces += 1
                    } else {
                        break
                    }
                }
                let indent = String(repeating: " ", count: spaces * 2)
                return indent + line.dropFirst(spaces)
            }
            .joined(separator: "\n")
        
        // Copy to clipboard
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(jsonString, forType: .string)
        print("📋 Copied provider config to clipboard")
    }
    
    /// Paste provider from clipboard and add to list
    func pasteProvider() -> Provider? {
        guard let envVariables = checkClipboardForConfig() else {
            return nil
        }
        let newProvider = createProviderFromImport(envVariables)
        addProvider(newProvider)
        return newProvider
    }
    
    /// Duplicate a provider and add to list
    @discardableResult
    func duplicateProvider(_ provider: Provider) -> Provider {
        let duplicatedProvider = Provider(
            name: "\(provider.name) Copy",
            envVariables: provider.envVariables,
            icon: provider.icon
        )
        addProvider(duplicatedProvider)
        return duplicatedProvider
    }

    // MARK: - Private Helper Methods
    private func applyProviderToConfig(_ provider: Provider, previousKeys: [String]) {
        let success = configManager.updateEnvVariables(provider.envVariables, previousKeys: previousKeys)
        if !success {
            print("Failed to apply provider configuration")
        }
    }

    private func clearManagedEnv(previousKeys: [String]) {
        let success = configManager.removeManagedEnvVariables(previousKeys: previousKeys)
        if !success {
            print("Failed to clear managed env variables")
        }
    }
}