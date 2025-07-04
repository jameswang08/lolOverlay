//
//  lolOverlayApp.swift
//  lolOverlay
//
//  Created by jam on 7/3/25.
//

import AppKit

class OverlayWindow: NSWindow {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    init(contentView: NSView) {
        let screenFrame = NSScreen.main?.frame ?? .zero

        super.init(
            contentRect: screenFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false)

        self.level = .screenSaver
        self.isOpaque = false
        self.backgroundColor = .clear
        self.ignoresMouseEvents = true
        self.contentView = contentView
        self.makeKeyAndOrderFront(nil)
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    }
}
