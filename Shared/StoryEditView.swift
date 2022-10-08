//
//  StoryEditView.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 08.08.22.
//

import SwiftUI

struct StoryEditView: View {
    
    var story: Story
    @State var headline: String
    
    @EnvironmentObject var episodeViewModel: EpisodeViewModel
    
    //@State private var path: [Story] = []
    
    init(story: Story) {
        self.story = story
        _headline = State(initialValue: story.headline)
    }
    
    
    var body: some View {
        
        Form {
            Section("Story headline") {
                TextField("Headline", text: $headline, axis: .vertical)
            }
            
            //            Section("Story text") {
            //                TextField("Story text", text: $episode.stories[storyNumber].storyText, axis: .vertical)
            //                    //.lineLimit(10)
            //            }
        }
        .navigationTitle("Story Editor")
        
    }
}

struct StoryEditView_Previews: PreviewProvider {
    static var previews: some View {
        let story = Story(usedInIntroduction: true, headline: "Headline", storyText: "Text")
        StoryEditView(story: story)
    }
}
