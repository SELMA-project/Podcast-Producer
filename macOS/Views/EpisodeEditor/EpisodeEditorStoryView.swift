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
                    
                        Text("Text").font(.title2).padding(.top)
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
