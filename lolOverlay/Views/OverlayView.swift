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
    
    let testJungleCamps = [
        // blue side
        TestCampPosition(id: "blue_krugs", marker: "Krugs", position: CGPoint(x: 0.89, y: 0.92)),
        TestCampPosition(id: "blue_raptors", marker: "Rapt", position: CGPoint(x: 0.87, y: 0.86)),
        TestCampPosition(id: "blue_wolves", marker: "Wolve", position: CGPoint(x: 0.82, y: 0.83)),
        TestCampPosition(id: "blue_gromp", marker: "Red", position: CGPoint(x: 0.88, y: 0.89)),
        TestCampPosition(id: "blue_blue", marker: "Blue", position: CGPoint(x: 0.83, y: 0.8)),
        TestCampPosition(id: "blue_kru", marker: "Gromp", position: CGPoint(x: 0.80, y: 0.78)),
        
        // red side
        TestCampPosition(id: "red_krugs", marker: "Krugs", position: CGPoint(x: 0.868, y: 0.697)),
        TestCampPosition(id: "red_g", marker: "Red", position: CGPoint(x: 0.875, y: 0.725)),
        TestCampPosition(id: "redr", marker: "Rapt", position: CGPoint(x: 0.89, y: 0.76)),
        
        TestCampPosition(id: "redw", marker: "Wolve", position: CGPoint(x: 0.935, y: 0.78)),
        TestCampPosition(id: "red_blue", marker: "Blue", position: CGPoint(x: 0.93, y: 0.82)),
        TestCampPosition(id: "red_kruzs", marker: "Gromp", position: CGPoint(x: 0.948, y: 0.83)),

    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Transparent background
                Color.clear
                
                // Display test markers at hardcoded positions
                ForEach(testJungleCamps, id: \.id) { camp in
                    TestCampMarkerView(camp: camp)
                        .position(
                            x: camp.position.x * geometry.size.width,
                            y: camp.position.y * geometry.size.height
                        )
                }
            }
        }
        .onReceive(timer) { _ in
            // Update view every second
        }
    }
}

#Preview {
    OverlayView()
}


struct TestCampMarkerView: View {
    let camp: TestCampPosition
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(Color.black.opacity(0.7))
                .frame(width: 20, height: 20)
            
            // Border circle
            Circle()
                .stroke(getCampColor(), lineWidth: 2)
                .frame(width: 20, height: 20)
            
            // Marker text
            Text(camp.marker)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
        }
    }
    
    private func getCampColor() -> Color {
        // Color code the camps
        switch camp.marker {
        case "B": return .blue      // Blue/Red buff
        case "R": return .red       // Raptors
        case "G": return .green     // Gromp
        case "W": return .orange    // Wolves
        case "K": return .purple    // Krugs
        case "S": return .cyan      // Scuttle
        default: return .white
        }
    }
}

struct TestCampPosition {
    let id: String
    let marker: String
    let position: CGPoint
}
