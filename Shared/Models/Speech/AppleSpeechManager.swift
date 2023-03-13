//
//  AppleSpeechManager.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 19.10.22.
//

import AVFoundation
import Foundation

class AppleSpeechManager {
        
    let synthesizer: AVSpeechSynthesizer
    var player: AVAudioPlayer?
    
    // singleton
    static var shared = AppleSpeechManager()
    
    init() {
        let synthesizer = AVSpeechSynthesizer()
        self.synthesizer = synthesizer
    }
    
    // Uses voice with given identifier to render text to speech stored in a file URL
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
}
