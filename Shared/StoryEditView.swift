//
//  StoryEditView.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 08.08.22.
//

import SwiftUI

struct StoryEditView: View {
    
    @Binding var episode: Episode
    var storyNumber: Int = 0
        
    var body: some View {

        Section("Story headline") {
            TextField("Headline", text: $episode.stories[storyNumber].headline)
        }
        
        Section("Story text") {
            TextField("Story text", text: $episode.stories[storyNumber].storyText, axis: .vertical)
                .lineLimit(10)
        }        
    }
}

struct StoryEditView_Previews: PreviewProvider {
    static var previews: some View {
        StoryEditView(episode: .constant(Episode.episode0))
    }
}
