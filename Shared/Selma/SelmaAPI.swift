//
//  SelmaAPI.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 16.08.22.
//

import Foundation

class SelmaAPI {
        
    func renderAudio(speakerName: String, text: String) async -> Data? {
        
        // path on server
        let path = "/x:selmaproject:tts:777:5002/api/tts"
        
        // query parameters
        let textQueryItem = URLQueryItem(name: "text", value: text)
        let speakerQueryItem = URLQueryItem(name: "speaker_id", value: speakerName)
        let queryItems = [textQueryItem, speakerQueryItem]
        
        // endpoint
        let uc0endPoint = UC0Endpoint(path: path, queryItems: queryItems)
        
        // result
        var data: Data?
        
        if let url = uc0endPoint.url {
            
            //print("TTS URL: \(url.absoluteString)")
            
            do {
                (data, _) = try await URLSession.shared.data(from: url)
            } catch {
                print("Download error.")
            }
        }
        
        return data
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
