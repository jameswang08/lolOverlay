//
//  IgnoreSSL.swift
//  lolOverlay
//
//  Created by jam on 7/4/25.
//


import Foundation

// Skip signing process since LCU API is locally hosted. Need to fix this in future if releasing for public use.
class IgnoreSSL: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}
