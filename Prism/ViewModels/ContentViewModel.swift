//
//  ContentViewModel.swift
//  Prism
//
//  Created by okooo5km(十里) on 2025/9/30.
//

import SwiftUI

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
        let currentEnv = configManager.getCurrentEnvVariables()
        let hasBaseURL = !(currentEnv["ANTHROPIC_BASE_URL"]?.value ?? "").isEmpty
        let hasAuthToken = !(currentEnv["ANTHROPIC_AUTH_TOKEN"]?.value ?? "").isEmpty
        return !hasBaseURL && !hasAuthToken
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
        providerStore.activateProvider(provider)
        applyProviderToConfig(provider)
    }

    func activateDefault() {
        providerStore.deactivateAllProviders()
        clearManagedEnv()
    }

    func addProvider(_ provider: Provider) {
        providerStore.addProvider(provider)
        // Don't update config file - only save data
    }

    func updateProvider(_ provider: Provider) {
        // Check if this is the active provider before updating
        let wasActive = provider.isActive

        providerStore.updateProvider(provider)

        // If editing the currently active provider, sync changes to config file immediately
        if wasActive {
            print("📝 Updated active provider, syncing to config file")
            applyProviderToConfig(provider)
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

    // MARK: - Private Helper Methods
    private func applyProviderToConfig(_ provider: Provider) {
        let success = configManager.updateEnvVariables(provider.envVariables)
        if !success {
            print("Failed to apply provider configuration")
        }
    }

    private func clearManagedEnv() {
        let success = configManager.removeManagedEnvVariables()
        if !success {
            print("Failed to clear managed env variables")
        }
    }
}