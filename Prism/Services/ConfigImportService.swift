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

    /// Sync configuration state when menu opens
    /// Detects external config changes and updates activation state
    /// - Returns: true if configuration changed
    func syncConfigurationState() -> Bool {
        let currentEnv = configManager.getCurrentEnvVariables()

        guard let configToken = currentEnv["ANTHROPIC_AUTH_TOKEN"]?.value, !configToken.isEmpty else {
            // No token in config - deactivate all providers if any are active
            if providerStore.activeProvider != nil {
                print("🔄 Config has no token, deactivating all providers")
                providerStore.deactivateAllProviders()
                return true
            }
            return false
        }

        // Check if config token matches active provider
        let activeProviderID = providerStore.savedActiveProviderID
        if !activeProviderID.isEmpty, let activeUUID = UUID(uuidString: activeProviderID) {
            if let activeProvider = providerStore.providers.first(where: { $0.id == activeUUID }) {
                let providerToken = activeProvider.envVariables["ANTHROPIC_AUTH_TOKEN"]?.value ?? ""

                if providerToken == configToken {
                    // Config matches active provider
                    return false
                } else {
                    print("⚠️ Config token changed externally")
                }
            }
        }

        // Config changed - find matching provider
        for provider in providerStore.providers {
            let providerToken = provider.envVariables["ANTHROPIC_AUTH_TOKEN"]?.value ?? ""
            if providerToken == configToken {
                print("🔄 Activating provider based on config change: \(provider.name)")
                providerStore.activateProvider(provider)
                return true
            }
        }

        // No matching provider - create new one (same as Phase 3 in startup)
        let configBaseURL = currentEnv["ANTHROPIC_BASE_URL"]?.value ?? ""
        if !configBaseURL.isEmpty {
            if let matchedTemplate = findMatchingTemplate(baseURL: configBaseURL, env: currentEnv) {
                print("🔄 Creating provider from config change (template): \(matchedTemplate.name)")
                let newProvider = Provider(name: matchedTemplate.name, envVariables: currentEnv, icon: matchedTemplate.icon)
                providerStore.addProvider(newProvider)
                providerStore.activateProvider(newProvider)
                return true
            } else {
                print("🔄 Creating custom provider from config change")
                let newProvider = Provider(name: "Other", envVariables: currentEnv, icon: "OtherLogo")
                providerStore.addProvider(newProvider)
                providerStore.activateProvider(newProvider)
                return true
            }
        }

        return false
    }

    /// Sync configuration on app startup
    /// Three-phase validation:
    /// 1. Check activeProviderID and validate token consistency
    /// 2. If inconsistent, match token across all providers
    /// 3. If no match, create new provider from template
    func syncConfigurationOnStartup() {
        let currentEnv = configManager.getCurrentEnvVariables()
        configManager.debugPrintCurrentEnvVariables()

        // Check if we have any configuration
        guard let configToken = currentEnv["ANTHROPIC_AUTH_TOKEN"]?.value, !configToken.isEmpty else {
            print("❌ No auth token found in Claude Code configuration")
            return
        }

        let configBaseURL = currentEnv["ANTHROPIC_BASE_URL"]?.value ?? ""
        print("✅ Found valid configuration")
        print("📡 Base URL: \(configBaseURL)")
        print("🔑 Auth Token: \(String(repeating: "*", count: min(configToken.count, 20)))")

        // Phase 1: Check activeProviderID
        let activeProviderID = providerStore.savedActiveProviderID
        if !activeProviderID.isEmpty, let activeUUID = UUID(uuidString: activeProviderID) {
            print("🔍 Phase 1: Checking activeProviderID: \(activeProviderID)")

            if let activeProvider = providerStore.providers.first(where: { $0.id == activeUUID }) {
                let providerToken = activeProvider.envVariables["ANTHROPIC_AUTH_TOKEN"]?.value ?? ""

                if providerToken == configToken {
                    print("✅ Active provider matches config token")
                    if !activeProvider.isActive {
                        providerStore.activateProvider(activeProvider)
                        print("🔄 Activated saved provider: \(activeProvider.name)")
                    }
                    return
                } else {
                    print("⚠️ Active provider token doesn't match config, proceeding to Phase 2")
                }
            } else {
                print("⚠️ Active provider not found, proceeding to Phase 2")
            }
        } else {
            print("🔍 No activeProviderID found, proceeding to Phase 2")
        }

        // Phase 2: Match token across all providers
        print("🔍 Phase 2: Matching token across all providers")
        for provider in providerStore.providers {
            let providerToken = provider.envVariables["ANTHROPIC_AUTH_TOKEN"]?.value ?? ""
            if providerToken == configToken {
                print("✅ Found matching provider: \(provider.name)")
                if !provider.isActive {
                    providerStore.activateProvider(provider)
                    print("🔄 Activated matching provider")
                }
                return
            }
        }

        // Phase 3: Create new provider from template or custom
        print("🔍 Phase 3: No matching provider found, creating new provider")
        if !configBaseURL.isEmpty {
            if let matchedTemplate = findMatchingTemplate(baseURL: configBaseURL, env: currentEnv) {
                print("🎯 Matched template: \(matchedTemplate.name)")
                let newProvider = Provider(name: matchedTemplate.name, envVariables: currentEnv, icon: matchedTemplate.icon)
                providerStore.addProvider(newProvider)
                providerStore.activateProvider(newProvider)
                print("✅ Created and activated provider from template: \(matchedTemplate.name)")
            } else {
                print("❓ No template matched, creating custom provider")
                let newProvider = Provider(name: "Other", envVariables: currentEnv, icon: "OtherLogo")
                providerStore.addProvider(newProvider)
                providerStore.activateProvider(newProvider)
                print("✅ Created and activated custom provider")
            }
        } else {
            print("⚠️ No BASE_URL in config, cannot create provider")
        }
    }

    private func findMatchingTemplate(baseURL: String, env: [String: EnvValue]) -> ProviderTemplate? {
        print("🔍 Checking templates against baseURL: \(baseURL)")
        print("🔐 Available token: \(env["ANTHROPIC_AUTH_TOKEN"]?.value.isEmpty == false ? "Yes" : "No")")

        for template in ProviderTemplate.allTemplates {
            if let templateURL = template.envVariables["ANTHROPIC_BASE_URL"]?.value {
                print("📋 Template '\(template.name)' has URL: \(templateURL)")

                // Try exact matching first
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

                // Try pattern matching for dynamic URLs (like StreamLake)
                if templateURL.contains("ep-xxx-xxxxxxx") {
                    print("🔍 Trying pattern matching for dynamic URL")

                    // Replace dynamic endpoint ID in user's URL with placeholder
                    let regex = try? NSRegularExpression(pattern: "ep-[a-z0-9-]+", options: [])
                    let normalizedURL = regex?.stringByReplacingMatches(
                        in: baseURL,
                        options: [],
                        range: NSRange(location: 0, length: baseURL.utf16.count),
                        withTemplate: "ep-xxx-xxxxxxx"
                    ) ?? baseURL

                    print("🔄 Normalized URL: \(normalizedURL)")
                    print("📝 Template URL: \(templateURL)")

                    if normalizedURL == templateURL {
                        print("✅ Pattern matched for dynamic URL!")

                        // Additional validation
                        if isValidProviderForTemplate(baseURL: baseURL, template: template, env: env) {
                            print("🎯 Template and configuration validated!")
                            return template
                        } else {
                            print("⚠️ Pattern matched but configuration seems invalid for this template")
                        }
                    } else {
                        print("❌ Pattern did not match: \(normalizedURL) != \(templateURL)")
                    }
                }
            }
        }
        print("❌ No template matched")
        return nil
    }

    private func isValidProviderForTemplate(baseURL: String, template: ProviderTemplate, env: [String: EnvValue]) -> Bool {
        // For Zhipu AI, validate the URL pattern and token format
        if template.name == "Zhipu AI" {
            // Zhipu AI should have the specific base URL
            guard baseURL == "https://open.bigmodel.cn/api/anthropic" else {
                return false
            }

            // Token should be in expected format (length and pattern)
            guard let token = env["ANTHROPIC_AUTH_TOKEN"]?.value else { return false }

            // Zhipu AI tokens are typically 32 chars + ".W7Gu3qS0k5isSImL" pattern
            return token.count >= 20
        }

        // For StreamLake, validate the URL pattern
        if template.name == "StreamLake" {
            // StreamLake should contain the specific base URL pattern
            guard baseURL.contains("streamlakeapi.com") && baseURL.contains("claude-code-proxy") else {
                return false
            }

            // Token should be present and reasonably long
            guard let token = env["ANTHROPIC_AUTH_TOKEN"]?.value else { return false }
            return token.count >= 10
        }

        // For other future templates, add specific validation logic here
        return true
    }
}