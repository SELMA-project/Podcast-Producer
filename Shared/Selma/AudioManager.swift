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
    
    func synthesizeAudio(speakerName: String?, text: String?, toURL fileURL: URL) async -> Bool {
        
        var success = false
        let speakerName = speakerName ?? "leila endruweit"
        let text = text ?? "Olá, hoje é quinta-feira, três de setembro de 2020."
        
        let audioData = await selmaAPI.renderAudio(speakerName: speakerName, text: text)
        
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
    
    // S0: intro music
    private func createS0(episodeStructure: [BuildingBlock], audioEpisode: inout AudioEpisode) {
        
        // add new segment
        let segmentId = audioEpisode.addSegment()
        
        // in S0: music
        let introStartFile = Bundle.main.url(forResource: "00-intro-start-trimmed.caf", withExtension: nil)!
        audioEpisode.addAudioTrack(toSegmentId: segmentId, url: introStartFile)
    }
    
    // S1: welcome and headlines
    private func createS1(episodeStructure: [BuildingBlock], audioEpisode: inout AudioEpisode) {
        
        // add new segment
        let segmentId = audioEpisode.addSegment()
        
        for (_, episodeSegment) in episodeStructure.enumerated() {
            
            // welcome text in S1
            if episodeSegment.blockIdentifier == .introduction {
                
                // add speech
                if let speechUrl = episodeSegment.audioURL {
                    audioEpisode.addAudioTrack(toSegmentId: segmentId, url: speechUrl)
                }
                
            }
            
            // headlines added to S1
            if episodeSegment.blockIdentifier == .headline  {
                
                // only use the headlines that should be highlighted in summary
                if episodeSegment.highlightInSummary == true {
                    // add speech
                    if let speechUrl = episodeSegment.audioURL {
                        audioEpisode.addAudioTrack(toSegmentId: segmentId, url: speechUrl)
                    }
                }
            }
        }
        
        // add music once we know how long the segment is
        let backgroundMusicFile = Bundle.main.url(forResource: "01-intro-middle-trimmed.caf", withExtension: nil)!
        audioEpisode.addAudioTrack(toSegmentId: segmentId, url: backgroundMusicFile, volume: 0.5, isLoopingBackgroundTrack: true)
        
    }
    
    // S2: end of introduction
    private func createS2(episodeStructure: [BuildingBlock], audioEpisode: inout AudioEpisode) {
        
        // add new segment
        let segmentId = audioEpisode.addSegment()
        
        // in S2: music
        let introEndFile = Bundle.main.url(forResource: "02-intro-end-trimmed.caf", withExtension: nil)!
        audioEpisode.addAudioTrack(toSegmentId: segmentId, url: introEndFile)
    }
    
    // S3: Stories
    private func createS3(episodeStructure: [BuildingBlock], audioEpisode: inout AudioEpisode) {
        
        // add new segment
        let segmentId = audioEpisode.addSegment()
        
        // filter to restrict to stories
        let storySegments = episodeStructure.filter({ $0.blockIdentifier == .story })
        
        for (index, episodeSegment) in storySegments.enumerated() {
            
            // Add storys
            if episodeSegment.blockIdentifier == .story {
                
                // add speech
                if let speechUrl = episodeSegment.audioURL {
                    audioEpisode.addAudioTrack(toSegmentId: segmentId, url: speechUrl)
                }
                
                // add a sting at the end of each - except the last one
                if index < storySegments.endIndex - 1 {
                    let stingFile = Bundle.main.url(forResource: "03-string-trimmed.caf", withExtension: nil)!
                    audioEpisode.addAudioTrack(toSegmentId: segmentId, url: stingFile)
                }
                
            }
        }

    }
    
    // S4: Outro Start
    private func createS4(episodeStructure: [BuildingBlock], audioEpisode: inout AudioEpisode) {
        
        // add new segment
        let segmentId = audioEpisode.addSegment()
        
        // outro start
        let audioFile = Bundle.main.url(forResource: "07-outro-start-trimmed.caf", withExtension: nil)!
        audioEpisode.addAudioTrack(toSegmentId: segmentId, url: audioFile)
    }
    
    // S5: Outro Middle
    private func createS5(episodeStructure: [BuildingBlock], audioEpisode: inout AudioEpisode) {
        
        // add new segment
        let segmentId = audioEpisode.addSegment()
        
        // add epiloge speech
        let episodeSegment = episodeStructure.filter({$0.blockIdentifier == .epilogue})[0]
        if let speechUrl = episodeSegment.audioURL {
            audioEpisode.addAudioTrack(toSegmentId: segmentId, url: speechUrl)
        }
        
        // outro middle as background
        let audioFile = Bundle.main.url(forResource: "08-outro-middle-trimmed.caf", withExtension: nil)!
        audioEpisode.addAudioTrack(toSegmentId: segmentId, url: audioFile, volume: 0.5, isLoopingBackgroundTrack: true)
    }
    
    // S6: Outro end
    private func createS6(episodeStructure: [BuildingBlock], audioEpisode: inout AudioEpisode) {
        
        // add new segment
        let segmentId = audioEpisode.addSegment()
        
        // outro start
        let audioFile = Bundle.main.url(forResource: "09-outro-end-trimmed.caf", withExtension: nil)!
        audioEpisode.addAudioTrack(toSegmentId: segmentId, url: audioFile)
    }
    
    
    /// Renders and Audio Episode and resturns its (local) URL
    func createAudioEpisode(basedOnEpisodeStructure episodeStructure: [BuildingBlock]) -> URL {
        
        // create entrie episode
        var audioEpisode = AudioEpisode()
        
        createS0(episodeStructure: episodeStructure, audioEpisode: &audioEpisode)
        createS1(episodeStructure: episodeStructure, audioEpisode: &audioEpisode)
        createS2(episodeStructure: episodeStructure, audioEpisode: &audioEpisode)
        createS3(episodeStructure: episodeStructure, audioEpisode: &audioEpisode)
        createS4(episodeStructure: episodeStructure, audioEpisode: &audioEpisode)
        createS5(episodeStructure: episodeStructure, audioEpisode: &audioEpisode)
        createS6(episodeStructure: episodeStructure, audioEpisode: &audioEpisode)
        
        // render episode
        let url = audioEpisode.render(outputfileName: "output")
        
        return url
    }
    

    
    func deleteContentsOfDocumentDirectory() {
        let documentsFolderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
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
    
    /// Returns all locally available audio files
    static func availableAudioFiles() -> [URL] {
        
        var audioUrls = [URL]()
        
        for extension in ["caf", "mp3", "m4a"] {
            let urlsForExtension = Bundle.main.urls(forResourcesWithExtension: extension, subdirectory: nil)
            audioUrls.append(contentsOf: urlsForExtension)
        }
        
        return audioUrls
    }
    
}
