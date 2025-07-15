//
//  CaptureScreen.swift
//  lolOverlay
//
//  Created by jam on 7/13/25.
//

import Foundation
import ScreenCaptureKit

@MainActor
class ScreenRecorder: NSObject, ObservableObject {
    
    private var stream: SCStream?
    private var lolWindow: SCWindow?
    
    // Configure video stream to capture a ss every 5 seconds
    private var streamConfiguration: SCStreamConfiguration {
        var streamConfig = SCStreamConfiguration()
        streamConfig.minimumFrameInterval = CMTime(value: 5, timescale: 0)
        return streamConfig
    }
    
    private var contentFilter: SCContentFilter {
        var filter = SCContentFilter(desktopIndependentWindow: lolWindow!)
        return filter
    }
    
    
    func start() async throws {
        let allWindows = try await SCShareableContent.excludingDesktopWindows(true,
                                                                               onScreenWindowsOnly: false)
        // Find the League of Legends client window
        guard let lolWindow = allWindows.windows.first(
            where: { window in
                guard let app = window.owningApplication,
                      let title = window.title else {
                    return false
                }
                return app.applicationName == "League of Legends" &&
                       title == "League of Legends (TM) Client"
            }) else {
            print("Matching window not found.")
            return
        }
        
        let config = streamConfiguration
        let filter = contentFilter

    }
    
    func stop() async {
        do {
            try await stream?.stopCapture()
            print("Recording stopped.")
        } catch {
            print("Failed to stop capture: \(error)")
        }
    }
}

