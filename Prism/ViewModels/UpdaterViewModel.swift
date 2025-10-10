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

    func startAutomaticChecksIfNeeded() {
        // 可选：启动自动检查（间隔走 Info.plist 或用户偏好）
        // 也可以由视图启动一次后台检查
        updaterController?.updater.checkForUpdatesInBackground()
    }

    func presentUpdateUI() {
        // 调用 Sparkle 默认 UI（只在需要时点击触发）
        updaterController?.checkForUpdates(nil)
    }

    func refreshInBackground() {
        updaterController?.updater.checkForUpdatesInBackground()
    }
}
