//
//  PermissionWindow.swift
//  Prism
//
//  Created by okooo5km(十里) on 2025/10/2.
//

import SwiftUI
import AppKit

class PermissionWindow: NSWindow {
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 480),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        self.center()
        self.isReleasedWhenClosed = false
        self.level = .normal
        
        self.titlebarAppearsTransparent = true
        self.titleVisibility = .hidden
        
        self.backgroundColor = .clear
        
        self.isMovable = true
        self.isMovableByWindowBackground = false

        // Create SwiftUI view and set as content
        let contentView = PermissionRequestView {
            // Permission granted callback
            self.close()

            // Notify app to continue
            NotificationCenter.default.post(name: .permissionGranted, object: nil)
        }

        self.contentView = NSHostingView(rootView: contentView)
    }
}

extension Notification.Name {
    static let permissionGranted = Notification.Name("permissionGranted")
}
