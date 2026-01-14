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
            // Use template keys if matched, otherwise use core EnvKey variables as fallback
            _baseTemplateKeys = State(initialValue: inferredTemplate.map { Set($0.envVariables.keys) } ?? Set(EnvKey.allCases.map { $0.rawValue }))
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
                        DetailTemplatePickerCardView(
                            title: LocalizedStringKey("Provider Template"),
                            systemImage: "square.grid.2x2",
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
                            Text("Add Environment Variable")
                        }
                        .font(.subheadline)
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(cornerRadius: 8, strokeColor: .primary.opacity(0.08), fill: .background.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                    .popover(isPresented: $showingAddCustomVar, arrowEdge: .bottom) {
                        AddCustomVariableView(
                            existingKeys: Set(envVariables.keys),
                            onSave: { key, envValue in
                                envVariables[key] = envValue
                                    showingAddCustomVar = false
                            },
                            onCancel: {
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
        let description = ClaudeEnvVariable.find(byName: envKey.rawValue)?.description
        
        switch envKey.valueType {
        case .string:
            if envKey == .authToken {
                DetailSecureFieldCardView(
                    title: LocalizedStringKey(envKey.displayName),
                    systemImage: envKey.systemImage,
                    placeholder: LocalizedStringKey(envKey.placeholder),
                    required: true,
                    description: description,
                    value: binding(for: envKey)
                )
            } else {
                DetailTextFieldCardView(
                    title: LocalizedStringKey(envKey.displayName),
                    systemImage: envKey.systemImage,
                    placeholder: LocalizedStringKey(envKey.placeholder),
                    required: envKey == .baseURL,
                    description: description,
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
                description: description,
                value: binding(for: envKey)
            )
        case .boolean:
            DetailSwitchCardView(
                title: LocalizedStringKey(envKey.displayName),
                systemImage: envKey.systemImage,
                description: description,
                value: boolBinding(for: envKey)
            )
        }
    }

    @ViewBuilder
    private func renderCustomField(for key: String) -> some View {
        if let envValue = envVariables[key] {
            let variableInfo = ClaudeEnvVariable.find(byName: key)
            let displayName = variableInfo?.shortName ?? key
            let description = variableInfo?.description
            
            switch envValue.type {
            case .string:
                DetailTextFieldCardView(
                    title: LocalizedStringKey(displayName),
                    systemImage: "gearshape",
                    placeholder: "Enter value",
                    description: description,
                    onDelete: { envVariables.removeValue(forKey: key) },
                    value: customBinding(for: key, type: envValue.type)
                )
            case .integer:
                DetailTextFieldCardView(
                    title: LocalizedStringKey(displayName),
                    systemImage: "gearshape",
                    placeholder: "Enter a number",
                    validation: { value in
                        value.isEmpty || Int(value) != nil
                    },
                    validationMessage: "Must be a valid integer",
                    description: description,
                    onDelete: { envVariables.removeValue(forKey: key) },
                    value: customBinding(for: key, type: envValue.type)
                )
            case .boolean:
                DetailSwitchCardView(
                    title: LocalizedStringKey(displayName),
                    systemImage: "gearshape",
                    description: description,
                    onDelete: { envVariables.removeValue(forKey: key) },
                    value: customBoolBinding(for: key)
                )
                    }
        }
    }
    
    private func customBinding(for key: String, type: EnvValueType) -> Binding<String> {
        Binding<String>(
            get: { envVariables[key]?.value ?? "" },
            set: { newValue in
                envVariables[key] = EnvValue(value: newValue, type: type)
            }
        )
    }
    
    private func customBoolBinding(for key: String) -> Binding<Bool> {
        Binding<Bool>(
                        get: {
                let value = envVariables[key]?.value ?? "0"
                return value == "1" || value.lowercased() == "true"
                        },
                        set: { newValue in
                            envVariables[key] = EnvValue(value: newValue ? "1" : "0", type: .boolean)
                        }
        )
        }
    }

    // MARK: - Template Inference

extension AddEditProviderView {
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
    let existingKeys: Set<String>
    let onSave: (String, EnvValue) -> Void
    let onCancel: () -> Void

    @State private var searchText = ""
    @State private var selectedVariable: ClaudeEnvVariable?
    @State private var value = ""

    private var availableVariables: [ClaudeEnvVariable] {
        let filtered = ClaudeEnvVariable.availableVariables(excluding: existingKeys)
        if searchText.isEmpty {
            return filtered
        }
        let lowercasedQuery = searchText.lowercased()
        return filtered.filter {
            $0.name.lowercased().contains(lowercasedQuery) ||
            $0.description.lowercased().contains(lowercasedQuery)
        }
    }

    private var isSaveDisabled: Bool {
        selectedVariable == nil
    }

    var body: some View {
        VStack(spacing: 12) {
            // Header
            Text("Add Environment Variable")
                .font(.headline)

            // Variable selection from list
            variableSelectionView

            // Value input (shown when a variable is selected)
            if selectedVariable != nil {
                valueInputView
            }

            // Action buttons
            HStack {
                Button("Cancel") {
                    onCancel()
                }
                .buttonStyle(.gradient(configuration: .danger))

                Spacer()

                Button("Add") {
                    if let variable = selectedVariable {
                        let envValue = EnvValue(value: value, type: variable.type)
                        onSave(variable.name, envValue)
                    }
                }
                .buttonStyle(.gradient(configuration: .primary))
                .disabled(isSaveDisabled)
            }
        }
        .padding()
        .frame(width: 420)
    }

    @ViewBuilder
    private var variableSelectionView: some View {
        VStack(spacing: 8) {
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.tertiary)
                TextField("Search variables...", text: $searchText)
                    .textFieldStyle(.plain)
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.tertiary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(cornerRadius: 8, strokeColor: .primary.opacity(0.08), fill: .background.opacity(0.6))

            // Variable list
            ScrollView {
                LazyVStack(spacing: 6) {
                    if availableVariables.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "tray")
                                .font(.largeTitle)
                                .foregroundStyle(.tertiary)
                            Text("No available variables")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if !searchText.isEmpty {
                                Text("Try a different search term")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        ForEach(availableVariables) { variable in
                            EnvVariableRow(
                                variable: variable,
                                isSelected: selectedVariable?.name == variable.name,
                                onSelect: {
                                    selectedVariable = variable
                                    // Set default value if available
                                    value = variable.defaultValue ?? ""
                                }
                            )
                        }
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 4)
            }
            .frame(maxHeight: 320)
            }
    }

    @ViewBuilder
    private var valueInputView: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let variable = selectedVariable {
                // Value input based on type
                if variable.type == .boolean {
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
                        placeholder: placeholderForVariable(variable),
                    validation: { val in
                            if variable.type == .integer && !val.isEmpty {
                            return Int(val) != nil
                        }
                        return true
                    },
                    validationMessage: "Must be a valid integer",
                    value: $value
                )
            }
            }
        }
    }

    private func placeholderForVariable(_ variable: ClaudeEnvVariable) -> LocalizedStringKey {
        if let defaultValue = variable.defaultValue, !defaultValue.isEmpty {
            return LocalizedStringKey(defaultValue)
        }
        if variable.type == .integer {
            return "Enter a number"
        }
        return "Enter value"
    }
}

// MARK: - Environment Variable Row

struct EnvVariableRow: View {
    let variable: ClaudeEnvVariable
    let isSelected: Bool
    let onSelect: () -> Void

    private var typeStyle: StyledContainerStyle {
        switch variable.type {
        case .string:
            return .pro
        case .integer:
            return .success
        case .boolean:
            return .warning
        }
    }

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 8) {
                // Variable info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(variable.name)
                            .font(.caption)
                            .fontWeight(.medium)
                            .lineLimit(1)

                        // Type badge - use simple background to avoid nesting conflict
                        Text(variable.type.displayName)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            colors: typeStyle.backgroundGradient,
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            )
                    }

                    // Always show description
                    Text(variable.description)
                        .font(.caption2)
                        .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
                        .lineLimit(2)
                }

                Spacer()
            }
            .styledContainer(style: isSelected ? .selected : .notSelected)
            .contentShape(Rectangle())
                }
        .buttonStyle(.plain)
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
