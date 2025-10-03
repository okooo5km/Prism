//
//  ProviderStore.swift
//  Prism
//
//  Created by okooo5km(十里) on 2025/9/30.
//

import SwiftUI

@Observable
class ProviderStore {
    @ObservationIgnored
    @AppStorage("saved_providers")
    private var providersData: Data = Data()

    @ObservationIgnored
    @AppStorage("active_provider_id")
    private var activeProviderID: String = ""

    var providers: [Provider] {
        get {
            access(keyPath: \.providers)
            guard !providersData.isEmpty else {
                return []
            }
            do {
                let decodedProviders = try JSONDecoder().decode([Provider].self, from: providersData)
                return decodedProviders
            } catch {
                print("❌ Failed to decode providers: \(error)")
                return []
            }
        }
        set {
            withMutation(keyPath: \.providers) {
                do {
                    providersData = try JSONEncoder().encode(newValue)
                } catch {
                    print("❌ Failed to encode providers: \(error)")
                }
            }
        }
    }

    var activeProvider: Provider? {
        providers.first { $0.isActive }
    }

    var savedActiveProviderID: String {
        activeProviderID
    }

    static let shared = ProviderStore()

    private init() {
        // Only print providers once during initialization
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.debugPrintProviders()
        }
    }

    // MARK: - Helper Methods

    /// Check if token is duplicated
    /// - Parameters:
    ///   - token: Auth token to check
    ///   - baseURL: Base URL to compare
    ///   - excludingID: Provider ID to exclude from check (for editing)
    /// - Returns: TokenCheckResult indicating uniqueness or duplicate type
    func checkTokenDuplicate(token: String, baseURL: String, excludingID: UUID?) -> TokenCheckResult {
        guard !token.isEmpty else { return .unique }

        for provider in providers {
            // Skip the provider being edited
            if let excludingID = excludingID, provider.id == excludingID {
                continue
            }

            if let providerToken = provider.envVariables["ANTHROPIC_AUTH_TOKEN"]?.value,
               providerToken == token {
                let providerURL = provider.envVariables["ANTHROPIC_BASE_URL"]?.value ?? ""

                if providerURL == baseURL {
                    return .duplicateWithSameURL(provider)
                } else {
                    return .duplicateWithDifferentURL(provider)
                }
            }
        }

        return .unique
    }

    /// Infer appropriate icon based on BASE_URL by matching host domain
    static func inferIcon(from envVariables: [String: EnvValue]) -> String {
        guard let baseURL = envVariables["ANTHROPIC_BASE_URL"]?.value, !baseURL.isEmpty else {
            return "ClaudeLogo"
        }

        let inputHost = extractHost(from: baseURL)
        if inputHost.isEmpty { return "ClaudeLogo" }

        // Match with template hosts
        for template in ProviderTemplate.allTemplates {
            if let templateURL = template.envVariables["ANTHROPIC_BASE_URL"]?.value,
               !templateURL.isEmpty {
                let templateHost = extractHost(from: templateURL)
                if !templateHost.isEmpty && inputHost == templateHost {
                    return template.icon
                }
            }
        }

        // If no template matches, use host-based inference
        if inputHost.contains("anthropic.com") {
            return "ClaudeLogo"
        } else if inputHost.contains("bigmodel.cn") {
            return "ZhipuLogo"
        } else if inputHost.contains("z.ai") {
            return "ZaiLogo"
        } else if inputHost.contains("moonshot.cn") {
            return "MoonshotLogo"
        } else if inputHost.contains("streamlakeapi.com") {
            return "StreamLakeLogo"
        } else if inputHost.contains("deepseek.com") {
            return "DeepSeekLogo"
        }

        return "OtherLogo"
    }

    /// Helper method to extract host from URL
    private static func extractHost(from url: String) -> String {
        guard let url = URL(string: url),
              let host = url.host else { return "" }

        // Remove www. prefix if present
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }

    func addProvider(_ provider: Provider) {
        print("➕ Adding provider: \(provider.name)")
        var updatedProviders = providers

        // Add new provider (without activating)
        var newProvider = provider
        newProvider.isActive = false
        updatedProviders.append(newProvider)

        providers = updatedProviders
        print("✅ Added provider: \(provider.name). Total: \(updatedProviders.count) providers")
    }

    func updateProvider(_ provider: Provider) {
        print("🔧 updateProvider called: \(provider.name) (icon: \(provider.icon))")
        var updatedProviders = providers
        if let index = updatedProviders.firstIndex(where: { $0.id == provider.id }) {
            let oldName = updatedProviders[index].name
            updatedProviders[index] = provider
            print("📝 Updating provider at index \(index): '\(oldName)' -> '\(provider.name)'")
            providers = updatedProviders
            print("✅ Provider updated and saved")
        } else {
            print("❌ Provider with ID \(provider.id) not found for update!")
        }
    }

    func deleteProvider(_ provider: Provider) {
        var updatedProviders = providers
        updatedProviders.removeAll { $0.id == provider.id }

        // Don't auto-activate another provider - let ContentViewModel handle it
        providers = updatedProviders
    }

    func activateProvider(_ provider: Provider) {
        print("🎯 Activating provider: \(provider.name)")
        var updatedProviders = providers
        // Deactivate all providers
        for i in updatedProviders.indices {
            updatedProviders[i].isActive = false
        }

        // Activate the selected provider
        if let index = updatedProviders.firstIndex(where: { $0.id == provider.id }) {
            updatedProviders[index].isActive = true
            providers = updatedProviders

            // Save activeProviderID
            activeProviderID = provider.id.uuidString
            print("✅ Successfully activated provider: \(provider.name) (ID: \(provider.id.uuidString))")
        } else {
            print("❌ Provider not found: \(provider.name)")
        }
    }

    func deactivateAllProviders() {
        var updatedProviders = providers
        for i in updatedProviders.indices {
            updatedProviders[i].isActive = false
        }
        providers = updatedProviders

        // Clear activeProviderID
        activeProviderID = ""
        print("✅ Deactivated all providers and cleared activeProviderID")
    }

    func clearAllProviders() {
        providers = []
    }

    // MARK: - Debug Methods
    func debugPrintProviders() {
        print("📋 Current providers (\(providers.count)): \(providers.map { $0.name })")
        if let active = activeProvider {
            print("✅ Active provider: \(active.name)")
        } else {
            print("⭕ No active provider")
        }
    }
}