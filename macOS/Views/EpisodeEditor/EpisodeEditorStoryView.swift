//
//  EpisodeEditorStoryView.swift
//  Podcast Creator (macOS)
//
//  Created by Andy Giefer on 28.02.23.
//

import SwiftUI

struct EpisodeEditorStoryView: View {
    
    @Binding var story: Story

    @EnvironmentObject var episodeViewModel: EpisodeViewModel
    
    /// Gets called when 'Summarize button is pressed.
    private func summarize() {
        
        // read select engine from user defaults
        guard let selectedEngineString = UserDefaults.standard.string(forKey: Constants.userDefaultsSelectedEngine) else {return}
        guard let selectedEngine = SummarisationEngine(rawValue: selectedEngineString) else {return}
        
        // read maxNumberOfTokens defaults
        let maxNumberOfTokens = UserDefaults.standard.integer(forKey: Constants.userDefaultsMaxNumberOfTokens)

        // read temperature defaults
        let temperature = UserDefaults.standard.double(forKey: Constants.userDefaultsChatTemperature)

        // read temperature defaults
        guard let summarizationPrompt = UserDefaults.standard.string(forKey: Constants.userDefaultsSummarizationPrompt) else {return}
        
        switch selectedEngine {
        case .titleAndTeaser:
            summarizeUsingTitleAndTeaser()
        case .alpaca:
            break
        case .openAI:
            break
        }
    }
    
    /// Summarizes the story by reducing it to the first two paragraphs.
    private func summarizeUsingTitleAndTeaser() {
        
        // split into paragraphs
        let paragraphs = story.storyText.split(separator: "\n")
        
        // use the first two non-empty paragraphs
        // these are the headline and the teaser text
        let numberOfParagraphs = min(2, paragraphs.count)
        story.storyText = String(paragraphs[0..<numberOfParagraphs].joined(separator: "\n\n"))
    }
    
    var body: some View {
        GroupBox {

            ZStack {
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Headline").font(.title2)
                            Spacer()
                            Toggle("Highlight story", isOn: $story.usedInIntroduction)
                        }
                        TextField("Title", text: $story.headline, prompt: Text("Story Headline"), axis: .vertical)
                            .font(.title3)
                    
                        HStack {
                            Text("Text").font(.title2)
                            Spacer()
                            Button("Summarize") {
                                summarize()
                            }
                        }.padding(.top)
                        
                        TextEditor(text: $story.storyText).font(.title3)
                    }
                    .padding()
                    
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct EpisodeEditorStoryView_Previews: PreviewProvider {
    static var previews: some View {
        
        EpisodeEditorStoryView(story: .constant(Story.mockup))
            .padding()
    }
}
