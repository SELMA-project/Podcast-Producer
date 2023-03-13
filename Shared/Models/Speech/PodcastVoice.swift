//
//  PodcastVoice.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 19.10.22.
//

import Foundation
import AVFoundation


/// A wrapper to address verious Speech Providers
struct PodcastVoice: Hashable, Codable {
        
    var speechProvider: SpeechProvider {
        
        // synchonise provider and identifier
        didSet {
            // if the provider changed...
            if speechProvider != oldValue {
                
                // convert languageCode to native Language
                if let language = LanguageManager.shared.language(fromIsoCode: languageCode) {
                    
                    // get the provider's available voices
                    let availableVoices = VoiceManager.shared.availableVoices(forLanguage: language, forProvider: speechProvider)
                    
                    // change the voice identifier to match the first voice
                    if let firstVoice = availableVoices.first {
                        self.identifier = firstVoice.identifier
                    }
                }
            }
        }
    }
    var languageCode: String
    var identifier: String
            
    /// A default voice used for initialisation
    static var standard: PodcastVoice {
        let alexVoice = AVSpeechSynthesisVoice(identifier: AVSpeechSynthesisVoiceIdentifierAlex)!
        let podcastVoice = PodcastVoice(speechProvider: .Apple, languageCode: alexVoice.language, identifier: alexVoice.identifier)
        return podcastVoice
    }
    
    var name: String {
        
        var voiceName: String
        
        switch(speechProvider) {
        case .Apple:
            voiceName = nativeAppleVoice()?.name ?? "<unknown>"
        case .SELMA:
            voiceName = nativeSelmaVoice()?.shortName ?? "<unknown>"
        case .ElevenLabs:
            voiceName = "Andy"
        case .EuroVOX: 
            voiceName = "not implemented"
        }
        
        return voiceName
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
