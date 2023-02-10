//
//  VoiceManager.swift
//  Podcast Creator
//
//  Created by Andy Giefer on 01.11.22.
//

import Foundation
import AVFoundation


enum SpeechProvider: String, CaseIterable, Codable {
    case SELMA, Apple, EuroVOX
    
    var displayName: String {
        return rawValue
    }
    
}

class VoiceManager {
    
    static let shared = VoiceManager()
    
    var appleVoices: [PodcastVoice] = []
    var selmaVoices: [PodcastVoice] = []
    var eurovoxVoices: [PodcastVoice] = []
    
    init() {
        
        // cache filtering of suitable  voices
        findSuitableVoices()
    }
    
    func findSuitableVoices() {
        print("Finding suitable voices")
        self.appleVoices =  findSuitableAppleVoices()
        self.selmaVoices =  findSuitableSelmaVoices()
        self.eurovoxVoices =  findSuitableEurovoxVoices()
    }
    
    /// Proposes a voice based on the given locale
    func proposedVoice(forLanguageCode languageCode: String) -> PodcastVoice {
        
        // the proposed voice of brasilian portuguese is Leila
        if languageCode == "pt-BR" {
            let leilasVoice = PodcastVoice(speechProvider: .SELMA, languageCode: "pt-BR", identifier: "leila")
            return leilasVoice
        }
        
        // all other locales: use Apple Voices
        
        // the proposed PodcastVoice is stored here
        var proposedPodcastVoice: PodcastVoice?
        
        // get all voices that we can synthesize
        let usableApplePodcastVoices = voicesForSpeechProvider(.Apple)
        
        // go through each one of them
        for applePodcastVoice in usableApplePodcastVoices {
            
            // get the equivalent native apple voice
            if let nativeAppleVoice = applePodcastVoice.nativeAppleVoice() {
                
                // do we have the right language?
                if nativeAppleVoice.language == languageCode {
                                        
                    // only use voice that have associated audioFile setings
                    proposedPodcastVoice = applePodcastVoice
                    
                }
            }
        }
        

        // we should always have a podcast voice here
        if proposedPodcastVoice == nil {
            fatalError("We should have an Apple podcast voice here.")
        }
        
        return proposedPodcastVoice!
    }
    
    
    /// Returns all providers for given language
    func availableProviders(forLanguage language: LanguageManager.Language) -> [SpeechProvider] {
        
        // init result
        var providersForLanguage = [SpeechProvider]()
        
        for provider in SpeechProvider.allCases {
            let availableVoices = availableVoices(forLanguage: language, forProvider: provider)
            if availableVoices.count > 0 {
                providersForLanguage.append(provider)
            }
        }
        
        return providersForLanguage
    }
    
    
    /// Returns all voices for given language and provider
    func availableVoices(forLanguage language: LanguageManager.Language, forProvider provider: SpeechProvider) -> [PodcastVoice] {
        
        // all voice sdharing the same speech provider
        let voiceOfSameProvider = voicesForSpeechProvider(provider)
        
        // filter to find those voices sharing the same language
        let relatedVoices = voiceOfSameProvider.filter {$0.languageCode == language.isoCode}
        
        return relatedVoices
    }
    
    
    /// Retuns all voice for given provider
    func voicesForSpeechProvider(_ speechProvider: SpeechProvider) -> [PodcastVoice] {
        
        switch speechProvider {
        case .Apple: return appleVoices
        case .SELMA: return selmaVoices
        case .EuroVOX: return eurovoxVoices
        }
        
    }
    
    // TODO: Add voices
    private func findSuitableEurovoxVoices()  -> [PodcastVoice] {
        return []
    }
    
    /// All available SELMA voices
    private func findSuitableSelmaVoices()  -> [PodcastVoice] {
        
        // prepare result
        var returnedVoices = [PodcastVoice]()
        
        let nativeVoices = SelmaVoice.allVoices
        
        for nativeVoice in nativeVoices {
            let voice = PodcastVoice(speechProvider: .SELMA, languageCode: nativeVoice.language, identifier: nativeVoice.id.rawValue)
            returnedVoices.append(voice)
        }
        
        return returnedVoices
    }
    
    /// All available Apple voices
    private func findSuitableAppleVoices()  -> [PodcastVoice] {
        
        // prepare result
        var returnedVoices = [PodcastVoice]()
        
        let nativeVoices = AVSpeechSynthesisVoice.speechVoices()
        
        for nativeVoice in nativeVoices {
            
            // eleminate com.apple.speech.synthesis
            var excludeVoice = false
            
            let eliminatedVoiceDomains = ["com.apple.speech.synthesis", "com.apple.eloquence"]
            for voiceDomain in eliminatedVoiceDomains {
                if nativeVoice.identifier.starts(with: voiceDomain) {
                    //print("Excluded Apple voice: \(nativeVoice.identifier)")
                    excludeVoice = true
                }
            }

            // skip to next voice if the current voice is not suitable
            if excludeVoice {
                continue
            }
            
            let voice = PodcastVoice(speechProvider: .Apple, languageCode: nativeVoice.language, identifier: nativeVoice.identifier)
            returnedVoices.append(voice)
        }
        
        return returnedVoices
    }
    
    /// Returns an Apple voice with the given name
    func voiceForAppleName(_ name: String) -> PodcastVoice? {

        var wantedVoice: AVSpeechSynthesisVoice?

        for voice in AVSpeechSynthesisVoice.speechVoices() {
            if voice.name.lowercased() == name.lowercased() {
                wantedVoice = voice
            }
        }

        // convert to PodcastVoice
        var podcastVoice: PodcastVoice?

        if let wantedVoice {
            podcastVoice = PodcastVoice(speechProvider: .Apple, languageCode: wantedVoice.language, identifier: wantedVoice.identifier)
        }

        return podcastVoice
    }

    // Returns a SELMA voice for the given name
    func voiceForSelmaNarrator(_ fullName: String) -> PodcastVoice? {

        var wantedVoice: SelmaVoice?

        for voice in SelmaVoice.allVoices {
            if voice.fullName.lowercased() == fullName.lowercased() {
                wantedVoice = voice
            }
        }

        // convert to PodcastVoice
        var podcastVoice: PodcastVoice?

        if let wantedVoice {
            podcastVoice = PodcastVoice(speechProvider: .SELMA, languageCode: wantedVoice.language, identifier: wantedVoice.id.rawValue)
        }

        return podcastVoice
    }
}