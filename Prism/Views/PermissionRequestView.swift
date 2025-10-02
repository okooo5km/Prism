//
//  PermissionRequestView.swift
//  Prism
//
//  Created by okooo5km(十里) on 2025/10/2.
//

import SwiftUI

struct PermissionRequestView: View {
    let onGranted: () -> Void
    @State private var isRequesting = false
    @State private var sandboxManager = SandboxAccessManager.shared
    @State private var hasJustGrantedAccess = false
    
    var body: some View {
        ZStack {
            
            VibrantBG()
            
            VStack(spacing: 16) {
                // Icon
                Image(nsImage: NSApplication.shared.applicationIconImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                
                // Title
                Label(hasJustGrantedAccess ? "Access Granted!" : "File Access Required", systemImage: hasJustGrantedAccess ? "checkmark.circle.fill" : "lock.shield")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                // Description
                VStack(spacing: 12) {
                    Text("Prism needs access to Claude Code configuration file:")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                    
                    Text("~/.claude/settings.json")
                        .font(.system(.body, design: .monospaced))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.primary.opacity(0.05))
                        .cornerRadius(8)
                    
                    Text("This allows Prism to switch API providers for you.")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                }
                
                if hasJustGrantedAccess {
                    HStack {
                        Image(systemName: "checkmark.shield")
                        Text("The Window will be closed")
                    }
                    .styledContainer(style: .selected)
                    .padding(.vertical, 16)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            onGranted()
                        }
                    }
                } else {
                    // Grant Access Button
                    Button(action: {
                        Task {
                            isRequesting = true
                            let success = await SandboxAccessManager.shared.requestAccess()
                            isRequesting = false
                            
                            if success {
                                handleAccessGranted()
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: isRequesting ? "arrow.clockwise" : "checkmark.shield")
                            Text(isRequesting ? "Granting Access..." : (hasJustGrantedAccess ? "Success!" : "Grant Access"))
                        }
                        .styledContainer(style: .selected)
                    }
                    .buttonStyle(.plain)
                    .disabled(isRequesting || hasJustGrantedAccess)
                    .padding(.vertical, 16)
                }
                
                // Help Text
                VStack(spacing: 12) {
                    Text("What happens next:")
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HelpStepView(number: "1", text: LocalizedStringKey("Navigate to ~/.claude directory"))
                        HelpStepView(number: "2", text: LocalizedStringKey("Select .claude directory"))
                        HelpStepView(number: "3", text: LocalizedStringKey("Click \"Grant Access\" button"))
                    }
                    .background {
                        HStack {
                            Rectangle()
                                .frame(width: 1, height: 48)
                                .padding(.leading, 5.5)
                                .foregroundStyle(.primary.opacity(0.1))
                            Spacer()
                        }
                    }
                    .padding(12)
                    .background(cornerRadius: 12, fill: .background.opacity(0.5))
                }
                .padding(.horizontal, 32)
            }
        }
        .frame(width: 360)
        .background(.clear)
        .ignoresSafeArea(.all)
        .onChange(of: sandboxManager.hasAccess) { _, hasAccess in
            if hasAccess && !hasJustGrantedAccess {
                withAnimation(.easeOut(duration: 0.3)) {
                    hasJustGrantedAccess = true
                }
            }
        }
    }
    
    private func handleAccessGranted() {
        withAnimation(.easeOut(duration: 0.3)) {
            hasJustGrantedAccess = true
        }
    }
}

struct HelpStepView: View {
    let number: String
    let text: LocalizedStringKey
    
    var body: some View {
        HStack(spacing: 8) {
            Text(number)
                .font(.system(size: 8))
                .fontWeight(.bold)
                .foregroundStyle(.background)
                .frame(width: 12, height: 12)
                .background(Color.primary)
                .clipShape(Circle())
            
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
}

#Preview {
    PermissionRequestView(onGranted: {
        print("Access granted")
    })
}
