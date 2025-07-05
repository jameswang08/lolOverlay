//
//  Lockfile.swift
//  lolOverlay
//
//  Created by jam on 7/4/25.
//

import Foundation

// struct to parse data in Lockfile to extract port for locally hosted LCU API
struct Lockfile {
    let port: String
    let token: String

    static func read() -> Lockfile? {
        let lockfilePath = ("/Applications/League of Legends.app/Contents/LoL/lockfile" as NSString).expandingTildeInPath
        do {
            let content = try String(contentsOfFile: lockfilePath, encoding: .utf8)
            let parts = content.components(separatedBy: ":")
            guard parts.count > 4 else { return nil }
            return Lockfile(port: parts[2], token: parts[3])
        } catch {
            print("Failed to read lockfile: \(error)")
            return nil
        }
    }
}
