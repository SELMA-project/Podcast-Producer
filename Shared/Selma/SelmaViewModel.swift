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

@MainActor
class SelmaViewModel: ObservableObject {
    
    @Published var statusMessage: String = ""
    
    var audioData: Data?
    var audioPlayer: AVAudioPlayer?
    
    func testRender() async {
        
        let speakerName = "leila endruweit"
        let text = "Olá, hoje é quinta-feira, três de setembro de 2020."
        
        self.statusMessage = "Rendering audio..."
        
        audioData = await SelmaAPI.shared.renderAudio(speakerName: speakerName, text: text)
        
        var message = "Error while rendering audio on the server."
        if let data = audioData {
            message = "Data received: \(data.description)"
        }
        
        self.statusMessage = message
    }
    
    func playAudio() {
        
        guard let audioData = self.audioData else {return}

        do {
            audioPlayer = try AVAudioPlayer(data: audioData)
            audioPlayer?.play()
        } catch {
            self.statusMessage = "Could not play audio."
        }
        
    }
    
}


