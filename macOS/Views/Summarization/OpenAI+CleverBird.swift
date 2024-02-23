//
//  OpenAI+CleverBird.swift
//  SelmaKitWrapper
//
//  Created by Andy Giefer on 28.07.23.
//

import Foundation
import CleverBird


class CleverBirdManager {
    
    var openAIAPIConnection: OpenAIAPIConnection?
    
    init(key: String?) {
        
        // is key, with fallback from environment if no key is provided
        //let keyToUse = key ?? ProcessInfo.processInfo.environment["OPENAI_API_KEY"]
        
        if let key {
            openAIAPIConnection = OpenAIAPIConnection(apiKey: key) // <OPENAI_API_KEY>
        }
    }
    
    func summarize(prompt: String, context: String, temperature: Double = 0.5, maxTokens: Int = 300) async -> String? {

        var resultText: String?
        
        // early exit if no connection exists
        if let openAIAPIConnection = self.openAIAPIConnection {
            
            let chatThread = ChatThread()
                .addSystemMessage(prompt)
                .addUserMessage(context)
            
            do {
                
                let completion = try await chatThread.complete(
                    using: openAIAPIConnection,
                    model: .gpt35Turbo,
                    temperature: Percentage(floatLiteral: temperature),
                    maxTokens: maxTokens
                )
                
                resultText = completion.content ?? "<OpenAI returned an empty response>"
                
            } catch {
                print(error.localizedDescription)
                print(error)
            }
        }
        
        return resultText
    }
}
