//
//  AudioManager.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 15.08.22.
//

import Foundation

import AVFoundation
import SelmaKit

class AudioManager: NSObject, AVAudioPlayerDelegate {
    
    // singleton
    static var shared = AudioManager()
    
    // Selma API
    let selmaAPI = SelmaAPI()
    
    var audioPlayer: AVAudioPlayer?
    var audioEngine: AVAudioEngine?
    
    override init() {
        super.init()
        
#if os(iOS)
        // activate playback mode
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
#endif
    }
    
    func synthesizeSpeech(podcastVoice: PodcastVoice, text: String?, toURL fileURL: URL) async -> Bool {
        
        // return early if there is no text
        guard let text else {return false}
        
        // the result will be stored here
        var success = false
        
        switch podcastVoice.speechProvider {
        case .SELMA:
            if let voiceApiName = podcastVoice.nativeSelmaVoice()?.apiName {
                success = await selmaAPI.renderSpeech(voiceApiName: voiceApiName, text: text, toURL: fileURL)
            }
            
        case .Apple:
            let appleVoiceIdentifier = podcastVoice.identifier
            success = await AppleSpeechManager.shared.renderAppleSpeech(voiceIdentifier: appleVoiceIdentifier, text: text, toURL: fileURL)

        case .ElevenLabs:
            let voiceName = podcastVoice.identifier
            let apiKey = UserDefaults.standard.string(forKey: Constants.userDefaultsElevenLabsAPIKeyName)
            
            // only proceed if we have an apiKey
            if apiKey?.count ?? 0 > 0 {
                let voiceManager = ElevenLabsVoiceManager(apiKey: apiKey!, elevenLabsModelId: .multilingualV1)
                success = await voiceManager.renderSpeech(voiceName: voiceName, text: text, toURL: fileURL, stability: 0.9, similarityBoost: 0.5)
            }
            
        default:
            print("I don't know yet how to render speech for \(podcastVoice.speechProvider.displayName)")
            break
        }
     
        return success
    }
    
    
    

    private typealias AudioPlayerCheckedContinuation = CheckedContinuation<Void, Never>
    private var audioPlayerCheckedContinuation: AudioPlayerCheckedContinuation?
    
    func playAudio(audioUrl: URL) async {
        
        // in case that we have an outstanding checkedContinuation, resume it
        audioPlayerCheckedContinuation?.resume()
        
        return await withCheckedContinuation({ continuation in
            
            audioPlayerCheckedContinuation = continuation
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: audioUrl)
                audioPlayer?.delegate = self
                audioPlayer?.play()
            } catch {
                print("Could not play audio.")
            }
            
        })

    }
    
    func stopAudio() {
        audioPlayer?.stop()
        audioPlayerCheckedContinuation?.resume()
        audioPlayerCheckedContinuation = nil
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Did finish Playing")
        audioPlayerCheckedContinuation?.resume()
        audioPlayerCheckedContinuation = nil
    }
    
    
    private func avAudioFile(forResource resource: String, withExtension ex: String) -> AVAudioFile {
        
        let sourceFile: AVAudioFile
        do {
            let sourceFileURL = Bundle.main.url(forResource: resource, withExtension: ex)!
            sourceFile = try AVAudioFile(forReading: sourceFileURL)
            //format = sourceFile.processingFormat
        } catch {
            fatalError("Unable to load the source audio file: \(error.localizedDescription).")
        }
        
        return sourceFile
    }
    

 
    
    func deleteCachedFiles() {
        let documentsFolderURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        
        do {
            let items = try FileManager.default.contentsOfDirectory(at: documentsFolderURL, includingPropertiesForKeys: nil)

            for itemURL in items {
                if itemURL.pathExtension == "wav" {
                    try FileManager.default.removeItem(at: itemURL)
                    print("Removed: \(itemURL.absoluteString)")
                }
            }
        } catch {
            // failed to read directory – bad permissions, perhaps?
            print("\(error)")
        }
    }
    
}

// MARK: -  All code relating to the storage of the music files used for prefix, main and suffix audio
extension AudioManager {

    // Describes an audio file and its location
    struct AudioFile: Hashable, Codable {
        var displayName: String
        var bundlePath: String
        var url: URL? {
            Bundle.main.url(forResource: bundlePath, withExtension: nil)
        }
    }
    
    /// Returns all locally available audio files
    static func availableAudioFiles() -> [AudioFile] {

        var audioFiles = [AudioFile]()
  
        audioFiles.append(AudioFile(displayName: "None", bundlePath: ""))
        
        audioFiles.append(AudioFile(displayName: "Intro Start", bundlePath: "00-intro-start-trimmed.caf"))
        audioFiles.append(AudioFile(displayName: "Intro Main", bundlePath: "01-intro-middle-trimmed.caf"))
        audioFiles.append(AudioFile(displayName: "Intro End", bundlePath: "02-intro-end-trimmed.caf"))
        
        audioFiles.append(AudioFile(displayName: "Sting", bundlePath: "03-sting-trimmed.caf"))
        
        audioFiles.append(AudioFile(displayName: "Outro Start", bundlePath: "07-outro-start-trimmed.caf"))
        audioFiles.append(AudioFile(displayName: "Outro Main", bundlePath: "08-outro-middle-trimmed.caf"))
        audioFiles.append(AudioFile(displayName: "Outro End", bundlePath: "09-outro-end-trimmed.caf"))
        
        return audioFiles
    }

    /// An array of the names of all available audio files
    static func availableAudioFileNames() -> [String] {
        
        var audioFileNames = ["None"]
        
        // go through all Audio files
        for audioFile in Self.availableAudioFiles() {
            audioFileNames.append(audioFile.displayName)
        }
        
        return audioFileNames
    }
    
    /// Returns the URL for the given audi file name
    static func urlForDisplayName(_ displayName: String) -> URL? {
        
        var url: URL?
        
        for audioFile in Self.availableAudioFiles() {
            if displayName == audioFile.displayName {
                url = audioFile.url
            }
        }
        
        return url
    }
    
    static func audioFileForDisplayName(_ displayName: String) -> AudioFile {
        
        var wantedAudioFile = Self.availableAudioFiles()[0] // default is the first in the list
        
        for audioFile in Self.availableAudioFiles() {
            if displayName == audioFile.displayName {
                wantedAudioFile = audioFile
            }
        }
        
        return wantedAudioFile
    }
    
}

// MARK: -- Code where Audio Episode is created directly from episode data
extension AudioManager {
    
    /// Create audio episode, restricted to a certain section if parameter <selectedSectionIndex> is not nil
    func createAudioEpisodeBasedOnEpisode(_ episode: Episode, selectedSectionIndex: Int?) async -> URL {
        
        // initialize a new audio episode
        var audioEpisode = AudioEpisode()
        
        // go through episode section and process it
        for (sectionIndex, _) in episode.sections.enumerated() {
            
            // if a specific section was requested...
            if let selectedSectionIndex {
                // and if the loop's sectionIndex matches...
                if sectionIndex == selectedSectionIndex {
                    // add this section to the audioEpisode
                    await processSection(episode: episode, sectionIndex: sectionIndex, audioEpisode: &audioEpisode)
                }
            } else {
                // if we are _not_ restricting ourselves to a certain section, add all sections
                await processSection(episode: episode, sectionIndex: sectionIndex, audioEpisode: &audioEpisode)
            }
            
        }
        
        // deduce outputFileName
        let episodeIdString = episode.id.uuidString
        var outputFileName = "e-\(episodeIdString)"
        
        // add section index if we only render a section
        if let selectedSectionIndex {
            outputFileName += "-s\(selectedSectionIndex)"
        }
        
        // render episode
        let url = audioEpisode.render(outputfileName: outputFileName)
        
        return url
    }
    
    // Synthesizes text in specified section and adds audio for all three segments
    private func processSection(episode: Episode, sectionIndex: Int, audioEpisode: inout AudioEpisode) async {
        
        // contains id of current audio segment
        var segmentId: Int
        
        // contains audioURL
        var audioUrl: URL?
        
        // get relevant episodeSection
        let episodeSection = episode.sections[sectionIndex]
        
        // extract stories for headlines and story section
        let stories = episode.stories
        
        // ********* PREFIX Segment *********
        
        // prefix audio
        segmentId = audioEpisode.addSegment()
        audioUrl = episodeSection.prefixAudioFile.url
        audioEpisode.addAudioTrack(toSegmentId: segmentId, url: audioUrl, volume: 0.5)
        
        
        // ********* MAIN Segment *********
        
        // create main segment
        segmentId = audioEpisode.addSegment()
        
        // render the main text in the episode section. Returns nil if unsuccessful
        await audioUrl = renderText(inEpisode: episode, section: episodeSection)
        
        // add main text to new segment
        audioEpisode.addAudioTrack(toSegmentId: segmentId, url: audioUrl)
        
        // add text audio
        switch episodeSection.type {
            
        // the main segment of the standard episodeSection only contains the text audio given through textAudioURL
        // this hase been added above
        case .standard:
            break
            
        case .headlines:
            
            // which stories should appear in the headlines?
            var storiesUsedForHeadlines: [Story] = stories // by default, use all stories for headlines
            
            // if we are restricting ourselves as defined by the episode, filter stories used in headlines
            if episode.restrictHeadlinesToHighLights {
                storiesUsedForHeadlines = stories.filter{$0.usedInIntroduction == true}
            }
            
            // go through each headline story
            for (storyIndex, story) in storiesUsedForHeadlines.enumerated() {
                // headline audio
                await audioUrl = renderText(inEpisode: episode, section: episodeSection, story: story, useHeadline: true)
                audioEpisode.addAudioTrack(toSegmentId: segmentId, url: audioUrl)
                
                // add separator, except for the last headline
                if storyIndex < storiesUsedForHeadlines.count - 1 {
                    audioUrl = episodeSection.separatorAudioFile.url
                    audioEpisode.addAudioTrack(toSegmentId: segmentId, url: audioUrl, volume: 0.4)
                }
                
            }
        case .stories:
            // go through each story
            for (storyIndex, story) in stories.enumerated() {
                // story audio
                await audioUrl = renderText(inEpisode: episode, section: episodeSection, story: story, useHeadline: false)
                audioEpisode.addAudioTrack(toSegmentId: segmentId, url: audioUrl)
                
                // add separator, except for the last story
                if storyIndex < stories.count - 1 {
                    audioUrl = episodeSection.separatorAudioFile.url
                    audioEpisode.addAudioTrack(toSegmentId: segmentId, url: audioUrl, volume: 0.4)
                }
                
            }
        }
        
        // add background audio to the same segment
        audioUrl = episodeSection.mainAudioFile.url
        audioEpisode.addAudioTrack(toSegmentId: segmentId, url: audioUrl, delay: 0.0, volume: 0.3, fadeIn: 0.0, fadeOut: 0.0, isLoopingBackgroundTrack: true)
        
        
        // ********* SUFFIX Segment *********
        
        // add suffix audio to a new segment
        segmentId = audioEpisode.addSegment()
        audioUrl = episodeSection.suffixAudioFile.url
        audioEpisode.addAudioTrack(toSegmentId: segmentId, url: audioUrl, volume: 0.5)
        
    }
    
    private func renderText(inEpisode episode: Episode, section episodeSection: EpisodeSection, story: Story? = nil, useHeadline: Bool = true) async -> URL? {
        
        // the speaker identifier
        let podcastVoice = episode.podcastVoice
        
        // where is the audio stored?
        
        // by default, use the section's main text
        var audioURL = episode.textAudioURL(forSection: episodeSection)
        var rawText = episodeSection.rawText
        
        // if we want to render a story headline or main text...
        if let story {
            if useHeadline { // render headline
                audioURL = episode.headlineAudioURL(forStory: story)
                rawText = story.headline
            } else { // render main story text
                audioURL = episode.storyTextAudioURL(forStory: story)
                rawText = story.storyText
            }
        }
        
        // if we successfully rendered the speech, return its audioURL. Otherwise return nil.
        var returnedURL: URL? = nil
        
        // if there is any tex tat all, render it
        if rawText.count > 0 {
            
            // replace tokens
            let textToRender = episode.replaceTokens(inText: rawText)
            
            // render audio
            var success = true
            //if !FileManager.default.fileExists(atPath: audioURL.path) {
            success = await synthesizeSpeech(podcastVoice: podcastVoice, text: textToRender, toURL: audioURL)
            //}
            
            if success {
                returnedURL = audioURL
            }
        }
        
        return returnedURL
    }
    
}
