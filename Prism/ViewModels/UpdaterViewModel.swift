//
//  UpdaterViewModel.swift
//  Prism
//
//  Created by 十里 on 2025/10/10.
//

import SwiftUI
import Sparkle
import Combine

class UpdaterViewModel {
    
    static let shared = UpdaterViewModel()
    
    @Published var updateAvailable: Bool = false
    @Published var foundItem: SUAppcastItem? = nil

    // 由 AppDelegate 注入
    var updaterController: SPUStandardUpdaterController?

    func presentUpdateUI() {
        // 调用 Sparkle 默认 UI（只在需要时点击触发）
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
