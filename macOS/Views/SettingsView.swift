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
    @AppStorage(Constants.userDefaultsPriberamAPIKeyName) var priberamAPIKey = ""

    @AppStorage(Constants.userDefaultsSummarizationPrompt) var summarizationPrompt = "You are a radio presenter for Deutsche Welle. Summarize the text in 2 sentences."
    
    @AppStorage(Constants.userDefaultsChatTemperature) var temperature: Double = 0.5
    @AppStorage(Constants.userDefaultsMaxNumberOfTokens) var maxNumberOfTokens: Int = 400
    @AppStorage(Constants.userDefaultsSelectedEngine) var selectedEngine: SummarisationEngine = .openAI
    
    let tokenNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    

    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Form {
                
                TextField("ElevenLabs API Key:", text: $elevenLabsAPIKey)
                Text("Required to use ElevenLabs voices.")
                    .font(.caption)
                
                TextField("OpenAI API Key:", text: $openAIAPIKey)
                Text("Required to use ChatGPT summarization.")
                    .font(.caption)
                
                
                TextField("Priberam API Key:", text: $priberamAPIKey)
                Text("Required to use Google and Azure voices.")
                    .font(.caption)
                    .padding(.bottom, 8)

                
                Text("Please restart the app after settings the API Key.")
                    .padding(.bottom, 20)
                
                // Engine
                Picker("Summarization Engine:", selection: $selectedEngine) {
                    ForEach(SummarisationEngine.allCases) { engine in
                        Text(engine.displayName).tag(engine)
                    }
                }
                
                TextField("Maximum number of Tokens:", value: $maxNumberOfTokens, formatter: tokenNumberFormatter)


                LabeledContent {
                    //Slider(value: $temperature, in: 0...1, step: 0.1)
                    Slider(value: $temperature, in: 0...1, step: 0.1) {
                        
                    } minimumValueLabel: {
                        Text("0.0")
                    } maximumValueLabel: {
                        Text("1.0")
                    }

                } label: {
                    Text("Temperature:")
                }
                
                
                if selectedEngine != .priberam {
                    
                    TextField("Summarization Prompt:", text: $summarizationPrompt, axis: .vertical)
                        .lineLimit(4)
                }
                
            }
            
            Spacer()
            
            
        }
        .padding(EdgeInsets(top: 40, leading: 80, bottom: 40, trailing: 40))
        .frame(width: 700, height: 400)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
