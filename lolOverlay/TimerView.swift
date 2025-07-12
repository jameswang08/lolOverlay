//
//  TimerView.swift
//  lolOverlay
//
//  Created by jam on 7/12/25.
//

import SwiftUI

struct TimerView: View {
    
    @State private var remainingSeconds = 60
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // format time to min:sec
    private var timeString: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String("\(minutes):\(seconds)")
    }
    
    
    var body: some View {
        ZStack {
            Color.clear
            Text(timeString)
                .foregroundColor(.green)
                .font(.system(size: 12))
                .opacity(0.7)
                .onReceive(timer) { _ in
                    if remainingSeconds > 0 {
                        remainingSeconds -= 1
                    }
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)    }
}

#Preview {
    TimerView()
}
