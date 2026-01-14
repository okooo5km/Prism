//
//  VibrantBG.swift
//  Zipic
//
//  Created by okooo5km(十里) on 2023/5/14.
//

import SwiftUI

struct VibrantBG: NSViewRepresentable {

    @AppStorage("windowStyle")

    var material: NSVisualEffectView.Material = .underWindowBackground

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .underWindowBackground
        view.blendingMode = .behindWindow
        view.state = .active

        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        // Nothing to update
        nsView.blendingMode = .behindWindow
    }
}
