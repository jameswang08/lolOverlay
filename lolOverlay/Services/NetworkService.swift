//
//  NetworkService.swift
//  lolOverlay
//
//  Created by jam on 7/4/25.
//

import Foundation
import Combine

// Class to make requests to LCU API
class NetworkService {
    private let session: URLSession

    init() {
        self.session = URLSession(configuration: .default, delegate: IgnoreSSL(), delegateQueue: nil)
    }

    // Function to get game state
    func checkGamePhase(lockfile: Lockfile) -> AnyPublisher<String, Never> {
        // Form request to LCU
        let url = URL(string: "https://127.0.0.1:\(lockfile.port)/lol-gameflow/v1/session")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        
        // Authenticate req
        let loginString = "riot:\(lockfile.token)"
        guard let loginData = loginString.data(using: .utf8) else {
            print("NetworkService: Failed to create login data for authentication")
            return Just("none").eraseToAnyPublisher()
        }
        let base64LoginString = loginData.base64EncodedString()
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

        // Return request results
        return session.dataTaskPublisher(for: request)
            .map { data, _ in data }
            .replaceError(with: Data())
            .flatMap { data in
                Future<String, Never> { promise in
                    do {
                        if data.isEmpty {
                            print("NetworkService: Empty data received for game phase (likely connection error)")
                            promise(.success("none"))
                            return
                        }
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let phase = json["phase"] as? String {
                            print("NetworkService: Game phase received: \(phase)")
                            promise(.success(phase))
                        } else {
                            print("NetworkService: Invalid JSON or missing phase")
                            promise(.success("none"))
                        }
                    } catch {
                        print("NetworkService: JSON parsing error in checkGamePhase: \(error)")
                        promise(.success("none"))
                    }
                }
            }
            .eraseToAnyPublisher()
    }

    // Function to get in game time
    func fetchLiveClientData(lockfile: Lockfile) -> AnyPublisher<Double?, Never> {
        // Form request to LCU
        let url = URL(string: "https://127.0.0.1:2999/liveclientdata/allgamedata")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 5

        // Return request
        return Future<Double?, Never> { [weak self] promise in
            guard let self = self else {
                promise(.success(nil))
                return
            }
            let task = self.session.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("NetworkService: Live client data error at port \(lockfile.port): \(error.localizedDescription)")
                    promise(.success(nil))
                    return
                }
                guard let data = data else {
                    print("NetworkService: No data received for live client data at port \(lockfile.port)")
                    promise(.success(nil))
                    return
                }
                // Log raw JSON for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("NetworkService: Raw JSON response at port \(lockfile.port): \(jsonString)")
                } else {
                    print("NetworkService: Failed to convert data to string at port \(lockfile.port)")
                }
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let gameData = json["gameData"] as? [String: Any],
                       let gameTime = gameData["gameTime"] as? Double {
                        print("NetworkService: Game time received: \(gameTime) at port \(lockfile.port)")
                        promise(.success(gameTime))
                    } else {
                        print("NetworkService: Invalid JSON or missing gameData/gameTime at port \(lockfile.port)")
                        promise(.success(nil))
                    }
                } catch {
                    print("NetworkService: JSON parsing error in fetchLiveClientData at port \(lockfile.port): \(error)")
                    promise(.success(nil))
                }
            }
            task.resume()
        }
        .eraseToAnyPublisher()
    }
}
