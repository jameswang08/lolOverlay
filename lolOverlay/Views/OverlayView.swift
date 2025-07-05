//
//  OverlayView.swift
//  lolOverlay
//
//  Created by jam on 7/4/25.
//


import SwiftUI
import Combine

// View that updates OverlayWindow according to game state
struct OverlayView: View {
    @StateObject private var viewModel: GameStateViewModel
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(viewModel: GameStateViewModel = GameStateViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private var timeString: String {
        let seconds = Int(viewModel.gameTime)
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }

    var body: some View {
        ZStack {
            Color.clear
            if viewModel.isGameInProgress {
                Text(timeString)
                    .foregroundColor(.white)
                    .font(.system(size: 40, weight: .bold))
                    .onReceive(timer) { _ in
                        // Timer ensures view updates, but gameTime is driven by ViewModel
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
}

#Preview {
    OverlayView()
}
