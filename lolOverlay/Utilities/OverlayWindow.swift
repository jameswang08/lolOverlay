//
//  OverlayWindow.swift
//  lolOverlay
//
//  Created by jam on 7/4/25.
//


import AppKit
import SwiftUI

// Base window that contains everything for this overlay
class OverlayWindow: NSWindow {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    init(contentView: NSView) {
        let screenFrame = NSScreen.main?.frame ?? .zero
        super.init(
            contentRect: screenFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        self.level = NSWindow.Level(rawValue: 2_000_000)
        self.isOpaque = false
        self.backgroundColor = .clear
        self.ignoresMouseEvents = true
        self.contentView = contentView
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.makeKeyAndOrderFront(nil)
    }
}
