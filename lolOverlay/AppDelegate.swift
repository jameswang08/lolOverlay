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
    var pollingTimer: Timer?
    var pollInterval: TimeInterval = 5.0 // start with lazy polling
    var gameStarted = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        startPollingGameState()
    }

    func startPollingGameState() {
        pollingTimer = Timer.scheduledTimer(withTimeInterval: pollInterval, repeats: true) { [weak self] _ in
            self?.checkGameState()
        }
    }

    func checkGameState() {
        guard let lockfile = Lockfile.read() else {
            print("Lockfile unavailable, cannot check game state")
            return
        }

        let gameflowURL = URL(string: "https://127.0.0.1:\(lockfile.port)/lol-gameflow/v1/session")!
        var request = URLRequest(url: gameflowURL)
        request.timeoutInterval = 5

        let loginString = "riot:\(lockfile.token)"
        guard let loginData = loginString.data(using: .utf8) else { return }
        let base64LoginString = loginData.base64EncodedString()
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

        let session = URLSession(configuration: .default, delegate: IgnoreSSL(), delegateQueue: nil)
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("LCU API request error: \(error.localizedDescription)")
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let phase = json["phase"] as? String else {
                print("Invalid response or missing phase")
                return
            }

            DispatchQueue.main.async {
                print("Game phase: \(phase)")
                self?.handleGamePhase(phase, lockfile: lockfile)
            }
        }
        task.resume()
    }

    func handleGamePhase(_ phase: String, lockfile: Lockfile) {
        switch phase.lowercased() {
        case "lobby", "readycheck", "championselect", "planning", "preparation":
            // Game not started yet, lazy polling, hide overlay
            if pollInterval != 5.0 {
                restartPolling(with: 5.0)
            }
            gameStarted = false
            hideOverlay()

        case "inprogress":
            // Game loading started, increase polling rate to check live client data
            if pollInterval != 0.5 {
                restartPolling(with: 0.5)
            }
            pollLiveClientData(lockfile: lockfile)

        default:
            // Unknown or ended phases
            if pollInterval != 5.0 {
                restartPolling(with: 5.0)
            }
            gameStarted = false
            hideOverlay()
        }
    }

    func pollLiveClientData(lockfile: Lockfile) {
        let liveClientURL = URL(string: "https://127.0.0.1:2999/liveclientdata/allgamedata")!
        var request = URLRequest(url: liveClientURL)
        request.timeoutInterval = 5

        // The live client data API usually does not require authentication
        // but if needed, add headers here

        let session = URLSession(configuration: .default, delegate: IgnoreSSL(), delegateQueue: nil)
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            if let error = error {
                print("Live client data error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.gameStarted = false
                    self.hideOverlay()
                }
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let gameData = json["gameData"] as? [String: Any],
                  let gameTime = gameData["gameTime"] as? Double else {
                print("Invalid live client data response")
                DispatchQueue.main.async {
                    self.gameStarted = false
                    self.hideOverlay()
                }
                return
            }

            DispatchQueue.main.async {
                print("Live game time: \(gameTime)")
                if gameTime > 0 {
                    if !self.gameStarted {
                        print("Game clock started! Showing overlay.")
                        self.gameStarted = true
                        self.showOverlay()
                    }
                } else {
                    self.gameStarted = false
                    self.hideOverlay()
                }
            }
        }
        task.resume()
    }

    func restartPolling(with interval: TimeInterval) {
        pollingTimer?.invalidate()
        pollInterval = interval
        startPollingGameState()
    }

    func showOverlay() {
        guard window == nil else { return } // Already shown

        let contentView = OverlayView()
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


