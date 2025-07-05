//
//  GameServer.swift
//  lolOverlay
//
//  Created by jam on 7/4/25.
//


import Foundation

class GameServer {
    private let url = URL(string: "https://127.0.0.1:2999/lol-gameflow/v1/session")!

    func isGameInProgress(completion: @escaping (Bool) -> Void) {
        var request = URLRequest(url: url)
        request.timeoutInterval = 5

        // Ignore SSL (self-signed cert)
        let session = URLSession(configuration: .default, delegate: IgnoreSSL(), delegateQueue: nil)

        let task = session.dataTask(with: request) { data, response, error in
            guard
                error == nil,
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let phase = json["phase"] as? String
            else {
                completion(false)
                return
            }

            completion(phase == "InProgress")
        }

        task.resume()
    }
}

// MARK: - Ignore SSL Certificate Validation
class IgnoreSSL: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}
