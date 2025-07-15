//
//  CaptureScreen.swift
//  lolOverlay
//
//  Created by jam on 7/13/25.
//

import Foundation
import ScreenCaptureKit

@MainActor
class ScreenRecorder: NSObject, SCStreamDelegate {
        
    private var stream: SCStream?
    private let streamQueue = DispatchQueue(label: "com.lolOverlay.streamQueue")
    
    // Configure video stream to capture a ss every 5 seconds
    private var streamConfiguration: SCStreamConfiguration {
        var streamConfig = SCStreamConfiguration()
        streamConfig.minimumFrameInterval = CMTime(value: 5, timescale: 0)
        return streamConfig
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
        let contentFilter = SCContentFilter(desktopIndependentWindow: lolWindow)
        
        stream = SCStream(filter: contentFilter, configuration: config, delegate: self)
        try stream?.addStreamOutput(self, type: .screen, sampleHandlerQueue: streamQueue)
        try await stream?.startCapture()
        
        print("Stream started.")

    }
    
    func stop() async throws{
        try await stream?.stopCapture()
        print("Recording stopped.")
    }
}

extension ScreenRecorder: SCStreamOutput {
    nonisolated func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        if type == .screen {
            MinimapProcessor.processFrame(sampleBuffer)
        }
    }
}
