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
    private func createS0(episodeStructure: [EpisodeSegment], audioEpisode: inout AudioEpisode) {
        
        // add new segment
        let segmentId = audioEpisode.addSegment()
        
        // in S0: music
        let introStartFile = Bundle.main.url(forResource: "00-intro-start-trimmed.caf", withExtension: nil)!
        audioEpisode.addAudioTrack(toSegmentId: segmentId, url: introStartFile)
    }
    
    // S1: welcome and headlines
    private func createS1(episodeStructure: [EpisodeSegment], audioEpisode: inout AudioEpisode) {
        
        // add new segment
        let segmentId = audioEpisode.addSegment()
        
        for (_, episodeSegment) in episodeStructure.enumerated() {
            
            // welcome text in S1
            if episodeSegment.segmentIdentifer == .welcomeText {
                
                // add music
                let backgroundMusicFile = Bundle.main.url(forResource: "01-intro-middle-trimmed.caf", withExtension: nil)!
                audioEpisode.addAudioTrack(toSegmentId: segmentId, url: backgroundMusicFile, volume: 0.5, isLoopingBackgroundTrack: true)
                
                // add speech
                if let speechUrl = episodeSegment.audioURL {
                    audioEpisode.addAudioTrack(toSegmentId: segmentId, url: speechUrl)
                }
                
            }
            
            // headline introduction added to S1
            if episodeSegment.segmentIdentifer == .headlineIntroduction {
                // add speech
                if let speechUrl = episodeSegment.audioURL {
                    audioEpisode.addAudioTrack(toSegmentId: segmentId, url: speechUrl)
                }
            }
            
            // headlines added to S1
            if episodeSegment.segmentIdentifer == .headline  {
                
                // only use the headlines that should be highlighted in summary
                if episodeSegment.highlightInSummary == true {
                    // add speech
                    if let speechUrl = episodeSegment.audioURL {
                        audioEpisode.addAudioTrack(toSegmentId: segmentId, url: speechUrl)
                    }
                }
            }
        }
        
    }
    
    // S2: sting
    private func createS2(episodeStructure: [EpisodeSegment], audioEpisode: inout AudioEpisode) {
        
        // add new segment
        let segmentId = audioEpisode.addSegment()
        
        // in S2: music
        let introEndFile = Bundle.main.url(forResource: "02-intro-end-trimmed.caf", withExtension: nil)!
        audioEpisode.addAudioTrack(toSegmentId: segmentId, url: introEndFile)
    }
    
    /// Renders and Audio Episode and resturns its (local) URL
    func createAudioEpisode(basedOnEpisodeStructure episodeStructure: [EpisodeSegment]) -> URL {
        
        // create entrie episode
        var audioEpisode = AudioEpisode()
        
        createS0(episodeStructure: episodeStructure, audioEpisode: &audioEpisode)
        createS1(episodeStructure: episodeStructure, audioEpisode: &audioEpisode)
        createS2(episodeStructure: episodeStructure, audioEpisode: &audioEpisode)
        
//        // reference to recently created segment
//        var segmentId: Int
//
//        // add first segment S0
//        segmentId = audioEpisode.addSegment()
//
//        // in S0: music
//        let introStartFile = Bundle.main.url(forResource: "00-intro-start-trimmed.caf", withExtension: nil)!
//        audioEpisode.addAudioTrack(toSegmentId: segmentId, url: introStartFile)
//
//        for (_, episodeSegment) in episodeStructure.enumerated() {
//
//            // welcome text in S1
//            if episodeSegment.segmentIdentifer == .welcomeText {
//
//                // Start new segment S1: welcome
//                segmentId = audioEpisode.addSegment()
//
//                // add music
//                let backgroundMusicFile = Bundle.main.url(forResource: "01-intro-middle-trimmed.caf", withExtension: nil)!
//                audioEpisode.addAudioTrack(toSegmentId: segmentId, url: backgroundMusicFile, volume: 0.5, isLoopingBackgroundTrack: true)
//
//                // add speech
//                if let speechUrl = episodeSegment.audioURL {
//                    audioEpisode.addAudioTrack(toSegmentId: segmentId, url: speechUrl)
//                }
//
//
//            }
//
//            // headline intro added to S1
//            if episodeSegment.segmentIdentifer == .headlineIntroduction {
//                // add speech
//                if let speechUrl = episodeSegment.audioURL {
//                    audioEpisode.addAudioTrack(toSegmentId: segmentId, url: speechUrl)
//                }
//            }
//
//            // headlines added to S1
//            if episodeSegment.segmentIdentifer == .headline  {
//
//                // only use the headlines that should be highlighted in summary
//                if episodeSegment.highlightInSummary == true {
//                    // add speech
//                    if let speechUrl = episodeSegment.audioURL {
//                        audioEpisode.addAudioTrack(toSegmentId: segmentId, url: speechUrl)
//                    }
//                }
//            }
//
//            // intro end added to S2
//            if episodeSegment.segmentIdentifer == .headline  {
//
//                // only use the headlines that should be highlighted in summary
//                if episodeSegment.highlightInSummary == true {
//                    // add speech
//                    if let speechUrl = episodeSegment.audioURL {
//                        audioEpisode.addAudioTrack(toSegmentId: segmentId, url: speechUrl)
//                    }
//                }
//            }
//
//        }

        
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


