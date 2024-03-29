//
//  VoiceManager.swift
//  Podcast Creator
//
//  Created by Andy Giefer on 01.11.22.
//

import Foundation
import AVFoundation


enum SpeechProvider: String, CaseIterable, Codable {
    case SELMA, Apple, EuroVOX, ElevenLabs
    
    var displayName: String {
        return rawValue
    }
    
}

class VoiceManager {
    
    static let shared = VoiceManager()
    
    var appleVoices: [PodcastVoice] = []
    var selmaVoices: [PodcastVoice] = []
    var eurovoxVoices: [PodcastVoice] = []
    var elevenLabsVoices: [PodcastVoice] = []
    
    init() {
        
        // cache filtering of suitable  voices
        findSuitableVoices()
    }
    
    func findSuitableVoices() {
        print("Finding suitable voices")
        self.appleVoices =  findSuitableAppleVoices()
        self.selmaVoices =  findSuitableSelmaVoices()
        self.eurovoxVoices =  findSuitableEurovoxVoices()
        self.elevenLabsVoices =  findSuitableElevenLabsVoices()
    }
    
    /// Proposes a voice based on the given locale
    func proposedVoice(forLanguageCode languageCode: String) -> PodcastVoice {
        
        // the proposed voice of brasilian portuguese is Leila
        if languageCode == "pt-BR" {
            let leilasVoice = PodcastVoice(speechProvider: .SELMA, languageCode: "pt-BR", identifier: "leila")
            return leilasVoice
        }
        
        // all other locales: use Apple Voices
        
        // we don't have a voice for Urdu yet, so let's use Hidi instead
        let appleLanguageCode = languageCode != "ur-PK" ? languageCode : "hi-IN"
            
        // the proposed PodcastVoice is stored here
        var proposedPodcastVoice: PodcastVoice?
        
        // get all voices that we can synthesize
        let usableApplePodcastVoices = voicesForSpeechProvider(.Apple)
        
        // go through each one of them
        for applePodcastVoice in usableApplePodcastVoices {
            
            // get the equivalent native apple voice
            if let nativeAppleVoice = applePodcastVoice.nativeAppleVoice() {
                
                // do we have the right language?
                if nativeAppleVoice.language == appleLanguageCode {
                                        
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

            // skip to next provider if ElevenLabs is not available
            if provider == .ElevenLabs && !isElevenLabsVoiceAvailable {
                continue
            }
            
            // get all provided voice
            let availableVoices = availableVoices(forLanguage: language, forProvider: provider)
            
            // if we have at least one voice, this provider is available
            if availableVoices.count > 0 {
                providersForLanguage.append(provider)
            }
        }
        
        return providersForLanguage
    }
    
    
    /// Returns all voices for given language and provider
    func availableVoices(forLanguage language: LanguageManager.Language, forProvider provider: SpeechProvider) -> [PodcastVoice] {
        
        // all voice sharing the same speech provider
        let voicesOfSameProvider = voicesForSpeechProvider(provider)
        
        // filter to find those voices sharing the same language
        let relatedVoices = voicesOfSameProvider.filter {$0.languageCode == language.isoCode}
        
        return relatedVoices
    }
    
    
    /// Retuns all voice for given provider
    func voicesForSpeechProvider(_ speechProvider: SpeechProvider) -> [PodcastVoice] {
        
        switch speechProvider {
        case .Apple: return appleVoices
        case .SELMA: return selmaVoices
        case .EuroVOX: return eurovoxVoices
        case .ElevenLabs: return elevenLabsVoices
        }
        
    }
    
    // TODO: Add voices
    private func findSuitableEurovoxVoices()  -> [PodcastVoice] {
        return []
    }

    private func findSuitableElevenLabsVoices()  -> [PodcastVoice] {
        // prepare result
        var returnedVoices = [PodcastVoice]()
        
        let andysVoices = getAllVoicesFor(identifier: "Andy")
        //let leilasVoices = getAllVoicesFor(identifier: "Leila")
        
        returnedVoices.append(contentsOf: andysVoices)
        //returnedVoices.append(contentsOf: leilasVoices)
        
        return returnedVoices
    }
    
    private func getAllVoicesFor(identifier: String) -> [PodcastVoice] {
        // prepare result
        var returnedVoices = [PodcastVoice]()
        
        let usVoice = PodcastVoice(speechProvider: .ElevenLabs, languageCode: "en-US", identifier: identifier)
        let ukVoice = PodcastVoice(speechProvider: .ElevenLabs, languageCode: "en-UK", identifier: identifier)
        let auVoice = PodcastVoice(speechProvider: .ElevenLabs, languageCode: "en-AU", identifier: identifier)
        let caVoice = PodcastVoice(speechProvider: .ElevenLabs, languageCode: "en-CA", identifier: identifier)
        let deVoice = PodcastVoice(speechProvider: .ElevenLabs, languageCode: "de-DE", identifier: identifier)
        let plVoice = PodcastVoice(speechProvider: .ElevenLabs, languageCode: "pl-PL", identifier: identifier)
        let esVoice = PodcastVoice(speechProvider: .ElevenLabs, languageCode: "es-ES", identifier: identifier)
        let mxVoice = PodcastVoice(speechProvider: .ElevenLabs, languageCode: "es-MX", identifier: identifier)
        let itVoice = PodcastVoice(speechProvider: .ElevenLabs, languageCode: "it-IT", identifier: identifier)
        let frVoice = PodcastVoice(speechProvider: .ElevenLabs, languageCode: "fr-FR", identifier: identifier)
        let ptVoice = PodcastVoice(speechProvider: .ElevenLabs, languageCode: "pt-PT", identifier: identifier)
        let brVoice = PodcastVoice(speechProvider: .ElevenLabs, languageCode: "pt-BR", identifier: identifier)
        let hiVoice = PodcastVoice(speechProvider: .ElevenLabs, languageCode: "hi-IN", identifier: identifier)
        
        returnedVoices = [usVoice, ukVoice, auVoice, caVoice, deVoice, plVoice, esVoice, mxVoice, itVoice, frVoice, ptVoice, brVoice, hiVoice]
        
        return returnedVoices
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

            let voice = PodcastVoice(speechProvider: .Apple, languageCode: nativeVoice.language, identifier: "\(nativeVoice.identifier)")
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

// MARK: ElevenLabs support
extension VoiceManager {
    
    /// Determines whether the ElvenLabs Voice manager is available for use.
    var isElevenLabsVoiceAvailable: Bool {
        let apiKey = UserDefaults.standard.string(forKey: Constants.userDefaultsElevenLabsAPIKeyName)
        
        if apiKey?.count ?? 0 > 0 {
            return true
        } else {
            return false
        }
    }
}
