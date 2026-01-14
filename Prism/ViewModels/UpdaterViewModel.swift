//
//  UpdaterViewModel.swift
//  Prism
//
//  Created by okooo5km(十里) on 2025/10/10.
//

import SwiftUI
import Sparkle
import Combine

class UpdaterViewModel {
    
    static let shared = UpdaterViewModel()
    
    @Published var updateAvailable: Bool = false
    @Published var foundItem: SUAppcastItem? = nil

    // Injected by AppDelegate
    var updaterController: SPUStandardUpdaterController?

    func presentUpdateUI() {
        // Trigger Sparkle default UI (on-demand check)
        updaterController?.checkForUpdates(nil)
    }

    func refreshInBackground() {
        // Only check in background if automatic checks are enabled
        // This prevents the warning when SUEnableAutomaticChecks is not set
        guard let updater = updaterController?.updater,
              updater.automaticallyChecksForUpdates else {
            return
        }
        updater.checkForUpdatesInBackground()
    }
}
