//
//  StoryEditView.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 08.08.22.
//

import SwiftUI

struct StoryEditView: View {
    
    var story: Story
    @State var headlineText: String
    @State var storyText: String
    @State var markAsHighlight: Bool
    
    @EnvironmentObject var episodeViewModel: EpisodeViewModel
    
    //@State private var path: [Story] = []
    
    init(story: Story) {
        self.story = story
        _headlineText = State(initialValue: story.headline)
        _storyText = State(initialValue: story.storyText)
        _markAsHighlight = State(initialValue: story.usedInIntroduction)
    }
    
    
    var body: some View {
        
        let headlineBinding = Binding {
            self.headlineText
        } set: { newValue in
            self.headlineText = newValue
            
            // update section in viewModel
            //episodeViewModel.updateEpisodeStory(storyId: story.id, newHeadline: headlineText)
        }

        let storyTextBinding = Binding {
            self.storyText
        } set: { newValue in
            self.storyText = newValue
            
            // update section in viewModel
            //episodeViewModel.updateEpisodeStory(storyId: story.id, newText: storyText)
        }
        
        let markAsHighlightBinding = Binding {
            self.markAsHighlight
        } set: { newValue in
            self.markAsHighlight = newValue
            
            // update section in viewModel
            //episodeViewModel.updateEpisodeStory(storyId: story.id, markAsHighlight: markAsHighlight)
        }
        
        Form {
            
            
            Section("Story headline") {
                TextField("Headline", text: headlineBinding, axis: .vertical)
                    .onSubmit {
                        // update section in viewModel
                        episodeViewModel.updateEpisodeStory(storyId: story.id, newHeadline: headlineText)
                    }
            }
            
            Section("Highlight") {
                Toggle("Highlight story", isOn: markAsHighlightBinding)
                    .onChange(of: markAsHighlight) { newValue in
                        // update section in viewModel
                        episodeViewModel.updateEpisodeStory(storyId: story.id, markAsHighlight: markAsHighlight)
                    }
            }
            
            Section("Story text") {
                TextField("Story", text: storyTextBinding, axis: .vertical)
                    .onSubmit {
                        // update section in viewModel
                        episodeViewModel.updateEpisodeStory(storyId: story.id, newText: storyText)
                    }
            }
            
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
