//
//  ContentView.swift
//  Prism
//
//  Created by okooo5km(十里) on 2025/9/30.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = ContentViewModel()
    @State private var showQuitAlert: Bool = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1"
    }

    var body: some View {
        VStack(spacing: 0) {
            switch viewModel.currentView {
            case .main:
                mainView
            case .add:
                AddEditProviderView(
                    provider: nil,
                    onSave: { savedProvider in
                        viewModel.addProvider(savedProvider)
                        viewModel.backToMain()
                    },
                    onCancel: {
                        viewModel.backToMain()
                    }
                )
            case .edit(let provider):
                AddEditProviderView(
                    provider: provider,
                    onSave: { savedProvider in
                        viewModel.updateProvider(savedProvider)
                        viewModel.backToMain()
                    },
                    onCancel: {
                        viewModel.backToMain()
                    }
                )
            }
        }
        .background(.clear)
        .frame(width: 360)
    }

    private var mainView: some View {
        VStack(spacing: 8) {
            headerView
            providerListView
            footerView
        }
        .padding(12)
    }

    private var headerView: some View {
        HStack {
            HStack(spacing: 6) {
                if let provider = viewModel.activeProvider {
                    Image(provider.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                } else {
                    Image("ClaudeLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                }

                Text(viewModel.activeProvider?.name ?? "Default")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
            }

            Spacer()

            Button(action: {
                viewModel.showAddProvider()
            }) {
                Image(systemName: "plus")
                    .font(.title2)
                    .padding(4)
                    .background(.background.opacity(0.001))
            }
            .buttonStyle(.plain)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "plus.circle.dashed")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No API Providers")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Add your first API provider to get started")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var providerListView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                // Default provider row
                DefaultProviderRowView(
                    isActive: viewModel.isDefaultActive,
                    onActivate: {
                        viewModel.activateDefault()
                    }
                )

                // User-added providers
                ForEach(viewModel.providers) { provider in
                    ProviderRowView(
                        provider: provider,
                        isActive: provider.isActive,
                        onActivate: {
                            viewModel.activateProvider(provider)
                        },
                        onEdit: {
                            viewModel.showEditProvider(provider)
                        },
                        onDelete: {
                            viewModel.deleteProvider(provider)
                        }
                    )
                }
            }
        }
        .frame(maxHeight: 320)
    }

    private var footerView: some View {
        HStack {
            Spacer()
            Text("Prism v\(appVersion)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.tertiary)
            Spacer()
        }
        .padding(.vertical, 4)
        .overlay(alignment: .trailing) {
            Button(action: {
                showQuitAlert = true
            }, label: {
                Image(systemName: "xmark")
                    .font(.caption)
                    .padding(6)
                    .background(cornerRadius: 8, fill: .background.opacity(0.8))
            })
            .buttonStyle(.plain)
            .popover(isPresented: $showQuitAlert) {
                VStack {
                    Text("Quit Prism now?")
                        .font(.caption)
                    
                    HStack(spacing: 12) {
                        Button("No") {
                            showQuitAlert = false
                        }
                        .buttonStyle(.gradient(configuration: .primary))
                        .controlSize(.small)

                        Button("Yes") {
                            NSApplication.shared.terminate(nil)
                        }
                        .buttonStyle(.gradient(configuration: .danger2))
                        .controlSize(.small)
                        .tint(.red)
                    }
                    .font(.caption)
                }
                .padding(16)
            }
        }
    }
}

struct ProviderRowView: View {
    let provider: Provider
    let isActive: Bool
    let onActivate: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var showingDeleteConfirmation = false

    var body: some View {
        HStack {
            HStack(alignment: .top, spacing: 8) {
                Image(provider.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)

                VStack(alignment: .leading, spacing: 2) {
                    Text(provider.name)
                        .font(.headline)
                        .fontWeight(.semibold)

                    Text(provider.envVariables["ANTHROPIC_BASE_URL"] ?? "")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .truncationMode(.middle)
                        .lineLimit(1)
                }
            }

            Spacer()

            if isActive {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
            }

            HStack(spacing: 8) {
                Button(action: {
                    print("🔧 Edit button clicked for provider: \(provider.name)")
                    onEdit()
                }) {
                    Image(systemName: "info.circle.fill")
                }
                .buttonStyle(.plain)
                .help("Edit Provider")

                Button(action: {
                    showingDeleteConfirmation = true
                }) {
                    Image(systemName: "minus.circle.fill")
                }
                .buttonStyle(.plain)
                .help("Delete Provider")
                .popover(isPresented: $showingDeleteConfirmation) {
                    DeleteConfirmationPopover(
                        providerName: provider.name,
                        onConfirm: {
                            onDelete()
                            showingDeleteConfirmation = false
                        },
                        onCancel: {
                            showingDeleteConfirmation = false
                        }
                    )
                }
            }
            .font(.title3)
        }
        .styledContainer(style: isActive ? .selected : .notSelected)
        .onTapGesture {
            if !isActive {
                onActivate()
            }
        }
    }
}

struct DefaultProviderRowView: View {
    let isActive: Bool
    let onActivate: () -> Void

    var body: some View {
        HStack {
            HStack(alignment: .top, spacing: 8) {
                Image("ClaudeLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Claude Default")
                        .font(.headline)
                        .fontWeight(.semibold)

                    Text("Login with Claude (Console) account")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .truncationMode(.middle)
                        .lineLimit(1)
                }
            }

            Spacer()

            if isActive {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.primary)
                    .font(.title3)
            }
        }
        .styledContainer(style: isActive ? .selected : .notSelected)
        .onTapGesture {
            if !isActive {
                onActivate()
            }
        }
    }
}

struct DeleteConfirmationPopover: View {
    let providerName: String
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text("Delete Provider")
                    .font(.headline)
                    .fontWeight(.semibold)

                Text("Are you sure you want to delete \"\(providerName)\"? This action cannot be undone.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 200)
            }

            HStack(spacing: 12) {
                Button("Cancel") {
                    onCancel()
                }
                .buttonStyle(.gradient(configuration: .primary))
                .controlSize(.small)

                Button("Delete") {
                    onConfirm()
                }
                .buttonStyle(.gradient(configuration: .danger2))
                .controlSize(.small)
                .tint(.red)
            }
            .font(.caption)
        }
        .padding(16)
        .frame(width: 240)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

#Preview {
    ContentView()
}
