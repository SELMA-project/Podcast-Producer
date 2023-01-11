//
//  StoryListView.swift
//  Podcast Creator
//
//  Created by Andy Giefer on 11.01.23.
//

import SwiftUI

struct StoryListView: View {
    
    @EnvironmentObject var viewModel: EpisodeViewModel
    
    var stories: [Story] {
        return viewModel.chosenEpisode.stories
    }
    
    var body: some View {
                    
        Form {
            Section("Stories") {
                ForEach(stories) {story in
                    NavigationLink(value: story) {
                        Text(story.headline)
                    }
                }
            }
            
        }
        .navigationDestination(for: Story.self) { story in
            StoryEditView(story: story)
        }
        
        .navigationTitle("Stories")

    }
}

struct StoryListView_Previews: PreviewProvider {
    static var previews: some View {
        StoryListView()
    }
}
