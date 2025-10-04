//
//  AddEditProviderView.swift
//  Prism
//
//  Created by okooo5km(十里) on 2025/9/30.
//

import SwiftUI
import AppKit

struct AddEditProviderView: View {
    let provider: Provider?
    let onSave: (Provider) -> Void
    let onCancel: () -> Void
    let onCheckDuplicate: (String, String, UUID?) -> TokenCheckResult

    @State private var providerName: String
    @State private var selectedTemplate: ProviderTemplate?
    @State private var envVariables: [String: EnvValue]
    @State private var baseTemplateKeys: Set<String>
    @State private var templateDocLink: String?
    @State private var showingAddCustomVar = false
    @State private var newCustomKey = ""
    @State private var newCustomValue = ""
    @State private var newCustomType: EnvValueType = .string

    private var isSaveDisabled: Bool {
        // Provider name is required
        if providerName.isEmpty {
            return true
        }

        // BASE_URL and AUTH_TOKEN are required
        let baseURL = envVariables["ANTHROPIC_BASE_URL"]?.value ?? ""
        let authToken = envVariables["ANTHROPIC_AUTH_TOKEN"]?.value ?? ""

        return baseURL.isEmpty || authToken.isEmpty
    }
    
    init(
        provider: Provider?,
        onSave: @escaping (Provider) -> Void,
        onCancel: @escaping () -> Void,
        onCheckDuplicate: @escaping (String, String, UUID?) -> TokenCheckResult
    ) {
        self.provider = provider
        self.onSave = onSave
        self.onCancel = onCancel
        self.onCheckDuplicate = onCheckDuplicate

        print("🔧 AddEditProviderView init - provider: \(provider?.name ?? "nil")")

        if let provider = provider {
            // Editing existing provider - infer template from BASE_URL
            let inferredTemplate = Self.inferTemplate(from: provider)
            _baseTemplateKeys = State(initialValue: Set(inferredTemplate?.envVariables.keys ?? provider.envVariables.keys))
            _templateDocLink = State(initialValue: inferredTemplate?.docLink)
            _providerName = State(initialValue: provider.name)
            _envVariables = State(initialValue: provider.envVariables)
            _selectedTemplate = State(initialValue: nil)
        } else {
            // Adding new provider - use first template as default
            let firstTemplate = ProviderTemplate.allTemplates.first!
            _baseTemplateKeys = State(initialValue: Set(firstTemplate.envVariables.keys))
            _templateDocLink = State(initialValue: firstTemplate.docLink)
            _providerName = State(initialValue: firstTemplate.name)
            _envVariables = State(initialValue: firstTemplate.envVariables)
            _selectedTemplate = State(initialValue: firstTemplate)
        }

        print("🔧 Initial state - name: '\(providerName)', envVars: \(envVariables)")
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                Button(action: {
                    onCancel()
                }) {
                    Image(systemName: "chevron.backward")
                        .font(.title2)
                        .padding(2)
                        .background(.background.opacity(0.001))
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text(provider == nil ?
                     "Add Provider" : "Edit Provider")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    // Check token duplicate before saving
                    let token = envVariables["ANTHROPIC_AUTH_TOKEN"]?.value ?? ""
                    let baseURL = envVariables["ANTHROPIC_BASE_URL"]?.value ?? ""
                    let excludingID = provider?.id

                    let checkResult = onCheckDuplicate(token, baseURL, excludingID)

                    switch checkResult {
                    case .unique:
                        // No duplicate, proceed with save
                        saveProvider()
                    case .duplicateWithSameURL, .duplicateWithDifferentURL:
                        // Show NSAlert window
                        showDuplicateAlertWindow(for: checkResult)
                    }
                }, label: {
                    Label("Save", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                })
                .buttonStyle(.gradient(configuration: .primary))
                .disabled(isSaveDisabled)
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {

                    // Provider Template Picker
                    if provider == nil {
                        HorizontalTemplatePicker(
                            selection: $selectedTemplate,
                            templates: ProviderTemplate.allTemplates
                        )
                        .onChange(of: selectedTemplate) { _, newTemplate in
                            if let newTemplate = newTemplate {
                                // Preserve custom variables (not in current template)
                                let currentCustomVars = envVariables.filter { key, _ in
                                    !baseTemplateKeys.contains(key)
                                }

                                // Start with new template's base variables
                                var mergedVars = newTemplate.envVariables

                                // Add back custom variables (template takes priority on conflicts)
                                for (key, value) in currentCustomVars {
                                    if mergedVars[key] == nil {
                                        mergedVars[key] = value
                                    }
                                }

                                providerName = newTemplate.name
                                envVariables = mergedVars
                                baseTemplateKeys = Set(newTemplate.envVariables.keys)
                                templateDocLink = newTemplate.docLink
                            }
                        }
                    }

                    // Documentation Link (if available)
                    if let docLink = templateDocLink {
                        Button(action: {
                            if let url = URL(string: docLink) {
                                NSWorkspace.shared.open(url)
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "book.fill")
                                    .font(.caption)
                                Text("View Documentation")
                                    .font(.caption)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption2)
                            }
                            .foregroundStyle(
                                LinearGradient(colors: [Color(hex: "#55AAEF") ?? .blue, .blue], startPoint: .top, endPoint: .bottom)
                            )
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.blue.opacity(0.08))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(
                                        .blue.opacity(0.2),
                                        lineWidth: 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    // Provider Information
                    DetailTextFieldCardView(
                        title: LocalizedStringKey("Provider Name"),
                        systemImage: "person.text.rectangle",
                        placeholder: LocalizedStringKey("Enter provider name"),
                        value: $providerName
                    )

                    // Template Environment Variables
                    ForEach(templateKeys, id: \.self) { key in
                        if let envKey = EnvKey(rawValue: key) {
                            renderField(for: envKey)
                        }
                    }

                    // Custom Environment Variables Section
                    if !customKeys.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Custom Variables")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                                .fontWeight(.bold)
                                .padding(.top, 8)

                            ForEach(customKeys, id: \.self) { key in
                                renderCustomField(for: key)
                            }
                        }
                    }

                    // Add Custom Variable Button
                    Button(action: {
                        showingAddCustomVar = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Custom Variable")
                        }
                        .font(.subheadline)
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(cornerRadius: 8, strokeColor: .primary.opacity(0.08), fill: .background.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                    .popover(isPresented: $showingAddCustomVar, arrowEdge: .bottom) {
                        AddCustomVariableView(
                            key: $newCustomKey,
                            value: $newCustomValue,
                            type: $newCustomType,
                            onSave: {
                                if !newCustomKey.isEmpty {
                                    envVariables[newCustomKey] = EnvValue(value: newCustomValue, type: newCustomType)
                                    newCustomKey = ""
                                    newCustomValue = ""
                                    newCustomType = .string
                                    showingAddCustomVar = false
                                }
                            },
                            onCancel: {
                                newCustomKey = ""
                                newCustomValue = ""
                                newCustomType = .string
                                showingAddCustomVar = false
                            }
                        )
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
        }
    }

    // MARK: - Helper Computed Properties

    private var templateKeys: [String] {
        return envVariables.keys.filter { baseTemplateKeys.contains($0) }.sorted()
    }

    private var customKeys: [String] {
        return envVariables.keys.filter { !baseTemplateKeys.contains($0) }.sorted()
    }

    private func showDuplicateAlertWindow(for result: TokenCheckResult) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = NSLocalizedString("Token Already in Use", comment: "Duplicate token alert title")

        switch result {
        case .duplicateWithSameURL(let provider):
            alert.informativeText = String(format: NSLocalizedString("Token used by '%@' with same URL", comment: "Duplicate token with same URL warning"), provider.name)
        case .duplicateWithDifferentURL(let provider):
            alert.informativeText = String(format: NSLocalizedString("Token used by '%@' with different URL", comment: "Duplicate token with different URL warning"), provider.name)
        case .unique:
            alert.informativeText = NSLocalizedString("No conflict detected", comment: "No token conflict message")
        }

        alert.addButton(withTitle: NSLocalizedString("Cancel", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("Save Anyway", comment: "Save despite warning button"))

        let response = alert.runModal()
        if response == .alertSecondButtonReturn {
            // User clicked "Save Anyway"
            saveProvider()
        }
    }

    private func saveProvider() {
        // Filter out empty MODEL env variables
        var cleanedEnvVariables = envVariables
        let modelKeys = [
            "ANTHROPIC_DEFAULT_HAIKU_MODEL",
            "ANTHROPIC_DEFAULT_SONNET_MODEL",
            "ANTHROPIC_DEFAULT_OPUS_MODEL"
        ]
        for key in modelKeys {
            if let value = cleanedEnvVariables[key]?.value, value.isEmpty {
                cleanedEnvVariables.removeValue(forKey: key)
            }
        }

        let newProvider: Provider
        if let existingProvider = provider {
            // Editing: preserve id, isActive, and icon
            newProvider = Provider(
                id: existingProvider.id,
                name: providerName.isEmpty ? "Untitled Provider" : providerName,
                envVariables: cleanedEnvVariables,
                icon: existingProvider.icon,
                isActive: existingProvider.isActive
            )
        } else {
            // Adding: infer icon from BASE_URL
            let inferredIcon = ProviderStore.inferIcon(from: cleanedEnvVariables)
            newProvider = Provider(
                name: providerName.isEmpty ? "Untitled Provider" : providerName,
                envVariables: cleanedEnvVariables,
                icon: inferredIcon,
                isActive: false
            )
        }
        onSave(newProvider)
    }

    private func binding(for envKey: EnvKey) -> Binding<String> {
        Binding<String>(
            get: {
                envVariables[envKey.rawValue]?.value ?? ""
            },
            set: { newValue in
                let currentType = envVariables[envKey.rawValue]?.type ?? envKey.valueType
                envVariables[envKey.rawValue] = EnvValue(value: newValue, type: currentType)
            }
        )
    }

    private func boolBinding(for envKey: EnvKey) -> Binding<Bool> {
        Binding<Bool>(
            get: {
                let value = envVariables[envKey.rawValue]?.value ?? "0"
                return value == "1" || value.lowercased() == "true"
            },
            set: { newValue in
                envVariables[envKey.rawValue] = EnvValue(value: newValue ? "1" : "0", type: .boolean)
            }
        )
    }

    @ViewBuilder
    private func renderField(for envKey: EnvKey) -> some View {
        switch envKey.valueType {
        case .string:
            if envKey == .authToken {
                DetailSecureFieldCardView(
                    title: LocalizedStringKey(envKey.displayName),
                    systemImage: envKey.systemImage,
                    placeholder: LocalizedStringKey(envKey.placeholder),
                    required: true,
                    value: binding(for: envKey)
                )
            } else {
                DetailTextFieldCardView(
                    title: LocalizedStringKey(envKey.displayName),
                    systemImage: envKey.systemImage,
                    placeholder: LocalizedStringKey(envKey.placeholder),
                    required: envKey == .baseURL,
                    value: binding(for: envKey)
                )
            }
        case .integer:
            DetailTextFieldCardView(
                title: LocalizedStringKey(envKey.displayName),
                systemImage: envKey.systemImage,
                placeholder: LocalizedStringKey(envKey.placeholder),
                validation: { value in
                    value.isEmpty || Int(value) != nil
                },
                validationMessage: "Must be a valid integer",
                value: binding(for: envKey)
            )
        case .boolean:
            DetailSwitchCardView(
                title: LocalizedStringKey(envKey.displayName),
                systemImage: envKey.systemImage,
                value: boolBinding(for: envKey)
            )
        }
    }

    @ViewBuilder
    private func renderCustomField(for key: String) -> some View {
        if let envValue = envVariables[key] {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "gearshape")
                        Text(key)

                        Text(LocalizedStringKey(envValue.type.displayName))
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(cornerRadius: 4, fill: .secondary.opacity(0.2))
                    }
                    .foregroundStyle(.tertiary)
                    
                    Spacer()
                    
                    Button(action: {
                        envVariables.removeValue(forKey: key)
                    }) {
                        Image(systemName: "minus.circle.fill")
                    }
                    .buttonStyle(.plain)
                }
                .font(.subheadline)

                if envValue.type == .boolean {
                    Toggle("", isOn: Binding(
                        get: {
                            envValue.value == "1" || envValue.value.lowercased() == "true"
                        },
                        set: { newValue in
                            envVariables[key] = EnvValue(value: newValue ? "1" : "0", type: .boolean)
                        }
                    ))
                    .toggleStyle(.switch)
                    .controlSize(.mini)
                } else {
                    TextField("Value", text: Binding(
                        get: { envValue.value },
                        set: { newValue in
                            envVariables[key] = EnvValue(value: newValue, type: envValue.type)
                        }
                    ))
                    .font(.caption)
                    .textFieldStyle(.plain)
                    .padding(8)
                    .background(cornerRadius: 8, strokeColor: .primary.opacity(0.04), fill: .background)
                }
            }
            .padding(8)
            .background(cornerRadius: 12, strokeColor: .primary.opacity(0.08), fill: .background.opacity(0.6))
        }
    }

    // MARK: - Template Inference

    static func inferTemplate(from provider: Provider) -> ProviderTemplate? {
        guard let providerURLString = provider.envVariables["ANTHROPIC_BASE_URL"]?.value,
              !providerURLString.isEmpty,
              let providerURL = URL(string: providerURLString),
              let providerHost = providerURL.host else {
            return nil
        }

        return ProviderTemplate.allTemplates.first { template in
            guard let templateURLString = template.envVariables["ANTHROPIC_BASE_URL"]?.value,
                  !templateURLString.isEmpty,
                  let templateURL = URL(string: templateURLString),
                  let templateHost = templateURL.host else {
                return false
            }
            return providerHost == templateHost
        }
    }
}

// MARK: - Add Custom Variable View

struct AddCustomVariableView: View {
    @Binding var key: String
    @Binding var value: String
    @Binding var type: EnvValueType
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Add Custom Variable")
                .font(.headline)

            DetailTextFieldCardView(
                title: "Key",
                systemImage: "key",
                placeholder: "CUSTOM_ENV_KEY",
                required: true,
                value: $key
            )

            DetailPickerCardView(
                "Type",
                systemImage: "gear",
                selection: $type
            ) {
                Text("String").tag(EnvValueType.string)
                Text("Integer").tag(EnvValueType.integer)
                Text("Boolean").tag(EnvValueType.boolean)
            }

            if type == .boolean {
                DetailSwitchCardView(
                    title: "Value",
                    systemImage: "checkmark.circle",
                    value: Binding(
                        get: { value == "1" || value.lowercased() == "true" },
                        set: { value = $0 ? "1" : "0" }
                    )
                )
            } else {
                DetailTextFieldCardView(
                    title: "Value",
                    systemImage: "text.alignleft",
                    placeholder: type == .integer ? "123" : "value",
                    validation: { val in
                        if type == .integer && !val.isEmpty {
                            return Int(val) != nil
                        }
                        return true
                    },
                    validationMessage: "Must be a valid integer",
                    value: $value
                )
            }

            HStack {
                Button("Cancel") {
                    onCancel()
                }
                .buttonStyle(.plain)

                Spacer()

                Button("Save") {
                    onSave()
                }
                .buttonStyle(.gradient(configuration: .primary))
                .disabled(key.isEmpty)
            }
        }
        .padding()
        .frame(width: 400)
    }
}

#Preview {
    AddEditProviderView(
        provider: nil,
        onSave: { provider in
            print("Saved provider: \(provider.name)")
        },
        onCancel: {
            print("Cancelled")
        },
        onCheckDuplicate: { token, baseURL, excludingID in
            return .unique
        }
    )
}
