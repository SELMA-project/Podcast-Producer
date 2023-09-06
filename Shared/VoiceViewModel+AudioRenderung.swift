//
//  VoiceViewModel+AudioRenderung.swift
//  Podcast Creator
//
//  Created by Andy Giefer on 06.09.23.
//

import Foundation

extension VoiceViewModel {
    
    /// Called when play button is sectionEditView is pressed
    /// - Parameters:
    ///   - chosenEpisode: The episode to render.
    ///   - episodeSectionIndex: The episode'S section index to render.
    /// - Returns: The URL of the rendered audio.
    func renderEpisodeSection(chosenEpisode: Episode, episodeSectionIndex: Int?) async -> URL? {
        
        // early return when we don't havea section index
        guard let episodeSectionIndex else {return nil}
        
        // make the VoiceViewModel the AudioManager's delegate for TTS
        AudioManager.shared.textToSpeechDelegate = self
        
        // create an audio episode which just contains the episode we want to preview
        let sectionAudioUrl = await AudioManager.shared.createAudioEpisodeBasedOnEpisode(chosenEpisode, selectedSectionIndex: episodeSectionIndex)
        
        return sectionAudioUrl
    }
    
    
    /// Render entire episode.
    /// - Parameters:
    ///   - episode: The episode to render.
    ///   - muteBackgroundAudio: A boolean controlling whether the background audio should be muted.
    /// - Returns: The file URL containing the rendered episode.
    func renderEpisode(_ episode: Episode, muteBackgroundAudio: Bool = false) async -> URL {
        
        // copy episode so that we can mute it
        var chosenEpisode = episode
        
        // mute backgroundAudio if requested
        if muteBackgroundAudio {
            chosenEpisode.muteBackgroundAudio()
        }
        
        // make the VoiceViewModel the AudioManager's delegate for TTS
        AudioManager.shared.textToSpeechDelegate = self
        
        // render episode as audio file
        let episodeUrl = await AudioManager.shared.createAudioEpisodeBasedOnEpisode(chosenEpisode, selectedSectionIndex: nil)
        print("Audio file saved here: \(String(describing: episodeUrl))")
        
        return episodeUrl
    }
}

/// VoiceViewModel becomes the AudioManager's delegate to do TTS
extension VoiceViewModel: AudioManagerDelegate {

    /// Delegate function called by the AudioManager for TTS.
    func synthesizeSpeech(text: String?, toURL fileURL: URL) async -> Bool {
        
        // default result
        var success = false

        // early exit if we don't have a text
        guard let text else {return false}
        
        // early exit if we don't have a voice
        guard let selectedVoice = await selectedProvider?.voice(forId: selectedVoiceId) else {return false}
        
        // synthesize to temporary URL
        if let tempURL = await voiceController.synthesizeText(text, usingVoice: selectedVoice, settings: voiceSettings) {
            // move to requested URL
            do {
                if FileManager.default.fileExists(atPath: fileURL.path()) {
                    try FileManager.default.removeItem(at: fileURL) // remove file first
                }
                try FileManager.default.moveItem(at: tempURL, to: fileURL)
                success = true
            } catch {
                print(error)
            }

        }
        
        return success
    }
}
