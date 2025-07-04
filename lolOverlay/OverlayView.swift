//
//  ContentView.swift
//  lolOverlay
//
//  Created by jam on 7/3/25.
//

import SwiftUI

struct OverlayView: View {
    var body: some View {
        ZStack {
            Color.clear  // Keep full frame
            Text("Hello World")
                .foregroundColor(.white)
                .font(.system(size: 40, weight: .bold))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
}

#Preview {
    OverlayView()
}
