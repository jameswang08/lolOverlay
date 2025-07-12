//
//  TimersOverlayView.swift
//  lolOverlay
//
//  Created by jam on 7/12/25.
//


import SwiftUI

struct JungleTimerView: View {

    var body: some View {
        GeometryReader { geo in
            let screenWidth = geo.size.width
            let screenHeight = geo.size.height
            
            let points = [
                CGPoint(x: 0.89 * screenWidth, y: 0.92 * screenHeight),   // Krugs_Left
                CGPoint(x: 0.885 * screenWidth, y: 0.89 * screenHeight),   // Red_Left
                CGPoint(x: 0.875 * screenWidth, y: 0.855 * screenHeight),   // Raptors_Left
                CGPoint(x: 0.825 * screenWidth, y: 0.83 * screenHeight),   // Wolves_Left
                CGPoint(x: 0.825 * screenWidth, y: 0.795 * screenHeight),   // Blue_Left
                CGPoint(x: 0.80 * screenWidth, y: 0.78 * screenHeight),   // Gromp_Left
                CGPoint(x: 0.868 * screenWidth, y: 0.697 * screenHeight), // Krugs_Right
                CGPoint(x: 0.875 * screenWidth, y: 0.725 * screenHeight), // Red_Right
                CGPoint(x: 0.885 * screenWidth, y: 0.755 * screenHeight),   // Raptors_Right
                CGPoint(x: 0.935 * screenWidth, y: 0.785 * screenHeight),  // Wolves_Right
                CGPoint(x: 0.935 * screenWidth, y: 0.82 * screenHeight),   // Blue_Right
                CGPoint(x: 0.96 * screenWidth, y: 0.83 * screenHeight)   // Gromp_Right
            ]

            
            ZStack {
                ForEach(0..<points.count, id: \.self) { index in
                    TimerView()
                        .frame(width: 100, height: 60)
                        .position(points[index])
                }
            }
        }
        .ignoresSafeArea()
    }
}
