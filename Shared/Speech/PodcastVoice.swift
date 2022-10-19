//
//  PodcastVoice.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 19.10.22.
//

import Foundation
import AVFoundation

enum SpeechProvider {
    case SELMA, Apple
}

/// A wrapper to address verious Speecg Providers
struct PodcastVoice {
    
    var speechProvider: SpeechProvider
    var language: String
    var identifier: String
    var name: String

    static func voicesForSpeechSpeechSystem(_ speechProvider: SpeechProvider) -> [PodcastVoice] {
        
        switch speechProvider {
        case .Apple: return Self.appleVoices()
        case .SELMA: return Self.selmaVoices()
        }
        
    }
        
    static func selmaVoices() -> [PodcastVoice] {
        
        // prepare result
        var returnedVoices = [PodcastVoice]()
        
        let nativeVoices = SelmaVoice.allVoices
        
        for nativeVoice in nativeVoices {
            let voice = PodcastVoice(speechProvider: .SELMA, language: nativeVoice.language, identifier: nativeVoice.id.rawValue, name: nativeVoice.shortName)
            returnedVoices.append(voice)
        }
        
        return returnedVoices
    }
    
    static func appleVoices() -> [PodcastVoice] {
        
        // prepare result
        var returnedVoices = [PodcastVoice]()
        
        let nativeVoices = AVSpeechSynthesisVoice.speechVoices()
        
        for nativeVoice in nativeVoices {
            let voice = PodcastVoice(speechProvider: .Apple, language: nativeVoice.language, identifier: nativeVoice.identifier, name: nativeVoice.name)
            returnedVoices.append(voice)
        }
        
        return returnedVoices
    }
    
    func nativeAppleVoice() -> AVSpeechSynthesisVoice? {
        guard self.speechProvider == .Apple else {return nil}
        return AVSpeechSynthesisVoice(identifier: self.identifier)
    }
    
    func nativeSelmaVoice() -> SelmaVoice? {
        guard self.speechProvider == .SELMA else {return nil}
        guard let selmaVoiceId = SelmaVoice.SelmaVoiceId(rawValue: identifier) else {return nil}
        return SelmaVoice(selmaVoiceId)
    }
}
