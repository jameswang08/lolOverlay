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
    var pollClient: PollClient!

    func applicationDidFinishLaunching(_ notification: Notification) {
        pollClient = PollClient()
        pollClient.onGameStarted = { [weak self] in
            self?.showOverlay()
        }
        pollClient.onGameStopped = { [weak self] in
            self?.hideOverlay()
        }
        pollClient.startPolling()
    }

    func showOverlay() {
        guard window == nil else { return } // Skip if already shown

        let contentView = JungleTimerView()
        let hostingView = NSHostingView(rootView: contentView)
        hostingView.frame = NSScreen.main?.frame ?? .zero
        hostingView.autoresizingMask = [.width, .height]
        hostingView.wantsLayer = true
        hostingView.layer?.backgroundColor = NSColor.clear.cgColor

        window = OverlayWindow(contentView: hostingView)
        window?.orderFrontRegardless()
        window?.level = NSWindow.Level(rawValue: 2_000_000) // above game windows

        print("Overlay shown with frame: \(window?.frame ?? .zero)")
    }

    func hideOverlay() {
        window?.orderOut(nil)
        window = nil
        print("Overlay hidden")
    }
}


