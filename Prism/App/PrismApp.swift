//
//  PrismApp.swift
//  Prism
//
//  Created by okooo5km(十里) on 2025/9/30.
//

import SwiftUI

@main
struct PrismApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra(
            "Prism",
            systemImage: "rectangle.2.swap"
        ) {
            ContentView()
        }
        .menuBarExtraStyle(.window)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var permissionWindow: PermissionWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Check sandbox access first
        let hasAccess = SandboxAccessManager.shared.checkAccess()

        if hasAccess {
            // Sync configuration on app startup if we have access
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                ConfigImportService.shared.syncConfigurationOnStartup()
            }
        } else {
            // Show permission request window
            print("⚠️ No access to settings.json, showing permission request window")
            showPermissionWindow()
        }

        // Listen for permission granted notification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePermissionGranted),
            name: .permissionGranted,
            object: nil
        )
    }

    private func showPermissionWindow() {
        DispatchQueue.main.async {
            if self.permissionWindow == nil {
                self.permissionWindow = PermissionWindow()
            }
            self.permissionWindow?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    @objc private func handlePermissionGranted() {
        print("✅ Permission granted, syncing configuration")

        // Close permission window
        permissionWindow?.close()
        permissionWindow = nil

        // Sync configuration
        ConfigImportService.shared.syncConfigurationOnStartup()
    }
}
