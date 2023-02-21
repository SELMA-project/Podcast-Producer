//
//  StoryEditView.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 08.08.22.
//

import SwiftUI

struct StoryEditView: View {
    
    @Binding var story: Story
    
    @EnvironmentObject var episodeViewModel: EpisodeViewModel
    
    var body: some View {
        
        Form {
            
            
            Section("Story headline") {
                TextField("Headline", text: $story.headline, axis: .vertical)
            }
            
            Section("Highlight") {
                Toggle("Highlight story", isOn: $story.usedInIntroduction)
            }
            
            Section("Story text") {
                TextField("Story", text: $story.storyText, axis: .vertical)
            }
            
        }

        .navigationTitle("Story Editor")
        
    }
}


struct StoryEditView_Previews: PreviewProvider {
    static var previews: some View {
        let story = Story(usedInIntroduction: true, headline: "Headline", storyText: "Text")
        StoryEditView(story: .constant(story))
    }
}
