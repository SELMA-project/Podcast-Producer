//
//  ElevenLabsVoiceManager.swift
//  ElevenLabsVoice
//
//  Created by Andy on 12.03.23.
//

import Foundation


class ElevenLabsVoiceManager {
    
    let apiKey: String
    let apiVersion = "v1"
    let elevenLabsModelId: ElevenLabsModelID
    /// Cache for all downloaded voices
    private var availableVoices: [NativeVoice] = []

    /// Cache of all downloaded models
    private var availableModels: [ModelQueryReply] = []
    
    enum ElevenLabsModelID {
        case monolingualV1, multilingualV1
        
        var stringValue: String {
            switch self {
            case .monolingualV1:
                return "eleven_monolingual_v1"
            case .multilingualV1:
                return "eleven_multilingual_v1"
            }
        }
    }
    
    /// Initializes the ElevenLabs voice manager.
    /// - Parameters:
    ///   - apiKey: The API key to use.
    init(apiKey: String, elevenLabsModelId: ElevenLabsModelID) {
        self.apiKey = apiKey
        self.elevenLabsModelId = elevenLabsModelId
    }
        
    enum EndPoint {
        case models
        case voices
        case textToSpeech(voiceId: String, text: String, modelId: String, stability: Double, similarityBoost: Double)
        
        var value: String {
            switch self {
            case .models:
                return "models"
            case .voices:
                return "voices"
            case .textToSpeech(let voiceId, _, _ , _, _):
                return "text-to-speech/\(voiceId)"
            }
        }
    }

    

}

// Public
extension ElevenLabsVoiceManager {
    
    func renderSpeech(voiceName: String, text: String, toURL fileURL: URL, stability: Double, similarityBoost: Double) async -> Bool {
        
        // early exit if the voice does not exist
        guard let voiceId = await voiceId(forName: voiceName) else {
            print("VoiceId \(voiceName) does not exist")
            return false
        }
        
        print("Id for name \(voiceName): \(voiceId)")
        
        // create TTS endpoint
        let endPoint = EndPoint.textToSpeech(voiceId: voiceId, text: text, modelId: self.elevenLabsModelId.stringValue, stability: stability, similarityBoost: similarityBoost)
        
        // convert to request
        let urlRequest = urlRequest(forEndPoint: endPoint)
        
        // defualt result: fail
        var success = false
        
        // download audio
        if let voiceData = await downloadData(forUrlRequest: urlRequest) {
            
            //print(String(data: voiceData, encoding: .utf8) ?? "")
            
            do {
                try voiceData.write(to: fileURL, options: .atomic)
                success = true
            } catch {
                print(error)
            }
        }
        
        return success
    }
    
    /// Downloads an array of available ElevenLabs Voices and returns it.
    /// - Returns: An array of available ElevenLabs Voices.
    func nativeVoices() async -> [NativeVoice] {
        
        // download the voices if we haven't done so yet
        if availableVoices.count == 0 {
            availableVoices = await downloadVoices()
        }
        
        return availableVoices
    }
    
    func supportedLocales() async -> [Locale] {
        
        var result = [Locale]()
        
        // get models if not yet downloaded
        if availableModels.count == 0 {
            availableModels = await downloadModels()
        }
        
        // get multilingual one
        if let multiLingualModel = availableModels.first(where: { $0.modelId == elevenLabsModelId.stringValue}) {
            
            for elevenLabsLanguage in multiLingualModel.languages {
                result.append(elevenLabsLanguage.locale)
            }
        }
        
        return result
    }
    
    
}


// MARK: Everything with models
extension ElevenLabsVoiceManager {
    
    struct ModelQueryReply: Codable {
        var modelId: String
        var languages: [ElevenLabsLanguage]
        
        enum CodingKeys: String, CodingKey {
            case modelId = "model_id"
            case languages
        }
    }
    
    struct ElevenLabsLanguage: Codable {
        var languageId: String
        var name: String
        
        enum CodingKeys: String, CodingKey {
            case languageId = "language_id"
            case name
        }
        
        var locale: Locale {
            // default: no country code
            var result = Locale(identifier: self.languageId)
            
            // overwrite to add country code if only language is specified
            if languageId == "de" {result = Locale(identifier: "de-DE")}
            if languageId == "pl" {result = Locale(identifier: "pl-PL")}
            if languageId == "es" {result = Locale(identifier: "es-ES")}
            if languageId == "fr" {result = Locale(identifier: "fr-FR")}
            if languageId == "it" {result = Locale(identifier: "it-IT")}
            if languageId == "pt" {result = Locale(identifier: "pt-PT")}
            if languageId == "hi" {result = Locale(identifier: "hi-IN")}
            
            return result
        }
    }
    
    private func downloadModels() async -> [ModelQueryReply]{
        
        print("Downloading models")
        
        // generate request
        let urlRequest = urlRequest(forEndPoint: .models)
        
        // download
        if let data = await downloadData(forUrlRequest:urlRequest) {
            
            do {
                
                let jsonString = String(data: data, encoding: .utf8)
                print(jsonString ?? "")
                
                // decode JSON
                let models = try JSONDecoder().decode([ModelQueryReply].self, from: data)
                                
                return models
                
            } catch {
                print(error)
            }
        }

        // fallback - no models
        return []
    }
}


// MARK: Everything with voices
extension ElevenLabsVoiceManager {
    
    
    struct VoiceQueryReply: Codable {
        var voices: [NativeVoice]
    }
    
    // Andy's voiceId: abFX3QerypeGEFi0PDcz
    struct NativeVoice: Codable {
        var voiceId: String
        var name: String
        var category: String // premade
        var labels: Labels
        
        enum CodingKeys: String, CodingKey {
            case voiceId = "voice_id"
            case name, category, labels
        }
    }
    /*
     \"labels\":{\"accent\":\"american\",\"description\":\"soft\",\"age\":\"young\",\"gender\":\"female\",\"use case\":\"narration\"}
     */
    struct Labels: Codable {
        var accent: String?
        var description: String?
        var age: String?
        var gender: String?
        var useCase: String?
        
        enum CodingKeys: String, CodingKey {
            case useCase = "use case"
            case accent, description, age, gender
        }
    }
    
    private func voiceId(forName name: String) async -> String? {
        
        // download the voices if we haven't done so yet
        if availableVoices.count == 0 {
            self.availableVoices = await downloadVoices()
        }
        
        // return the id for given name (if there is a match)
        if let voice = self.availableVoices.first(where: {$0.name == name}) {
            return voice.voiceId
        }
        
        // fallback - no match
        return nil
    }
    
    private func downloadVoices() async -> [NativeVoice] {
        
        print("Downloading voices")
        
        // generate request
        let urlRequest = urlRequest(forEndPoint: .voices)
        
        // download
        if let data = await downloadData(forUrlRequest:urlRequest) {
            
            //print(String(data: data, encoding: .utf8)!)
            
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
            
        case .models:
            
            // -H 'accept: application/json' \
            request.setValue(
                "application/json",
                forHTTPHeaderField: "accept"
            )
        case .textToSpeech( _, let text, let modelId, let stability, let similarityBoost):
            
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
                                       "model_id": modelId,
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
