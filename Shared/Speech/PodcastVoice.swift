//
//  PodcastVoice.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 19.10.22.
//

import Foundation
import AVFoundation

enum SpeechProvider {
    case SELMA, Apple, EuroVOX
}

/// A wrapper to address verious Speecg Providers
struct PodcastVoice: Hashable {
    
    var speechProvider: SpeechProvider
    var language: String
    var identifier: String
    var name: String

    /// A default voice used for initialisation
    static var standard: PodcastVoice {
        let alexVoice = AVSpeechSynthesisVoice(identifier: AVSpeechSynthesisVoiceIdentifierAlex)!
        let podcastVoice = PodcastVoice(speechProvider: .Apple, language: alexVoice.language, identifier: alexVoice.identifier, name: alexVoice.name)
        return podcastVoice
    }
    
    /// Proposes a voice based on the given locale
    static func proposedVoiceForLocale(_ languageLocale: String) -> PodcastVoice? {
        
        var wantedVoice: AVSpeechSynthesisVoice?
        
        for voice in AVSpeechSynthesisVoice.speechVoices() {
            if voice.language == languageLocale {
                wantedVoice = voice
            }
        }
        
        // convert to PodcastVoice
        var podcastVoice: PodcastVoice?
        
        if let wantedVoice {
            podcastVoice = PodcastVoice(speechProvider: .Apple, language: wantedVoice.language, identifier: wantedVoice.identifier, name: wantedVoice.name)
        }
        
        return podcastVoice
    }
    
    
    /// Returns an Apple voice with the given name
    static func voiceForAppleName(_ name: String) -> PodcastVoice? {
        
        var wantedVoice: AVSpeechSynthesisVoice?
        
        for voice in AVSpeechSynthesisVoice.speechVoices() {
            if voice.name.lowercased() == name.lowercased() {
                wantedVoice = voice
            }
        }
        
        // convert to PodcastVoice
        var podcastVoice: PodcastVoice?
        
        if let wantedVoice {
            podcastVoice = PodcastVoice(speechProvider: .Apple, language: wantedVoice.language, identifier: wantedVoice.identifier, name: wantedVoice.name)
        }
        
        return podcastVoice
    }
    
    // Returns a SELMA voice for the given name
    static func voiceForSelmaNarrator(_ fullName: String) -> PodcastVoice? {
        
        var wantedVoice: SelmaVoice?
        
        for voice in SelmaVoice.allVoices {
            if voice.fullName.lowercased() == fullName.lowercased() {
                wantedVoice = voice
            }
        }
        
        // convert to PodcastVoice
        var podcastVoice: PodcastVoice?
        
        if let wantedVoice {
            podcastVoice = PodcastVoice(speechProvider: .SELMA, language: wantedVoice.language, identifier: wantedVoice.id.rawValue, name: wantedVoice.fullName)
        }
        
        return podcastVoice
    }
    
    /// Retuns all voice for given provider
    static func voicesForSpeechProvider(_ speechProvider: SpeechProvider) -> [PodcastVoice] {
        
        switch speechProvider {
        case .Apple: return Self.appleVoices()
        case .SELMA: return Self.selmaVoices()
        case .EuroVOX: return Self.euroVoxVoices()
        }
        
    }
    
    // TODO: Add voices
    static func euroVoxVoices() -> [PodcastVoice] {
        return []
    }
        
    /// All available SELMA voices
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
    
    /// All available Apple voices
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
    
    /// Returns native Apple voice  for  PodcastVoice instance
    func nativeAppleVoice() -> AVSpeechSynthesisVoice? {
        guard self.speechProvider == .Apple else {return nil}
        return AVSpeechSynthesisVoice(identifier: self.identifier)
    }
    
    /// Returns native SELMA voice  for PodcastVoice instance
    func nativeSelmaVoice() -> SelmaVoice? {
        guard self.speechProvider == .SELMA else {return nil}
        guard let selmaVoiceId = SelmaVoice.SelmaVoiceId(rawValue: identifier) else {return nil}
        return SelmaVoice(selmaVoiceId)
    }
}
