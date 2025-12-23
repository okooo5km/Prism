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
        // 可选：启动一次后台检查
        UpdaterViewModel.shared.startAutomaticChecksIfNeeded()
        
        // Sync configuration on app startup
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            ConfigImportService.shared.syncConfigurationOnStartup()
        }
    }

    // MARK: - SPUUpdaterDelegate（在 2.x 中仍支持这些回调）
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
    
    // 告诉 Sparkle 你的应用支持温和提醒
    // 这将消除控制台的 Warning
    var supportsGentleScheduledUpdateReminders: Bool {
        return true
    }
    
    // 可选：你可以进一步自定义提醒行为
    // 如果不实现此方法，Sparkle 会尝试使用系统通知中心发送更新提醒
    func standardUserDriverShouldHandleShowingScheduledUpdate(_ update: SUAppcastItem, andInImmediateFocus immediateFocus: Bool) -> Bool {
        // 返回 true 表示由你来处理 UI（比如在菜单栏图标上加个红点）
        // 返回 false 表示让 Sparkle 使用默认行为（但在后台应用中，默认行为已被限制，所以最好结合通知使用）
        return false
    }
}
