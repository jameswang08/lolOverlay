//
//  AppDelegate.swift
//  lolOverlay
//
//  Created by jam on 7/3/25.
//

import AppKit
import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: OverlayWindow?
    private let viewModel = GameStateViewModel()
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        viewModel.$isGameInProgress
            .sink { [weak self] isGameInProgress in
                DispatchQueue.main.async {
                    isGameInProgress ? self?.showOverlay() : self?.hideOverlay()
                }
            }
            .store(in: &cancellables)
    }

    func showOverlay() {
        guard window == nil else { return }
        let contentView = OverlayView(viewModel: viewModel)
        let hostingView = NSHostingView(rootView: contentView)
        hostingView.frame = NSScreen.main?.frame ?? .zero
        hostingView.autoresizingMask = [.width, .height]
        hostingView.wantsLayer = true
        hostingView.layer?.backgroundColor = NSColor.clear.cgColor
        window = OverlayWindow(contentView: hostingView)
        print("Overlay shown with frame: \(window?.frame ?? .zero)")
    }

    func hideOverlay() {
        window?.orderOut(nil)
        window = nil
        print("Overlay hidden")
    }
}
