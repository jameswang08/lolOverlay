//
//  AppDelegate.swift
//  lolOverlay
//
//  Created by jam on 7/3/25.
//

import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: OverlayWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize overlay
        let contentView = OverlayView()
        let hostingView = NSHostingView(rootView: contentView)
        hostingView.frame = NSScreen.main?.frame ?? .zero
        hostingView.autoresizingMask = [.width, .height]

        hostingView.wantsLayer = true
        hostingView.layer?.backgroundColor = NSColor.clear.cgColor
        
        window = OverlayWindow(contentView: hostingView)
        window?.orderFrontRegardless()
        window?.level = NSWindow.Level(rawValue: 2_000_000) // fix to make this show in lol 
        print("Overlay window frame: \(window?.frame ?? .zero)")
    }
}
