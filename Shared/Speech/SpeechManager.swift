//
//  SpeechManager.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 19.10.22.
//

import AVFoundation
import Foundation

class SpeechManager {
        
    let synthesizer: AVSpeechSynthesizer
    var player: AVAudioPlayer?
    
    // singleton
    static var shared = SpeechManager()
    
    init() {
        let synthesizer = AVSpeechSynthesizer()
        self.synthesizer = synthesizer
    }
    
    var recordingPath:  URL {
        let soundName = "Finally.caf"
        
        // Local Directory
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(soundName)
    }
    
    func speakPhrase(phrase: String) {
        let utterance = AVSpeechUtterance(string: phrase)
        utterance.voice = AVSpeechSynthesisVoice(language: "en")
        synthesizer.speak(utterance)
    }
    
    func printSpeechVoices() {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        for voice in voices {
            print(voice)
        }
    }
    
    func playFile() {
        print("Trying to play the file")
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: recordingPath, fileTypeHint: AVFileType.caf.rawValue)
            guard let player = player else {return}
            
            player.play()
        } catch {
            print("Error playing file.")
        }
    }
    
    func renderAppleSpeech(voiceIdentifier: String, text: String, toURL fileURL: URL) async -> Bool {
        
        await withCheckedContinuation { continuation in
            
            var success = false
        
            print("Rendering speech with voice: \(voiceIdentifier)")
            
            // create utterance
            let utterance = AVSpeechUtterance(string: text)
            //utterance.rate = 0.50
            
            // associate voice
            let voice = AVSpeechSynthesisVoice(identifier: voiceIdentifier)
            utterance.voice = voice

//            if let voice {
//                print("Voice settings: \(voice.audioFileSettings)")
//            }
            
            // Only create new file handle if `output` is nil.
            var output: AVAudioFile?
            
            self.synthesizer.write(utterance) {(buffer: AVAudioBuffer) in
                guard let pcmBuffer = buffer as? AVAudioPCMBuffer else {
                    fatalError("unknown buffer type: \(buffer)")
                }
                if pcmBuffer.frameLength == 0 {
                    // Done
                    
                    if output != nil {
                        // here, we know that we have been successful
                        success = true
                        
                        //print("Sucessfully rendered: '\(text)' to \(fileURL)")
                    }
                    
                    // set output AVAudioFile to nil to close it
                    output = nil
                    
                    continuation.resume(returning: success)
                    
                } else {
                    
                    do{
                        // this closure is called multiple times. so to save a complete audio, try create a file only for once.
                        if output == nil {
                            try  output = AVAudioFile(
                                forWriting: fileURL,
                                settings: pcmBuffer.format.settings,
                                commonFormat: .pcmFormatInt16,
                                interleaved: false)
                            
                            //print("pcmBuffer settings: \(pcmBuffer.format.settings)")
                        }
                        try output?.write(from: pcmBuffer)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                
            }
        }
    }
    
    func saveAVSpeechUtteranceToFile() async -> URL?  {
        
        await withCheckedContinuation { continuation in
            
            let utterance = AVSpeechUtterance(string: "This is speech to record")
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = 0.50
            
            // Only create new file handle if `output` is nil.
            var output: AVAudioFile?
            
            self.synthesizer.write(utterance) { [self] (buffer: AVAudioBuffer) in
                guard let pcmBuffer = buffer as? AVAudioPCMBuffer else {
                    fatalError("unknown buffer type: \(buffer)")
                }
                if pcmBuffer.frameLength == 0 {
                    // Done
                    
                    var outputUrl: URL? = nil
                    
                    if output != nil {
                        outputUrl = recordingPath
                    }
                    continuation.resume(returning: outputUrl)
                } else {
                    
                    do{
                        // this closure is called multiple times. so to save a complete audio, try create a file only for once.
                        if output == nil {
                            try  output = AVAudioFile(
                                forWriting: recordingPath,
                                settings: pcmBuffer.format.settings,
                                commonFormat: .pcmFormatInt16,
                                interleaved: false)
                        }
                        try output?.write(from: pcmBuffer)
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                }
                
            }
            
        }
    }
    
}
