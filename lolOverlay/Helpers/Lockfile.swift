//
//  Lockfile.swift
//  lolOverlay
//
//  Created by jam on 7/4/25.
//
//  Used to extract port for LCU API. Currently not used as LCU is not yet necessary.

import Foundation

struct Lockfile {
    let port: String
    let token: String

    static func read() -> Lockfile? {
        let lockfilePath = ("/Applications/League of Legends.app/Contents/LoL/lockfile" as NSString).expandingTildeInPath
        do {
            // Specify UTF-8 encoding explicitly to avoid deprecation warning
            let content = try String(contentsOfFile: lockfilePath, encoding: .utf8)
            let parts = content.components(separatedBy: ":")
            guard parts.count > 4 else { return nil }
            
            let port = parts[2]   // Correct index for port
            let token = parts[3]  // Correct index for token (password)
            
            return Lockfile(port: port, token: token)
        } catch {
            print("Failed to read lockfile: \(error)")
            return nil
        }
    }
}
