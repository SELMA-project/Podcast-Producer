//
//  ElevenLabsVoiceManager.swift
//  ElevenLabsVoice
//
//  Created by Andy on 12.03.23.
//

import Foundation


class ElevenLabsVoiceManager {
    
    let apiKey = "acae10e00ee6ec3f5ecc4f4c740b47cb"
    let apiVersion = "v1"
    
    /// Cache for all downloaded voices
    private var availableVoices: [Voice] = []
    
    // singleton
    static let shared = ElevenLabsVoiceManager()
    
    enum EndPoint {
        case voices
        case textToSpeech(voiceId: String, text: String, stability: Double, similarityBoost: Double)
        
        var value: String {
            switch self {
            case .voices:
                return "voices"
            case .textToSpeech(let voiceId, _, _ , _):
                return "text-to-speech/\(voiceId)"
            }
        }
    }
    
    struct VoiceQueryReply: Codable {
        var voices: [Voice]
    }
    
    // Andy's voiceId: abFX3QerypeGEFi0PDcz
    struct Voice: Codable {
        var voice_id: String
        var name: String
    }
}

// Public
extension ElevenLabsVoiceManager {
    
    func renderSpeech(voiceIdentifier: String, text: String, toURL fileURL: URL, stability: Double, similarityBoost: Double) async -> Bool {
        
        // early exit if the voice does not exist
        guard let voiceId = await voiceId(forName: voiceIdentifier) else {
            print("VoiceId \(voiceIdentifier) does not exist")
            return false
        }
        
        print("Id for name \(voiceIdentifier): \(voiceId)")

        // create TTS endpoint
        let endPoint = EndPoint.textToSpeech(voiceId: voiceId, text: text, stability: stability, similarityBoost: similarityBoost)
        
        // convert to request
        let urlRequest = urlRequest(forEndPoint: endPoint)
        
        // defualt reult: fail
        var success = false
        
        // download audio
        if let voiceData = await downloadData(forUrlRequest: urlRequest) {
            
            do {
                try voiceData.write(to: fileURL, options: .atomic)
                success = true
            } catch {
                print(error)
            }
        }
        
        return success
    }
    
    
}


// Everything with voices
extension ElevenLabsVoiceManager {
    
    private func voiceId(forName name: String) async -> String? {
        
        // download the voices if we haven't done so yet
        if availableVoices.count == 0 {
            self.availableVoices = await downloadVoices()
        }
        
        // return the id for given name (if there is a match)
        if let voice = self.availableVoices.first(where: {$0.name == name}) {
            return voice.voice_id
        }
        
        // fallback - no match
        return nil
    }
    
    private func downloadVoices() async -> [Voice] {
        
        print("Downloading voices")
        
        // generate request
        let urlRequest = urlRequest(forEndPoint: .voices)
        
        // download
        if let data = await downloadData(forUrlRequest:urlRequest) {
            
            do {
                // decode JSON
                let voiceQueryReply = try JSONDecoder().decode(VoiceQueryReply.self, from: data)
                let voices = voiceQueryReply.voices
                return voices
            } catch {
                print(error)
            }
        }

        // fallback - no voices
        return []
    }
    
}

// Downloading files
extension ElevenLabsVoiceManager {
    
    private func urlForEndPoint(_ endPoint: EndPoint) -> URL {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.elevenlabs.io"
        components.path = "/\(apiVersion)/\(endPoint.value)"
        
        return components.url!
    }
    
    private func urlRequest(forEndPoint endPoint: EndPoint) -> URLRequest {
        
        // create URL
        let url = urlForEndPoint(endPoint)
        
        // start request
        var request = URLRequest(url: url)

        // -H 'xi-api-key: acae10e00ee6ec3f5ecc4f4c740b47cb'
        request.setValue(
            apiKey,
            forHTTPHeaderField: "xi-api-key"
        )
        
        switch endPoint {
        case .voices:
            
            // -H 'accept: application/json' \
            request.setValue(
                "application/json",
                forHTTPHeaderField: "accept"
            )
            
        case .textToSpeech( _, let text, let stability, let similarityBoost):
            
            // -H 'accept: audio/mpeg' \
            request.setValue(
                "audio/mpeg",
                forHTTPHeaderField: "accept"
            )
            
            // -H 'Content-Type: application/json'
            request.setValue(
                "application/json",
                forHTTPHeaderField: "Content-Type"
            )
            
            // Serialize HTTP Body data as JSON
            let body: [String: Any] = ["text": text,
                                       "voice_settings": [
                                        "stability": stability,
                                        "similarity_boost": similarityBoost
                                       ]
            ]
            
            let bodyData = try? JSONSerialization.data(
                withJSONObject: body,
                options: []
            )

            // Change the URLRequest to a POST request
            request.httpMethod = "POST"
            request.httpBody = bodyData
        }
                
        return request
    }
    
    private func downloadData(forUrlRequest urlRequest: URLRequest) async -> Data? {
        
        var data: Data?
        
        do {
            let (returnedData, _) = try await URLSession.shared.data(for: urlRequest)
            data = returnedData
        } catch {
            print(error)
        }
        
        return data
    }

}
