//
//  PermissionOverlay.swift
//  Prism
//
//  Created by okooo5km(十里) on 2025/10/3.
//

import SwiftUI
import AppKit

struct PermissionOverlay: View {
    @State private var isRequesting = false
    @State private var sandboxManager = SandboxAccessManager.shared

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            VStack(spacing: 16) {
                Text("File Access Required")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Prism needs access to Claude Code configuration directory:")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                Text("~/.claude/settings.json")
                    .font(.system(.body, design: .monospaced))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.primary.opacity(0.05))
                    .cornerRadius(8)

                Button(action: {
                    requestAccess()
                }) {
                    HStack {
                        Image(systemName: isRequesting ? "arrow.clockwise" : "checkmark.shield")
                        Text(isRequesting ? "Granting Access..." : "Grant Access")
                    }
                    .styledContainer(style: .selected)
                }
                .buttonStyle(.plain)
                .disabled(isRequesting)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
        .zIndex(1)
    }

    private func requestAccess() {
        isRequesting = true

        Task {
            let success = await SandboxAccessManager.shared.requestAccess()

            isRequesting = false

            if success {
                // Access granted, the overlay will hide automatically
                print("✅ Permission granted from overlay")
            }
        }
    }
}
