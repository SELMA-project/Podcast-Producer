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
    
    func createAudioEpisode() -> URL {
        
        // create entrie episode
        var audioEpisode = AudioEpisode()
        
        // reference to recently created segment
        var segmentId: Int
        
        // add first segment
        segmentId = audioEpisode.addSegment()
        let introStartFile = Bundle.main.url(forResource: "00-intro-start-trimmed.caf", withExtension: nil)!
        audioEpisode.addAudioTrack(toSegmentId: segmentId, url: introStartFile, volume: 1.0, delay: 0.0, fadeIn: 0.0, fadeOut: 0.0)

        // add second segment
        segmentId = audioEpisode.addSegment()
        
        // speech
        let speechFile = Bundle.main.url(forResource: "leilatest-CAF.caf", withExtension: nil)!
        audioEpisode.addAudioTrack(toSegmentId: segmentId, url: speechFile, volume: 1.0, delay: 0.0, fadeIn: 0.0, fadeOut: 0.0)

        // music
        let backgroundMusicFile = Bundle.main.url(forResource: "01-intro-middle-trimmed.caf", withExtension: nil)!
        audioEpisode.addAudioTrack(toSegmentId: segmentId, url: backgroundMusicFile, volume: 0.5, delay: 0.0, fadeIn: 0.0, fadeOut: 0.0)
        
        // render episode
        let url = audioEpisode.render(outputfileName: "output")
        
        return url
    }
    
    
    func createDownloadableAudio(audioUrl: URL) -> URL? {
        
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else {return nil}

        // speech audio file
        let speechSourceFile = avAudioFile(forResource: "leilatest", withExtension: "caf")
        let speechFormat = speechSourceFile.processingFormat
        print("fileFormat: \(speechSourceFile.fileFormat)")
        print("processingFormat: \(speechSourceFile.processingFormat)")
        
        // speech player
        let speechPlayer = AVAudioPlayerNode()
        speechPlayer.volume = 1.0
        
        // connect speech player to node
        audioEngine.attach(speechPlayer)
        audioEngine.connect(speechPlayer, to: audioEngine.mainMixerNode, format: speechFormat)
        
        
        // music audio file
        let musicSourceFile = avAudioFile(forResource: "intro-01-CAF", withExtension: "caf")
        let musicFormat = musicSourceFile.processingFormat
        
        // music player
        let musicPlayer = AVAudioPlayerNode()
        musicPlayer.volume = 0.5
        
        // connect speech player to node
        audioEngine.attach(musicPlayer)
        audioEngine.connect(musicPlayer, to: audioEngine.mainMixerNode, format: musicFormat)
        
    
        // Schedule the speech file.
        speechPlayer.scheduleFile(speechSourceFile, at: nil)
        
        // Schedule the music file.
        musicPlayer.scheduleFile(musicSourceFile, at: nil)
        
        
        do {
            // The maximum number of frames the engine renders in any single render call.
            let maxFrames: AVAudioFrameCount = 4096
            try audioEngine.enableManualRenderingMode(.offline, format: speechFormat,
                                                 maximumFrameCount: maxFrames)
        } catch {
            fatalError("Enabling manual rendering mode failed: \(error).")
        }

        
        do {
            try audioEngine.start()
            speechPlayer.play()
            musicPlayer.play()
        } catch {
            fatalError("Unable to start audio engine: \(error).")
        }
        
        // The output buffer to which the engine renders the processed data.
        let buffer = AVAudioPCMBuffer(pcmFormat: audioEngine.manualRenderingFormat,
                                      frameCapacity: audioEngine.manualRenderingMaximumFrameCount)!

        var outputFile: AVAudioFile
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let outputURL = documentsURL.appendingPathComponent("leila-processed.caf")
            outputFile = try AVAudioFile(forWriting: outputURL, settings: speechSourceFile.fileFormat.settings)
        } catch {
            fatalError("Unable to open output audio file: \(error).")
        }
        
        
        while audioEngine.manualRenderingSampleTime < speechSourceFile.length {
            do {
                let frameCount = speechSourceFile.length - audioEngine.manualRenderingSampleTime
                let framesToRender = min(AVAudioFrameCount(frameCount), buffer.frameCapacity)
                
                let status = try audioEngine.renderOffline(framesToRender, to: buffer)

//                // control music volume based on time
//                let timeInSec = Double(audioEngine.manualRenderingSampleTime)/speechFormat.sampleRate
//                if Int(timeInSec) % 2 == 0 {
//                    musicPlayer.volume = 0.3
//                } else {
//                    musicPlayer.volume = 1.0
//                }
//                print("\(timeInSec)")
                
                switch status {
                    
                case .success:
                    // The data rendered successfully. Write it to the output file.
                    try outputFile.write(from: buffer)
                    
                case .insufficientDataFromInputNode:
                    // Applicable only when using the input node as one of the sources.
                    break
                    
                case .cannotDoInCurrentContext:
                    // The engine couldn't render in the current render call.
                    // Retry in the next iteration.
                    break
                    
                case .error:
                    // An error occurred while rendering the audio.
                    fatalError("The manual rendering failed.")
                    
                @unknown default:
                    print("Unknown status case for audioEngine.renderOffline")
                }
            } catch {
                fatalError("The manual rendering failed: \(error).")
            }
        }

        // Stop the player node and engine.
        speechPlayer.stop()
        audioEngine.stop()
        
        // return URL
        return outputFile.url

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


