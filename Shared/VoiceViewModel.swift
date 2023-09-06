//
//  VoiceViewModel.swift
//  DW Speaker
//
//  Created by Andy Giefer on 02.08.23.
//

import Foundation
import DWSpeakerKit

@MainActor
class VoiceViewModel: ObservableObject {
    
    /// Access point to for text-to-speech conversion.
    var voiceController: VoiceController
    
    /// Used to play and stop speech audio.
    var audioPlayerController: AudioPlayerController
    
    /// Stores which locales can be selected.
    @Published var selectableLocales: [Locale] = []
    
    /// Stores which providers can be selected.
    @Published var selectableProviders: [VoiceProvider] = []
    
    /// Stores whih voices can be selected.
    @Published var selectableVoices: [Voice] = []
    
    /// The identifier of the selected language.
    @Published var selectedLocaleId: String = "" {
        willSet {
            
            print("Updating selectedLocaleId to: \(newValue)")
            
            // store in user defaults
            UserDefaults.standard.set(newValue, forKey: UserDefaultKeys.selectedLocaleIdName)
            
            // manual publication
            objectWillChange.send()
            
            Task {
                // derive providers array and providerId
                let (providers, suggestedProvider) = await voiceController.findProviders(forLocaleId: newValue, currentProviderId: selectedProviderId)
                self.selectableProviders = providers
                
                if let suggestedProvider {
                    self.selectedProviderId = suggestedProvider.id
                }
            }
        }
        
    }

    
    /// The identifer of the selected provider.
    @Published var selectedProviderId: String = "" {
        willSet {
            
            print("Updating selectedProviderId to: \(newValue)")
            
            // store in user defaults
            UserDefaults.standard.set(newValue, forKey: UserDefaultKeys.selectedProviderIdName)
            
            objectWillChange.send()
            
            Task {
                // derive voices array and suggested voiceId
                let (voices, suggestedVoice) = await voiceController.findVoices(forLocaleId: selectedLocaleId, forProviderId: newValue, currentVoiceId: selectedVoiceId)
                self.selectableVoices = voices
                
                if let suggestedVoice {
                    self.selectedVoiceId = suggestedVoice.id
                }
            }
        }
    }
    

    
    /// The identifier of the selected voice.
    @Published var selectedVoiceId: String = "" {
        willSet {
            
            print("Updating selectedVoiceId to: \(newValue)")
            
            // store in user defaults
            UserDefaults.standard.set(newValue, forKey: UserDefaultKeys.selectedVoiceIdName)
            
            objectWillChange.send()
        }
        
    }
    
    
    /// Stores the individual settings for all voices.
    @Published var voiceSettings = VoiceSettings()
    
    /// The selected Voice Provider.
    var selectedProvider: VoiceProvider? {
        return voiceController.provider(forId: selectedProviderId)
    }
    
    /// Enumerates the different states that the audio player can take.
    enum PlayerStatus {
        case idle, rendering, playing
    }
    
    /// The current status of the audio player.
    @Published var playerStatus: PlayerStatus = .idle
    
    
    init() {
        
        /// Access to voice functionalitites
        self.voiceController = VoiceController(userDefaultsElevenLabsAPIKeyName: Constants.userDefaultsElevenLabsAPIKeyName)
        
        /// Access to audio player functionalitites
        self.audioPlayerController = AudioPlayerController()
        
        restoreDefaults()
    }
    
}

// MARK: Working with defaults
extension VoiceViewModel {
    
    struct UserDefaultKeys {
        static let selectedLocaleIdName = "voiceViewModelSelectedLocaleId"
        static let selectedProviderIdName = "voiceViewModelSelectedProviderId"
        static let selectedVoiceIdName = "voiceViewModelSelectedVoiceId"
    }
    
    private func restoreDefaults() {
        
        Task {
            
            // register defaults for all ids
            await registerDefaults()
            
            // all available locales can be selected
            self.selectableLocales = await voiceController.availableLocales() // all available locales
            
            // get stored ids from userDefaults
            let (restoredLocaleId, restoredProviderId, restoredVoiceId) = getStoredIds()
            
            // convert localeId to locale
            let restoredLocale = Locale(identifier: restoredLocaleId)
            
            // convert restoredProviderId to provider
            let restoredProvider = voiceController.provider(forId: restoredProviderId)
            
            // Download the restoredProvider's voices ahead of time.
            // The voices are then downloaded before a possible re-download can be triggered by updating the selectedProviderId.
            if let restoredProvider {
                //self.selectableVoices = await restoredProvider.availableVoicesForLocale(locale: restoredLocale)
                let (voices, _) = await voiceController.findVoices(forLocaleId: restoredLocale.identifier, forProviderId: restoredProvider.id, currentVoiceId: nil)
                self.selectableVoices = voices
            }
            
            // locale
            self.selectedLocaleId = restoredLocale.identifier // this also sets the selectable Providers
            
            // provider id
            self.selectedProviderId = restoredProviderId
            
            // voiceId
            self.selectedVoiceId = restoredVoiceId
            
        }
    }
    
    
    
    private func registerDefaults() async {
        
        // which provider and locale  should be shosen when the app starts the first time?
        let defaultLocaleId = "en-US"
        let defaultProvider = AppleVoiceProvider()
        
        // derive ids
        let defaultProviderId = defaultProvider.id
        let defaultVoiceId = await defaultProvider.preferedVoiceForLocale(locale: Locale(identifier: defaultLocaleId))!.id
        
        // register defaults
        UserDefaults.standard.register(defaults: [
            UserDefaultKeys.selectedLocaleIdName : defaultLocaleId,
            UserDefaultKeys.selectedProviderIdName: defaultProviderId,
            UserDefaultKeys.selectedVoiceIdName: defaultVoiceId,
        ])
        
    }
    
    /// Reads stored ids from userDefaults.
    /// - Returns: A tuple of (selectedLocaleId, selectedProviderId, selectedVoiceId)
    private func getStoredIds() -> (selectedLocaleId: String, selectedProviderId: String, selectedVoiceId: String) {
        
        let localekey = UserDefaultKeys.selectedLocaleIdName
        let selectedLocaleId = UserDefaults.standard.string(forKey: localekey)!
        
        // restore selected provider from User Defaults
        let providerKey = UserDefaultKeys.selectedProviderIdName
        let selectedProviderId = UserDefaults.standard.string(forKey: providerKey)!
        
        // restore selected voiceId from User Defaults
        let voiceKey = UserDefaultKeys.selectedVoiceIdName
        let selectedVoiceId = UserDefaults.standard.string(forKey: voiceKey)!
        
        return (selectedLocaleId: selectedLocaleId, selectedProviderId: selectedProviderId, selectedVoiceId: selectedVoiceId)
    }
    
}


// MARK: Speaking, stoping and rendering text.
extension VoiceViewModel {

    /// Speaks given text.
    /// - Parameter text: The text to speak.
    func speak(text: String) {

        Task {
            if let selectedVoice = await selectedProvider?.voice(forId: selectedVoiceId) {
                
                playerStatus = .rendering
                
                if let audioURL = await voiceController.synthesizeText(text, usingVoice: selectedVoice, settings: voiceSettings) {
                    playerStatus = .playing
                    await audioPlayerController.playAudio(audioUrl: audioURL)
                    playerStatus = .idle
                }
            }
        }
    }
    
    /// Stops audio playback.
    func stopSpeaking() {
        audioPlayerController.stopAudio()
    }
    
    /// Converts given text to speech and stores in in the given `destinationURL`.
    /// - Parameters:
    ///   - text: The text to convert,
    ///   - destinationURL: The file URL in which the resulting speech should be stored.
    func render(text: String, toURL destinationURL: URL) async {
        
        if let selectedVoice = await selectedProvider?.voice(forId: selectedVoiceId) {
        
            playerStatus = .rendering
            
            if let tempURL = await voiceController.synthesizeText(text, usingVoice: selectedVoice, settings: voiceSettings) {
                try? FileManager.default.moveItem(at: tempURL, to: destinationURL)
            }
            
            playerStatus = .idle
        }
    }

}

