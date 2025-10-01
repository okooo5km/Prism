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

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Import existing configuration on app launch
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            ConfigImportService.shared.importExistingConfigurationIfNeeded()
        }
    }
}
