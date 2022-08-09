//
//  StoryEditView.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 08.08.22.
//

import SwiftUI

struct StoryEditView: View {
    
    var storyNumber: Int = 1
    
    @EnvironmentObject var episodeViewModel: EpisodeViewModel
        
    var body: some View {
        
        Section("Story headline") {
            TextField("Headline", text: $episodeViewModel.chosenEpisode.stories[storyNumber].headline)
        }
        
        Section("Story text") {
            TextField("Story text", text: $episodeViewModel.chosenEpisode.stories[storyNumber].storyText, axis: .vertical)
                .lineLimit(10)
        }

        
    }
}

struct StoryEditView_Previews: PreviewProvider {
    static var previews: some View {
        StoryEditView()
    }
}
