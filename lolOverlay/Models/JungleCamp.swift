//
//  JungleCamp.swift
//  lolOverlay
//
//  Created by jam on 7/4/25.
//
import Foundation
import CoreGraphics

// class to store state of camps
class JungleCamp {
    let name: String
    let side: String
    let respawnTime: UInt8
    var lastCleared: UInt16
    let region: CGRect
    
    
    init(name: String, side: String, respawnTime: UInt8, lastCleared: UInt16, region: CGRect) {
        self.name = name
        self.side = side
        self.respawnTime = respawnTime
        self.lastCleared = lastCleared
        self.region = region
    }
}

let screenWidth: CGFloat = 1440
let screenHeight: CGFloat = 900

let testJungleCampsAbsolute = [
    // Blue side (left side)
    TestCampPosition(id: "krugs_left", marker: "Krugs", position: CGPoint(x: 0.89 * screenWidth, y: 0.92 * screenHeight)),
    TestCampPosition(id: "red_left", marker: "Red", position: CGPoint(x: 0.88 * screenWidth, y: 0.89 * screenHeight)),
    TestCampPosition(id: "raptors_left", marker: "Raptors", position: CGPoint(x: 0.87 * screenWidth, y: 0.86 * screenHeight)),
    
    TestCampPosition(id: "wolves_left", marker: "Wolves", position: CGPoint(x: 0.82 * screenWidth, y: 0.83 * screenHeight)),
    TestCampPosition(id: "blue_left", marker: "Blue", position: CGPoint(x: 0.83 * screenWidth, y: 0.80 * screenHeight)),
    TestCampPosition(id: "gromp_left", marker: "Gromp", position: CGPoint(x: 0.80 * screenWidth, y: 0.78 * screenHeight)),

    // Red side (right side)
    TestCampPosition(id: "krugs_right", marker: "Krugs", position: CGPoint(x: 0.868 * screenWidth, y: 0.697 * screenHeight)),
    TestCampPosition(id: "red_right", marker: "Red", position: CGPoint(x: 0.875 * screenWidth, y: 0.725 * screenHeight)),
    TestCampPosition(id: "raptors_right", marker: "Raptors", position: CGPoint(x: 0.89 * screenWidth, y: 0.76 * screenHeight)),
    
    TestCampPosition(id: "wolves_right", marker: "Wolves", position: CGPoint(x: 0.935 * screenWidth, y: 0.78 * screenHeight)),
    TestCampPosition(id: "blue_right", marker: "Blue", position: CGPoint(x: 0.93 * screenWidth, y: 0.82 * screenHeight)),
    TestCampPosition(id: "gromp_right", marker: "Gromp", position: CGPoint(x: 0.948 * screenWidth, y: 0.83 * screenHeight)),
]

