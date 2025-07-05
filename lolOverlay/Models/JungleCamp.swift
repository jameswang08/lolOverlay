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
    let side: String?
    var lastCleared: UInt16?
    let region: CGRect
    
    var respawnTime: Int {
        fatalError("Subclasses must override respawnTime")
    }
    
    init(name: String, side: String?, region: CGRect) {
        self.name = name
        self.side = side
        self.region = region
        self.lastCleared = nil
    }
}

class BlueSentinel: JungleCamp {
    override var respawnTime: Int { 300 }
    init(side: String, region: CGRect) { super.init(name: "Blue", side: side, region: region) }
}

class RedBrambleback: JungleCamp {
    override var respawnTime: Int { 300 }
    init(side: String, region: CGRect) { super.init(name: "Red", side: side, region: region) }
}

class Raptors: JungleCamp {
    override var respawnTime: Int { 135 }
    init(side: String, region: CGRect) { super.init(name: "Raptors", side: side, region: region) }
}

class Wolves: JungleCamp {
    override var respawnTime: Int { 135 }
    init(side: String, region: CGRect) { super.init(name: "Wolves", side: side, region: region) }
}

class Krugs: JungleCamp {
    override var respawnTime: Int { 135 }
    init(side: String, region: CGRect) { super.init(name: "Krugs", side: side, region: region) }
}

class Gromp: JungleCamp {
    override var respawnTime: Int { 135 }
    init(side: String, region: CGRect) { super.init(name: "Gromp", side: side, region: region) }
}
