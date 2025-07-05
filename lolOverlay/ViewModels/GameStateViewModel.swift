//
//  GameStateViewModel.swift
//  lolOverlay
//
//  Created by jam on 7/4/25.
//


import Foundation
import Combine

class GameStateViewModel: ObservableObject {
    @Published var isGameInProgress: Bool = false
    @Published var gameTime: Double = 0.0
    @Published var isWaitingForGame: Bool = false
    private var cancellables = Set<AnyCancellable>()
    private let networkService: NetworkService
    private var pollingTimer: Timer?
    private var pollInterval: TimeInterval = 5.0

    init(networkService: NetworkService = NetworkService()) {
        self.networkService = networkService
        startPollingGameState()
    }

    private func startPollingGameState() {
        pollingTimer?.invalidate() // Prevent duplicate timers
        pollingTimer = Timer.scheduledTimer(withTimeInterval: pollInterval, repeats: true) { [weak self] _ in
            self?.checkGameState()
        }
        print("GameStateViewModel: Started polling with interval \(pollInterval) seconds")
    }

    private func checkGameState() {
        print("GameStateViewModel: Checking game state")
        guard let lockfile = Lockfile.read() else {
            print("GameStateViewModel: Lockfile unavailable, cannot check game state")
            DispatchQueue.main.async { [weak self] in
                self?.isGameInProgress = false
                self?.gameTime = 0.0
                self?.isWaitingForGame = true
            }
            pollLiveClientData(lockfile: nil)
            return
        }

        Publishers.CombineLatest(
            networkService.checkGamePhase(lockfile: lockfile),
            networkService.fetchLiveClientData(lockfile: lockfile)
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] phase, gameTime in
            self?.handleGameState(phase: phase, gameTime: gameTime)
        }
        .store(in: &cancellables)
    }

    private func handleGameState(phase: String, gameTime: Double?) {
        print("GameStateViewModel: Handling game state - Phase: \(phase), GameTime: \(gameTime ?? 0)")
        switch phase.lowercased() {
        case "inprogress":
            updatePollingInterval(to: 0.5)
            if let gameTime = gameTime, gameTime > 0 {
                isGameInProgress = true
                self.gameTime = gameTime
                isWaitingForGame = false
                print("GameStateViewModel: Game in progress, time: \(gameTime)")
            } else {
                isGameInProgress = false
                self.gameTime = 0.0
                isWaitingForGame = true
                print("GameStateViewModel: InProgress phase but no valid game time. Polling continues.")
            }
        default:
            updatePollingInterval(to: 5.0)
            isGameInProgress = false
            self.gameTime = 0.0
            isWaitingForGame = true
            print("GameStateViewModel: Game not started or ended, phase: \(phase). Polling continues.")
        }
    }

    private func pollLiveClientData(lockfile: Lockfile?) {
        guard let lockfile = lockfile else {
            print("GameStateViewModel: No lockfile, skipping live client data poll")
            DispatchQueue.main.async { [weak self] in
                self?.isGameInProgress = false
                self?.gameTime = 0.0
                self?.isWaitingForGame = true
            }
            return
        }
        networkService.fetchLiveClientData(lockfile: lockfile)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] gameTime in
                guard let self = self else { return }
                if let gameTime = gameTime, gameTime > 0 {
                    self.isGameInProgress = true
                    self.gameTime = gameTime
                    self.isWaitingForGame = false
                    print("GameStateViewModel: Game in progress, time: \(gameTime)")
                } else {
                    self.isGameInProgress = false
                    self.gameTime = 0.0
                    self.isWaitingForGame = true
                    print("GameStateViewModel: No valid game time received. Polling continues.")
                }
            }
            .store(in: &cancellables)
    }

    private func updatePollingInterval(to interval: TimeInterval) {
        guard pollInterval != interval else { return }
        pollingTimer?.invalidate()
        pollInterval = interval
        startPollingGameState()
        print("GameStateViewModel: Polling interval updated to \(interval) seconds")
    }

    deinit {
        pollingTimer?.invalidate()
    }
}
