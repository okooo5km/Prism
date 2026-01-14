//
//  PrismApp.swift
//  Prism
//
//  Created by okooo5km(十里) on 2025/9/30.
//

import SwiftUI
import AppKit
import Sparkle

@main
struct PrismApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, SPUUpdaterDelegate, SPUStandardUserDriverDelegate {
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        let updaterController = SPUStandardUpdaterController(startingUpdater: true,
                                                             updaterDelegate: self,
                                                             userDriverDelegate: self)
        
        NSApplication.shared.setActivationPolicy(.accessory)
        StatusBarController.shared.setup()
        
        UpdaterViewModel.shared.updaterController = updaterController
        // Sparkle will automatically check for updates based on SUEnableAutomaticChecks in Info.plist
        
        // Sync configuration on app startup
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            ConfigImportService.shared.syncConfigurationOnStartup()
        }
    }

    // MARK: - SPUUpdaterDelegate
    func updater(_ updater: SPUUpdater, didFindValidUpdate item: SUAppcastItem) {
        DispatchQueue.main.async {
            UpdaterViewModel.shared.foundItem = item
            UpdaterViewModel.shared.updateAvailable = true
        }
    }

    func updaterDidNotFindUpdate(_ updater: SPUUpdater) {
        DispatchQueue.main.async {
            UpdaterViewModel.shared.foundItem = nil
            UpdaterViewModel.shared.updateAvailable = false
        }
    }
    
    // Indicate app supports gentle reminders (suppresses console warnings)
    var supportsGentleScheduledUpdateReminders: Bool {
        return true
    }
    
    // Optional: customize reminder behavior
    // If not implemented, Sparkle uses system notification center
    func standardUserDriverShouldHandleShowingScheduledUpdate(_ update: SUAppcastItem, andInImmediateFocus immediateFocus: Bool) -> Bool {
        // Return true to handle UI yourself (e.g. badge on menu bar icon)
        // Return false for Sparkle default behavior (limited for background apps)
        return false
    }
}
