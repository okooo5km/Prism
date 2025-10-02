//
//  SandboxAccessManager.swift
//  Prism
//
//  Created by okooo5km(十里) on 2025/10/2.
//

import Foundation
import AppKit
import UniformTypeIdentifiers

/// Manages sandbox file access permissions using Security-Scoped Bookmarks
@Observable
class SandboxAccessManager {
    static let shared = SandboxAccessManager()

    private let bookmarkKey = "claude_settings_bookmark"
    private let settingsPath = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".claude/settings.json")

    var hasAccess: Bool = false
    var isRequestingAccess: Bool = false

    private init() {
        _ = checkAccess()
    }

    /// Check if we have access to settings.json
    func checkAccess() -> Bool {
        // Try to restore from bookmark first
        if let bookmark = UserDefaults.standard.data(forKey: bookmarkKey) {
            do {
                var isStale = false
                let url = try URL(
                    resolvingBookmarkData: bookmark,
                    options: .withSecurityScope,
                    relativeTo: nil,
                    bookmarkDataIsStale: &isStale
                )

                if isStale {
                    print("⚠️ Bookmark is stale, need to re-request access")
                    hasAccess = false
                    return false
                }

                // Test if we can actually access the file
                if url.startAccessingSecurityScopedResource() {
                    defer { url.stopAccessingSecurityScopedResource() }

                    if FileManager.default.isReadableFile(atPath: url.path) {
                        hasAccess = true
                        return true
                    }
                }
            } catch {
                print("❌ Failed to resolve bookmark: \(error)")
            }
        }

        // Check if file exists and is accessible (non-sandbox mode)
        if FileManager.default.isReadableFile(atPath: settingsPath.path) {
            hasAccess = true
            return true
        }

        hasAccess = false
        return false
    }

    /// Request access to .claude directory via file picker
    @MainActor
    func requestAccess() async -> Bool {
        isRequestingAccess = true
        defer { isRequestingAccess = false }

        let openPanel = NSOpenPanel()
        openPanel.message = NSLocalizedString("Grant access to .claude directory", comment: "File picker title")
        openPanel.prompt = NSLocalizedString("Grant Access", comment: "File picker button")
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.canCreateDirectories = false
        openPanel.showsHiddenFiles = true
        openPanel.treatsFilePackagesAsDirectories = false

        // Always open home directory with hidden files shown
        // (NSOpenPanel cannot directly open hidden directories like ~/.claude)
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        openPanel.directoryURL = homeDir
        print("📂 Opening file picker at home directory (showing hidden files)")

        let response = openPanel.runModal()

        guard response == .OK, let url = openPanel.url else {
            return false
        }

        // Verify the selected directory is .claude
        guard url.lastPathComponent == ".claude" else {
            showAlert(
                title: NSLocalizedString("Invalid Directory", comment: "Error alert title"),
                message: NSLocalizedString("Please select .claude directory", comment: "Error alert message")
            )
            return false
        }

        // Create and save bookmark
        do {
            let bookmarkData = try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            UserDefaults.standard.set(bookmarkData, forKey: bookmarkKey)
            hasAccess = true

            print("✅ Successfully saved bookmark for .claude directory")
            return true
        } catch {
            print("❌ Failed to create bookmark: \(error)")
            showAlert(
                title: NSLocalizedString("Permission Error", comment: "Error alert title"),
                message: NSLocalizedString("Failed to save directory access permission", comment: "Error alert message")
            )
            return false
        }
    }

    /// Execute a block with security-scoped access to settings.json
    func withSecureAccess<T>(_ block: (URL) throws -> T) throws -> T {
        if let bookmark = UserDefaults.standard.data(forKey: bookmarkKey) {
            var isStale = false
            let url = try URL(
                resolvingBookmarkData: bookmark,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )

            guard url.startAccessingSecurityScopedResource() else {
                throw NSError(
                    domain: "SandboxAccessManager",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to access security-scoped resource"]
                )
            }

            defer { url.stopAccessingSecurityScopedResource() }
            return try block(url)
        }

        // Fallback to direct path (non-sandbox mode)
        return try block(settingsPath)
    }

    /// Clear saved bookmark (for testing/reset)
    func clearBookmark() {
        UserDefaults.standard.removeObject(forKey: bookmarkKey)
        hasAccess = false
        print("🗑️ Cleared bookmark")
    }

    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = message
            alert.alertStyle = .warning
            alert.addButton(withTitle: NSLocalizedString("OK", comment: ""))
            alert.runModal()
        }
    }
}
