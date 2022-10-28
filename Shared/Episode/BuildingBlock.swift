//
//  BuildingBlock.swift
//  Podcast Producer
//
//  Created by Andy on 01.10.22.
//

import Foundation
import CryptoKit

enum BlockIdentifier: String, CaseIterable  {
    case introduction = "Introduction"
    case headline = "Headline"
    case story = "Story"
    case epilogue = "Epilogue"
    case unknown = "Unknown"
}


struct BuildingBlock: Identifiable, Hashable {
    var id: String {
        let textToBeHashed = "\(blockIdentifier.rawValue)-\(text)"
        let textAsData = Data(textToBeHashed.utf8)
        let hashed = SHA256.hash(data: textAsData)
        let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }
    var blockIdentifier: BlockIdentifier
    var subIndex: Int = 0
    var isPlaying: Bool = false
    var audioURL: URL?
    var text: String
    var highlightInSummary: Bool = false
    
    // audio is rendered if there exists a file at the expeded audioURL
    var audioIsRendered: Bool {
        
        var isRendered = false
        
        if let audioURL {
            if FileManager.default.fileExists(atPath: audioURL.path) {
                isRendered = true
            }
        }
        
        return isRendered
    }
}

