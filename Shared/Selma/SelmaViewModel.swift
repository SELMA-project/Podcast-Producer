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

class SelmaViewModel: ObservableObject {

    @Published var statusMessage: String = ""
    
    func testRender() async {

        let speakerName = "leila endruweit"
        let text = "Olá, hoje é quinta-feira, três de setembro de 2020."

        await renderAudio(speakerName: speakerName, text: text)
    }

    func renderAudio(speakerName: String, text: String) async {
        
        DispatchQueue.main.async {
            self.statusMessage = "Rendering audio..."
        }
        
        // path on server
        let path = "/x:selmaproject:tts:777:5002/api/tts"
        
        // query parameters
        let textQueryItem = URLQueryItem(name: "text", value: text)
        let speakerQueryItem = URLQueryItem(name: "speaker_id", value: speakerName)
        let queryItems = [textQueryItem, speakerQueryItem]
        
        // endpoint
        let uc0endPoint = UC0Endpoint(path: path, queryItems: queryItems)
        
        if let url = uc0endPoint.url {
              
              do {
                  let (data, _) = try await URLSession.shared.data(from: url)
                  let message = "Data received: \(data.description)"
                  DispatchQueue.main.async {
                      self.statusMessage = message
                      print(message)
                  }

              } catch {
                  print("Download error: \(error)")
              }
          }

    }
    
}



struct UC0Endpoint {
    
    let path: String
    let queryItems: [URLQueryItem]
    
    var url: URL? {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "87.110.211.231"
        components.port = 10100
        components.path = path
        components.queryItems = queryItems

        return components.url
    }
}
