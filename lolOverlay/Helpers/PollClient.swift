//
//  PollClient.swift
//  lolOverlay
//
//  Created by jam on 7/12/25.
//
//  Helper function to continually poll LoL client to determine when a game has started.

import Foundation

class PollClient: NSObject {
    private var pollingTimer: Timer?
    private var pollInterval: TimeInterval
    private let session: URLSession

    var gameStarted: Bool = false
    var onGameStarted: (() -> Void)?
    var onGameStopped: (() -> Void)?

    init(pollInterval: TimeInterval = 5.0) {
        self.pollInterval = pollInterval
        // Ignore SSL validation because LoL's live client API uses a self-signed certificate
        self.session = URLSession(configuration: .default, delegate: IgnoreSSL(), delegateQueue: nil)
    }

    func startPolling() {
        pollingTimer?.invalidate()
        pollingTimer = Timer.scheduledTimer(withTimeInterval: pollInterval, repeats: true) { [weak self] _ in
            self?.pollLiveClientData()
        }
        pollingTimer?.fire() // Immediately start polling
    }

    func stopPolling() {
        pollingTimer?.invalidate()
        pollingTimer = nil
        gameStarted = false
    }

    private func pollLiveClientData() {
        let liveClientURL = URL(string: "https://127.0.0.1:2999/liveclientdata/allgamedata")!
        var request = URLRequest(url: liveClientURL)
        request.timeoutInterval = 5

        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            if error != nil {
                DispatchQueue.main.async {
                    if self.gameStarted {
                        self.gameStarted = false
                        self.onGameStopped?()
                    }
                }
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let gameData = json["gameData"] as? [String: Any],
                  let gameTime = gameData["gameTime"] as? Double else {
                DispatchQueue.main.async {
                    if self.gameStarted {
                        self.gameStarted = false
                        self.onGameStopped?()
                    }
                }
                return
            }

            DispatchQueue.main.async {
                if gameTime > 0 {
                    if !self.gameStarted {
                        self.gameStarted = true
                        self.onGameStarted?()
                    }
                } else {
                    if self.gameStarted {
                        self.gameStarted = false
                        self.onGameStopped?()
                    }
                }
            }
        }

        task.resume()
    }
}

class IgnoreSSL: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}
