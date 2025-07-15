//
//  MinimapProcessor.swift
//  lolOverlay
//
//  Created by jam on 7/15/25.
//

import Foundation
import Vision
import ScreenCaptureKit

class MinimapProcessor {
    
    static func processFrame(_ sampleBuffer: CMSampleBuffer){
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Failed to get pixel buffer from sample buffer")
            return
        }
        
        let largeImage = CIImage(cvPixelBuffer: pixelBuffer)
                
        // Update w/ template matching logic later.
        let matchResult = templateMatch(largeImage: largeImage, templateImage: largeImage)
        print(matchResult)
    }
    
    // used later to convert template images stored as assets
    private static func convertImage(named name: String) -> CIImage? {
        guard let templateNSImage = NSImage(named: NSImage.Name(name)),
              let templateCGImage = templateNSImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        return CIImage(cgImage: templateCGImage)
    }
    
    private static func templateMatch(largeImage: CIImage, templateImage: CIImage) -> String {
        let largeWidth = Int(largeImage.extent.width)
        let largeHeight = Int(largeImage.extent.height)
        let templateWidth = Int(templateImage.extent.width)
        let templateHeight = Int(templateImage.extent.height)

        guard largeWidth >= templateWidth && largeHeight >= templateHeight else {
            return "Template image is larger than the large image"
        }

        func featurePrintForImage(ciImage: CIImage) -> VNFeaturePrintObservation? {
            let requestHandler = VNImageRequestHandler(ciImage: ciImage, orientation: .up, options: [:])
            let request = VNGenerateImageFeaturePrintRequest()
            do {
                try requestHandler.perform([request])
                return request.results?.first as? VNFeaturePrintObservation
            } catch {
                print("Error generating feature print: \(error)")
                return nil
            }
        }

        guard let templateFeaturePrint = featurePrintForImage(ciImage: templateImage) else {
            return "Cannot generate feature print for template"
        }

        var minDistance: Float = Float.greatestFiniteMagnitude
        var bestPosition: (x: Int, y: Int) = (0, 0)

        // Using large sliding window rn. Adjust later for more accurate template matching.
        let step = 25

        for y in stride(from: 0, to: largeHeight - templateHeight + 1, by: step) {
            for x in stride(from: 0, to: largeWidth - templateWidth + 1, by: step) {
                let cropRect = CGRect(x: CGFloat(x), y: CGFloat(y), width: CGFloat(templateWidth), height: CGFloat(templateHeight))
                let croppedCIImage = largeImage.cropped(to: cropRect)
                
                if let cropFeaturePrint = featurePrintForImage(ciImage: croppedCIImage) {
                    var distance: Float = 0
                    do {
                        try cropFeaturePrint.computeDistance(&distance, to: templateFeaturePrint)
                        if distance < minDistance {
                            minDistance = distance
                            bestPosition = (x, y)
                        }
                    } catch {
                        print("Error computing distance at (\(x), \(y)): \(error)")
                    }
                }
            }
        }

        let threshold: Float = 0.5
        if minDistance < threshold {
            return "Match found at position (\(bestPosition.x), \(bestPosition.y)) with distance \(minDistance)"
        } else {
            return "No match found. Smallest distance: \(minDistance)"
        }
    }
}
