//
//  lolOverlayApp.swift
//  lolOverlay
//
//  Created by jam on 7/3/25.
//

import SwiftUI

@main
struct LolOverlayApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
