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
    
    //var audioData: Data?
    var audioPlayer: AVAudioPlayer?
    
    override init() {
        super.init()
    }
    
    func renderAudio(speakerName: String?, text: String?) async -> Data? {
        
        let speakerName = speakerName ?? "leila endruweit"
        let text = text ?? "Olá, hoje é quinta-feira, três de setembro de 2020."
        
        let audioData = await selmaAPI.renderAudio(speakerName: speakerName, text: text)
        
        var message = "Error while rendering audio on the server."
        if let data = audioData {
            message = "Data received: \(data.description)"
        }
        print(message)
        
        return audioData
    }
    
    
    private typealias AudioPlayerCheckedContinuation = CheckedContinuation<Void, Never>
    private var audioPlayerCheckedContinuation: AudioPlayerCheckedContinuation?
    
    func playAudio(audioData: Data) async {
        
        // in case that we have an outstanding checkedContinuationm, resume it
        audioPlayerCheckedContinuation?.resume()
        
        return await withCheckedContinuation({ continuation in
            
            audioPlayerCheckedContinuation = continuation
            
            do {
                audioPlayer = try AVAudioPlayer(data: audioData)
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
    }
    
}


