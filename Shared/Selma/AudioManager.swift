//
//  AudioManager.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 15.08.22.
//

import Foundation

import AVFoundation


class AudioManager: NSObject, AVAudioPlayerDelegate {
    
    // singleton
    static var shared = AudioManager()
    
    // Selma API
    let selmaAPI = SelmaAPI()
    
    var audioPlayer: AVAudioPlayer?
    var audioEngine: AVAudioEngine?
    
    override init() {
        super.init()
    }
    
    func synthesizeAudio(podcastVoice: PodcastVoice, text: String?, toURL fileURL: URL) async -> Bool {
        
        // TODO: extend for other voices
        guard podcastVoice.speechProvider == .SELMA else {return false}
        
        var success = false
        
        let selmaVoice = podcastVoice.nativeSelmaVoice()
        let selmaVoiceIdentifier = selmaVoice?.selmaName ?? "leila endruweit"
        
        let text = text ?? "Olá, hoje é quinta-feira, três de setembro de 2020."
        
        let audioData = await selmaAPI.renderAudio(speakerName: selmaVoiceIdentifier, text: text)
        
        if let data = audioData {            
            do {
                try data.write(to: fileURL)
                success = true
            } catch {
                print("Error writing audio to file with URL: \(fileURL)")
            }
        } else {
            print("Error while rendering audio on the server.")
        }
        
        return success
    }
    
    
    private typealias AudioPlayerCheckedContinuation = CheckedContinuation<Void, Never>
    private var audioPlayerCheckedContinuation: AudioPlayerCheckedContinuation?
    
    func playAudio(audioUrl: URL) async {
        
        // in case that we have an outstanding checkedContinuationm, resume it
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
                try FileManager.default.removeItem(at: itemURL)
                print("Removed: \(itemURL.absoluteString)")
            }
        } catch {
            // failed to read directory – bad permissions, perhaps?
            print("\(error)")
        }
    }
    
}

extension AudioManager {

    struct AudioFile: Hashable {
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
    
    func createAudioEpisodeBasedOnEpisode(_ episode: Episode) -> URL {
        
        // create entire episode
        var audioEpisode = AudioEpisode()
        
        // go through episode sections and process them
        for (sectionIndex, _) in episode.sections.enumerated() {
            processSection(episode: episode, sectionIndex: sectionIndex, audioEpisode: &audioEpisode)
        }
        
        // render episode
        let url = audioEpisode.render(outputfileName: "output")
        
        return url
    }
    
    private func processSection(episode: Episode, sectionIndex: Int, audioEpisode: inout AudioEpisode) {
        
        // contains id of current audio segment
        var segmentId: Int
        
        // contains audioURL
        var audioUrl: URL?
        
        // get relevant episodeSection
        let episodeSection = episode.sections[sectionIndex]
        
        // extract stories for headlines and story section
        let stories = episode.stories
        
        // prefix audio
        segmentId = audioEpisode.addSegment()
        audioUrl = episodeSection.prefixAudioFile.url
        audioEpisode.addAudioTrack(toSegmentId: segmentId, url: audioUrl)
        
        // create main segment
        segmentId = audioEpisode.addSegment()
        
        // add main text to new segment
        let voiceIdentifier = episode.podcastVoice.identifier
        audioUrl = Episode.textAudioURL(forSectionType: episodeSection.type, voiceIndentifier: voiceIdentifier, textContent: episodeSection.text)
        audioEpisode.addAudioTrack(toSegmentId: segmentId, url: audioUrl)
        
        // add text audio
        switch episodeSection.type {
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
                audioUrl = Episode.textAudioURL(forSectionType: episodeSection.type, voiceIndentifier: voiceIdentifier, textContent: story.headline)
                audioEpisode.addAudioTrack(toSegmentId: segmentId, url: audioUrl)
                
                // add separator, except for the last headline
                if storyIndex < storiesUsedForHeadlines.count - 1 {
                    audioUrl = episodeSection.separatorAudioFile.url
                    audioEpisode.addAudioTrack(toSegmentId: segmentId, url: audioUrl)
                }
                
            }
        case .stories:
            // go through each story
            for (storyIndex, story) in stories.enumerated() {
                // story audio
                audioUrl = Episode.textAudioURL(forSectionType: episodeSection.type, voiceIndentifier: voiceIdentifier, textContent: story.storyText)
                audioEpisode.addAudioTrack(toSegmentId: segmentId, url: audioUrl)
                
                // add separator, except for the last story
                if storyIndex < stories.count - 1 {
                    audioUrl = episodeSection.separatorAudioFile.url
                    audioEpisode.addAudioTrack(toSegmentId: segmentId, url: audioUrl)
                }
                
            }
        }
        
        // add background audio to the same segment
        audioUrl = episodeSection.mainAudioFile.url
        audioEpisode.addAudioTrack(toSegmentId: segmentId, url: audioUrl, delay: 0.0, volume: 0.5, fadeIn: 0.0, fadeOut: 0.0, isLoopingBackgroundTrack: true)
        
        // add suffix audio to a new segment
        segmentId = audioEpisode.addSegment()
        audioUrl = episodeSection.suffixAudioFile.url
        audioEpisode.addAudioTrack(toSegmentId: segmentId, url: audioUrl)
        
    }
    
    
    /// Adds audio to episode. Creates a new segment if *possibleSegmentId* is nil. Returns the segmentId that was used
//    private func addAudio(withURL audioUrl: URL?, toAudioEpisode audioEpisode: inout AudioEpisode, toSegmentWithId segmentId: Int) {
//
//        // do we have an audioURL?
//        if let audioUrl {
//
//            // do we have a file stored behind the URL?
//            if FileManager.default.fileExists(atPath: audioUrl.path(percentEncoded: false)) {
//
//                // add audio to episode
//                audioEpisode.addAudioTrack(toSegmentId: segmentId, url: audioUrl)
//            }
//
//        }
//    }
    
}

// this should be obsolete
//extension AudioManager {
//    
//    /// Renders and Audio Episode and resturns its (local) URL
//    func createAudioEpisode(basedOnBuildingBlocks episodeStructure: [BuildingBlock]) -> URL {
//        
//        // create entrie episode
//        var audioEpisode = AudioEpisode()
//        
//        createS0(episodeStructure: episodeStructure, audioEpisode: &audioEpisode)
//        createS1(episodeStructure: episodeStructure, audioEpisode: &audioEpisode)
//        createS2(episodeStructure: episodeStructure, audioEpisode: &audioEpisode)
//        createS3(episodeStructure: episodeStructure, audioEpisode: &audioEpisode)
//        createS4(episodeStructure: episodeStructure, audioEpisode: &audioEpisode)
//        createS5(episodeStructure: episodeStructure, audioEpisode: &audioEpisode)
//        createS6(episodeStructure: episodeStructure, audioEpisode: &audioEpisode)
//        
//        // render episode
//        let url = audioEpisode.render(outputfileName: "output")
//        
//        return url
//    }
//    
//    // S0: intro music
//    private func createS0(episodeStructure: [BuildingBlock], audioEpisode: inout AudioEpisode) {
//        
//        // add new segment
//        let segmentId = audioEpisode.addSegment()
//        
//        // in S0: music
//        let introStartFile = Bundle.main.url(forResource: "00-intro-start-trimmed.caf", withExtension: nil)!
//        audioEpisode.addAudioTrack(toSegmentId: segmentId, url: introStartFile)
//    }
//    
//    // S1: welcome and headlines
//    private func createS1(episodeStructure: [BuildingBlock], audioEpisode: inout AudioEpisode) {
//        
//        // add new segment
//        let segmentId = audioEpisode.addSegment()
//        
//        for (_, episodeSegment) in episodeStructure.enumerated() {
//            
//            // welcome text in S1
//            if episodeSegment.blockIdentifier == .introduction {
//                
//                // add speech
//                if let speechUrl = episodeSegment.audioURL {
//                    audioEpisode.addAudioTrack(toSegmentId: segmentId, url: speechUrl)
//                }
//                
//            }
//            
//            // headlines added to S1
//            if episodeSegment.blockIdentifier == .headline  {
//                
//                // only use the headlines that should be highlighted in summary
//                if episodeSegment.highlightInSummary == true {
//                    // add speech
//                    if let speechUrl = episodeSegment.audioURL {
//                        audioEpisode.addAudioTrack(toSegmentId: segmentId, url: speechUrl)
//                    }
//                }
//            }
//        }
//        
//        // add music once we know how long the segment is
//        let backgroundMusicFile = Bundle.main.url(forResource: "01-intro-middle-trimmed.caf", withExtension: nil)!
//        audioEpisode.addAudioTrack(toSegmentId: segmentId, url: backgroundMusicFile, volume: 0.5, isLoopingBackgroundTrack: true)
//        
//    }
//    
//    // S2: end of introduction
//    private func createS2(episodeStructure: [BuildingBlock], audioEpisode: inout AudioEpisode) {
//        
//        // add new segment
//        let segmentId = audioEpisode.addSegment()
//        
//        // in S2: music
//        let introEndFile = Bundle.main.url(forResource: "02-intro-end-trimmed.caf", withExtension: nil)!
//        audioEpisode.addAudioTrack(toSegmentId: segmentId, url: introEndFile)
//    }
//    
//    // S3: Stories
//    private func createS3(episodeStructure: [BuildingBlock], audioEpisode: inout AudioEpisode) {
//        
//        // add new segment
//        let segmentId = audioEpisode.addSegment()
//        
//        // filter to restrict to stories
//        let storySegments = episodeStructure.filter({ $0.blockIdentifier == .story })
//        
//        for (index, episodeSegment) in storySegments.enumerated() {
//            
//            // Add storys
//            if episodeSegment.blockIdentifier == .story {
//                
//                // add speech
//                if let speechUrl = episodeSegment.audioURL {
//                    audioEpisode.addAudioTrack(toSegmentId: segmentId, url: speechUrl)
//                }
//                
//                // add a sting at the end of each - except the last one
//                if index < storySegments.endIndex - 1 {
//                    let stingFile = Bundle.main.url(forResource: "03-sting-trimmed.caf", withExtension: nil)!
//                    audioEpisode.addAudioTrack(toSegmentId: segmentId, url: stingFile)
//                }
//                
//            }
//        }
//
//    }
//    
//    // S4: Outro Start
//    private func createS4(episodeStructure: [BuildingBlock], audioEpisode: inout AudioEpisode) {
//        
//        // add new segment
//        let segmentId = audioEpisode.addSegment()
//        
//        // outro start
//        let audioFile = Bundle.main.url(forResource: "07-outro-start-trimmed.caf", withExtension: nil)!
//        audioEpisode.addAudioTrack(toSegmentId: segmentId, url: audioFile)
//    }
//    
//    // S5: Outro Middle
//    private func createS5(episodeStructure: [BuildingBlock], audioEpisode: inout AudioEpisode) {
//        
//        // add new segment
//        let segmentId = audioEpisode.addSegment()
//        
//        // add epiloge speech
//        let episodeSegment = episodeStructure.filter({$0.blockIdentifier == .epilogue})[0]
//        if let speechUrl = episodeSegment.audioURL {
//            audioEpisode.addAudioTrack(toSegmentId: segmentId, url: speechUrl)
//        }
//        
//        // outro middle as background
//        let audioFile = Bundle.main.url(forResource: "08-outro-middle-trimmed.caf", withExtension: nil)!
//        audioEpisode.addAudioTrack(toSegmentId: segmentId, url: audioFile, volume: 0.5, isLoopingBackgroundTrack: true)
//    }
//    
//    // S6: Outro end
//    private func createS6(episodeStructure: [BuildingBlock], audioEpisode: inout AudioEpisode) {
//        
//        // add new segment
//        let segmentId = audioEpisode.addSegment()
//        
//        // outro start
//        let audioFile = Bundle.main.url(forResource: "09-outro-end-trimmed.caf", withExtension: nil)!
//        audioEpisode.addAudioTrack(toSegmentId: segmentId, url: audioFile)
//    }
//    
//    
//
//    
//}
