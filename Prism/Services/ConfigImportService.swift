//
//  ConfigImportService.swift
//  Prism
//
//  Created by okooo5km(十里) on 2025/9/30.
//

import Foundation

@Observable
class ConfigImportService {
    static let shared = ConfigImportService()

    private let configManager = ConfigManager()
    private let providerStore = ProviderStore.shared

    private init() {}

    func importExistingConfigurationIfNeeded() {
        let currentEnv = configManager.getCurrentEnvVariables()
        print("🔍 Current Claude Code env variables: \(currentEnv)")

        // Check if we have any configuration
        guard let baseURL = currentEnv["ANTHROPIC_BASE_URL"], !baseURL.isEmpty else {
            print("❌ No existing Claude Code configuration found")
            return
        }

        guard let authToken = currentEnv["ANTHROPIC_AUTH_TOKEN"], !authToken.isEmpty else {
            print("❌ No auth token found in configuration")
            return
        }

        print("✅ Found valid configuration")
        print("📡 Base URL: \(baseURL)")
        print("🔑 Auth Token: \(String(authToken.prefix(10)))...")

        // Enhanced matching: check both URL and token validity
        if let matchedTemplate = findMatchingTemplate(baseURL: baseURL, env: currentEnv) {
            print("🎯 Matched template: \(matchedTemplate.name)")

            // Check if we already have this provider
            let existingProvider = providerStore.providers.first { provider in
                provider.envVariables["ANTHROPIC_BASE_URL"] == baseURL &&
                provider.envVariables["ANTHROPIC_AUTH_TOKEN"] == authToken
            }

            if existingProvider == nil {
                print("➕ Creating new provider from existing config")
                var newProvider = Provider(name: matchedTemplate.name, envVariables: currentEnv, icon: matchedTemplate.icon)
                newProvider.isActive = true

                print("📝 New provider: name=\(newProvider.name), icon=\(newProvider.icon), active=\(newProvider.isActive)")

                // Add to store (this will trigger UI update automatically)
                providerStore.addProvider(newProvider)
                print("✅ Auto-imported existing provider: \(matchedTemplate.name)")
            } else {
                print("ℹ️ Provider already exists and matches current config")
                // Ensure existing provider is active
                if let provider = existingProvider, !provider.isActive {
                    providerStore.activateProvider(provider)
                    print("🔄 Activated existing provider")
                }
            }
        } else {
            print("❓ No template matched for baseURL: \(baseURL)")

            // Unknown provider - create with "Other" name
            let existingProvider = providerStore.providers.first { provider in
                provider.envVariables["ANTHROPIC_BASE_URL"] == baseURL &&
                provider.envVariables["ANTHROPIC_AUTH_TOKEN"] == authToken
            }

            if existingProvider == nil {
                print("➕ Creating unknown provider")
                var newProvider = Provider(name: "Other", envVariables: currentEnv, icon: "OtherLogo")
                newProvider.isActive = true

                providerStore.addProvider(newProvider)
                print("✅ Auto-imported unknown provider: \(baseURL)")
            } else {
                print("ℹ️ Unknown provider already exists")
                if let provider = existingProvider, !provider.isActive {
                    providerStore.activateProvider(provider)
                    print("🔄 Activated existing unknown provider")
                }
            }
        }
    }

    private func findMatchingTemplate(baseURL: String, env: [String: String]) -> ProviderTemplate? {
        print("🔍 Checking templates against baseURL: \(baseURL)")
        print("🔐 Available token: \(env["ANTHROPIC_AUTH_TOKEN"]?.isEmpty == false ? "Yes" : "No")")

        for template in ProviderTemplate.allTemplates {
            if let templateURL = template.envVariables["ANTHROPIC_BASE_URL"] {
                print("📋 Template '\(template.name)' has URL: \(templateURL)")
                if templateURL == baseURL {
                    print("✅ URL matched!")

                    // Additional validation: check if this is a known provider pattern
                    if isValidProviderForTemplate(baseURL: baseURL, template: template, env: env) {
                        print("🎯 Template and configuration validated!")
                        return template
                    } else {
                        print("⚠️ URL matched but configuration seems invalid for this template")
                    }
                }
            }
        }
        print("❌ No template matched")
        return nil
    }

    private func isValidProviderForTemplate(baseURL: String, template: ProviderTemplate, env: [String: String]) -> Bool {
        // For Zhipu AI, validate the URL pattern and token format
        if template.name == "Zhipu AI" {
            // Zhipu AI should have the specific base URL
            guard baseURL == "https://open.bigmodel.cn/api/anthropic" else {
                return false
            }

            // Token should be in expected format (length and pattern)
            guard let token = env["ANTHROPIC_AUTH_TOKEN"] else { return false }

            // Zhipu AI tokens are typically 32 chars + ".W7Gu3qS0k5isSImL" pattern
            return token.count >= 20
        }

        // For other future templates, add specific validation logic here
        return true
    }
}