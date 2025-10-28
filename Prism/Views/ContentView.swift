//
//  ContentView.swift
//  Prism
//
//  Created by okooo5km(十里) on 2025/9/30.
//

import SwiftUI
import Sparkle

struct ContentView: View {
    @State private var viewModel = ContentViewModel()
    @State private var showQuitAlert: Bool = false
    
    @State private var updaterVM = UpdaterViewModel.shared
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1"
    }
    
    var body: some View {
        ZStack {
            mainView
                .opacity(viewModel.currentView == .main ? 1 : 0)
                .scaleEffect(viewModel.currentView == .main ? 1 : 0.95)
                .animation(.easeInOut(duration: 0.3), value: viewModel.currentView)
            
            if viewModel.currentView == .add {
                AddEditProviderView(
                    provider: nil,
                    onSave: { savedProvider in
                        viewModel.addProvider(savedProvider)
                        viewModel.backToMain()
                    },
                    onCancel: {
                        viewModel.backToMain()
                    },
                    onCheckDuplicate: { token, baseURL, excludingID in
                        viewModel.checkTokenDuplicate(token: token, baseURL: baseURL, excludingID: excludingID)
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
            }
            
            if case .edit(let provider) = viewModel.currentView {
                AddEditProviderView(
                    provider: provider,
                    onSave: { savedProvider in
                        viewModel.updateProvider(savedProvider)
                        viewModel.backToMain()
                    },
                    onCancel: {
                        viewModel.backToMain()
                    },
                    onCheckDuplicate: { token, baseURL, excludingID in
                        viewModel.checkTokenDuplicate(token: token, baseURL: baseURL, excludingID: excludingID)
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
            }
        }
        .background(.clear)
        .frame(width: 360, height: 360)
        .animation(.easeInOut(duration: 0.35), value: viewModel.currentView)
        .onAppear {
            viewModel.syncConfigurationState()
        }
    }
    
    private var mainView: some View {
        VStack(spacing: 8) {
            headerView
                .padding(.top, 12)
                .padding(.horizontal, 12)
            providerListView
            footerView
                .padding(.bottom, 12)
                .padding(.horizontal, 12)
        }
    }
    
    private var headerView: some View {
        HStack {
            HStack(spacing: 6) {
                if let provider = viewModel.activeProvider {
                    Image(provider.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                        .scaleEffect(1.0)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.7).combined(with: .opacity),
                            removal: .scale(scale: 1.3).combined(with: .opacity)
                        ))
                } else {
                    Image("ClaudeLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                        .scaleEffect(1.0)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.7).combined(with: .opacity),
                            removal: .scale(scale: 1.3).combined(with: .opacity)
                        ))
                }
                
                Text(viewModel.activeProvider?.name ?? String(localized: "Claude Default"))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .id(viewModel.activeProvider?.id.uuidString ?? String(localized: "Claude Default")) // Force view refresh for animation
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .scale(scale: 1.2).combined(with: .opacity)
                    ))
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.2), value: viewModel.activeProvider?.id)
            
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
            
            Text("No API Providers", comment: "Empty state title")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text("Add your first API provider to get started", comment: "Empty state message")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var providerListView: some View {
        ScrollView {
            VStack(spacing: 8) {
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
            .padding(.horizontal, 12)
        }
    }
    
    @State private var isHovering: Bool = false
    
    private var footerView: some View {
        HStack {
            Spacer()
            if updaterVM.updateAvailable {
                Button(action: {
                    updaterVM.presentUpdateUI()
                }, label: {
                    HStack(spacing: 3) {
                        Image(systemName: "sparkles")
                        Text("New Version")
                        if let item = updaterVM.foundItem {
                            Text(item.displayVersionString)
                        }
                    }
                    .font(.caption)
                    .styledContainer(style: .newVersion)
                })
                .buttonStyle(.plain)
            } else {
                Text("Prism v\(appVersion)", comment: "App version display format")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.tertiary)
                    .onTapGesture {
                        updaterVM.presentUpdateUI()
                    }
            }
            Spacer()
        }
        .overlay {
            HStack {
                Button(action: {
                    if let url = URL(string: "https://donate.stripe.com/fZueVd3vxgAz18X5wxasg0b") {
                        NSWorkspace.shared.open(url)
                    }
                }, label: {
                    HStack {
                        Image(systemName: "cup.and.saucer")
                            .background(.background.opacity(0.001))
                            .fontWeight(isHovering ? .medium : .regular)
                    }
                    .foregroundStyle(isHovering ? .primary : .tertiary)
                    .onHover(perform: { hovering in
                        withAnimation {
                            isHovering = hovering
                        }
                    })
                })
                .buttonStyle(.plain)
                
                Spacer()
                
                Button(action: {
                    showQuitAlert = true
                }, label: {
                    Image(systemName: "power")
                        .background(.background.opacity(0.001))
                })
                .buttonStyle(.plain)
                .popover(isPresented: $showQuitAlert) {
                    VStack {
                        Text("Quit Prism now?", comment: "Quit confirmation message")
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
                    
                    Text(provider.envVariables["ANTHROPIC_BASE_URL"]?.value ?? "")
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
                    Text("Claude Default", comment: "Default Claude provider name")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Login with Claude (Console) account", comment: "Description for default Claude provider")
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
                Text("Delete Provider", comment: "Delete confirmation dialog title")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("Are you sure you want to delete \"\(providerName)\"? This action cannot be undone.", comment: "Delete confirmation message")
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
