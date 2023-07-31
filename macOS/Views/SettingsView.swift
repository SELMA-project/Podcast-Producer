//
//  SettingsView.swift
//  Podcast Creator (macOS)
//
//  Created by Andy Giefer on 21.04.23.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage(Constants.userDefaultsElevenLabsAPIKeyName) var elevenLabsAPIKey = ""
    @AppStorage(Constants.userDefaultsOpenAIAPIKeyName) var openAIAPIKey = ""
    @AppStorage(Constants.userDefaultsSummarizationPrompt) var summarizationPrompt = "You are a radio presenter for Deutsche Welle. Summarize the text in 2 sentences."
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Form {
                
                TextField("ElevenLabs API Key:", text: $elevenLabsAPIKey)
                
                TextField("OpenAI API Key:", text: $openAIAPIKey)
                
                TextField("Summarization Prompt:", text: $summarizationPrompt, axis: .vertical)
                    .lineLimit(4)
                
            }
            
            Spacer()
            
            
        }
        .padding(EdgeInsets(top: 40, leading: 80, bottom: 40, trailing: 40))
        .frame(width: 700, height: 200)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
