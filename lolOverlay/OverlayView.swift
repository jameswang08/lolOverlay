//
//  ContentView.swift
//  lolOverlay
//
//  Created by jam on 7/3/25.
//

import SwiftUI

struct OverlayView: View {
    @State private var remainingSeconds = 60
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var timeString: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String("HELLO WORLD")
//        return String(format: "%02d:%02d and then kaboom", minutes, seconds)
    }

    var body: some View {
        ZStack {
            Color.clear
            Text(timeString)
                .foregroundColor(.white)
                .font(.system(size: 40, weight: .bold))
                .onReceive(timer) { _ in
                    if remainingSeconds > 0 {
                        remainingSeconds -= 1
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
