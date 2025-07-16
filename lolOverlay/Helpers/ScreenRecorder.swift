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
        let streamConfig = SCStreamConfiguration()
        streamConfig.minimumFrameInterval = CMTime(value: 5, timescale: 0)
        return streamConfig
    }
    
    func start() async throws {
        
        guard let lolWindow = (try await SCShareableContent
            .excludingDesktopWindows(true, onScreenWindowsOnly: false))
            .windows
            .first(where: { window in
                func normalize(_ str: String?) -> String {
                    return str?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
                }

                let appName = normalize(window.owningApplication?.applicationName)
                let title = normalize(window.title)

                return appName == "league of legends" &&
                       title == "league of legends (tm) client"
            }) else {
                print("League of Legends window not found")
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
