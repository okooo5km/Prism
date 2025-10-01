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

    var providers: [Provider] {
        get {
            access(keyPath: \.providers)
            guard !providersData.isEmpty else {
                print("ℹ️ No saved providers found, starting with empty array")
                return []
            }
            do {
                let decodedProviders = try JSONDecoder().decode([Provider].self, from: providersData)
                print("✅ Loaded \(decodedProviders.count) providers: \(decodedProviders.map { $0.name })")
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
                    print("💾 Saved \(newValue.count) providers: \(newValue.map { $0.name })")
                } catch {
                    print("❌ Failed to encode providers: \(error)")
                }
            }
        }
    }

    var activeProvider: Provider? {
        providers.first { $0.isActive }
    }

    static let shared = ProviderStore()

    private init() {}

    // MARK: - Helper Methods

    /// Infer appropriate icon based on BASE_URL
    static func inferIcon(from envVariables: [String: String]) -> String {
        guard let baseURL = envVariables["ANTHROPIC_BASE_URL"] else {
            return "ClaudeLogo"
        }

        if baseURL.contains("bigmodel.cn") {
            return "ZhipuLogo"
        } else if baseURL.contains("z.ai") {
            return "ZaiLogo"
        } else if baseURL.contains("moonshot.cn") {
            return "MoonshotLogo"
        } else if baseURL.contains("anthropic.com") {
            return "ClaudeLogo"
        } else {
            return "OtherLogo"
        }
    }

    func addProvider(_ provider: Provider) {
        // Deactivate all existing providers
        var updatedProviders = providers
        for i in updatedProviders.indices {
            updatedProviders[i].isActive = false
        }

        // Add new provider and activate it
        var newProvider = provider
        newProvider.isActive = true
        updatedProviders.append(newProvider)

        providers = updatedProviders
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
        var updatedProviders = providers
        // Deactivate all providers
        for i in updatedProviders.indices {
            updatedProviders[i].isActive = false
        }

        // Activate the selected provider
        if let index = updatedProviders.firstIndex(where: { $0.id == provider.id }) {
            updatedProviders[index].isActive = true
        }

        providers = updatedProviders
    }

    func deactivateAllProviders() {
        var updatedProviders = providers
        for i in updatedProviders.indices {
            updatedProviders[i].isActive = false
        }
        providers = updatedProviders
    }

    func clearAllProviders() {
        providers = []
    }
}