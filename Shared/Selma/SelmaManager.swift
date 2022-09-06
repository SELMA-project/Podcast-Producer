//
//  SelmaAPI.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 15.08.22.
//

import Foundation


//def doTTS(text, filename):
//
//    startTime = time.perf_counter()
//
//    #text = "Olá, hoje é quinta-feira, três de setembro de 2020."
//    speaker = "leila endruweit"
//    ip = "87.110.211.231" # "194.57.216.166"
//    port = "10100" #"80"
//
//    #api_url = f"http://{ip}:{port}/api/tts?text={urllib.parse.quote(text)}&speaker_id={urllib.parse.quote(speaker)}"
//    #api_url = f"http://{ip}:{port}/tts/api/tts?text={urllib.parse.quote(text)}&speaker_id={urllib.parse.quote(speaker)}"
//    api_url = f"http://{ip}:{port}/x:selmaproject:tts:777:5002/api/tts?text={urllib.parse.quote(text)}&speaker_id={urllib.parse.quote(speaker)}"
//
//    print(api_url)
//
//    req = requests.get(api_url)
//
//    with open(f"{filename}.wav",'wb') as f:
//        f.write(req.content)
//
//    endTime = time.perf_counter()
//
//    return endTime - startTime

import AVFoundation


class SelmaManager: NSObject, AVAudioPlayerDelegate {
    
    // singleton
    static var shared = SelmaManager()
    
    // Selma API
    let selmaAPI = SelmaAPI()
    
    var audioPlayer: AVAudioPlayer?
    var audioEngine: AVAudioEngine?
    
    override init() {
        super.init()
    }
    
    func renderAudio(speakerName: String?, text: String?, toURL fileURL: URL) async -> Bool {
        
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
    
    func createDownloadableAudio(audioUrl: URL) -> URL? {
        
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else {return nil}

        // speech audio file
        let speechSourceFile = avAudioFile(forResource: "leilatest", withExtension: "caf")
        let speechFormat = speechSourceFile.processingFormat
        
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
    
}


