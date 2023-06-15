////
////  SelmaAPI.swift
////  Podcast Producer
////
////  Created by Andy Giefer on 16.08.22.
////
//
//import Foundation
//
//class SelmaAPI {
//        
//    func renderAudio(voiceApiName: String, text: String, toURL fileURL: URL) async -> Bool {
//        
//        // the return value: success
//        var success = false
//        
//        // path on server
//        //let path = "/x:selmaproject:tts:777:5002/api/tts" // v1
//        let path = "/x:selmaproject:selma-tts-avignon:pt_br-v2:5002/api/tts" // v2
//
//    
//        
//        // query parameters
//        let textQueryItem = URLQueryItem(name: "text", value: text)
//        let speakerQueryItem = URLQueryItem(name: "speaker_id", value: voiceApiName)
//        let queryItems = [textQueryItem, speakerQueryItem]
//        
//        // endpoint
//        let uc0endPoint = UC0Endpoint(path: path, queryItems: queryItems)
//        
//        // store data here
//        var data: Data?
//        
//        if let url = uc0endPoint.url {
//            
//            //print("TTS URL: \(url.absoluteString)")
//            
//            do {
//                (data, _) = try await URLSession.shared.data(from: url)
//            } catch {
//                print("Download error.")
//            }
//        }
//        
//        // store in file URL
//        if let data {
//            do {
//                try data.write(to: fileURL)
//                success = true
//            } catch {
//                print("Error writing audio to file with URL: \(fileURL)")
//            }
//        } else {
//            print("Error while rendering audio on the server.")
//        }
//        
//        return success
//    }
//    
//    static func testRender()  {
//        
//        let speakerName = "leila endruweit"
//        //let text = "Olá, hoje é quarta-feira, vinte e um de setembro de dois mil e vinte e dois. Eu sou Leila Endruweit"
//        let text = "Setembro."
//        
//        let selmaApi = SelmaAPI()
//        
//        let testURL = FileManager.default.temporaryDirectory.appending(path: "test.wav")
//        
//        Task {
//            let success = await selmaApi.renderAudio(voiceApiName: speakerName, text: text, toURL: testURL)
//            
//            if success {
//                print("Wrote test speech to: \(testURL.absoluteString)")
//            } else {
//                print("Error. Could not write test speech to: \(testURL.absoluteString)")
//            }
//        }
//        
//    }
//}
//
//struct UC0Endpoint {
//    
//    let path: String
//    let queryItems: [URLQueryItem]
//    
//    var url: URL? {
//        var components = URLComponents()
//        components.scheme = "http"
//        components.host = "87.110.211.231"
//        components.port = 10100
//        components.path = path
//        components.queryItems = queryItems
//        
//        return components.url
//    }
//}
//
