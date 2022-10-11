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
    
    @EnvironmentObject var episodeViewModel: EpisodeViewModel
    
    //@State private var path: [Story] = []
    
    init(story: Story) {
        self.story = story
        _headlineText = State(initialValue: story.headline)
        _storyText = State(initialValue: story.storyText)
    }
    
    
    var body: some View {
        
        let headlineBinding = Binding {
            self.headlineText
        } set: { newValue in
            self.headlineText = newValue
            
            // update section in viewModel
            episodeViewModel.updateEpisodeStory(storyId: story.id, newHeadline: headlineText)
        }

        let storyTextBinding = Binding {
            self.storyText
        } set: { newValue in
            self.storyText = newValue
            
            // update section in viewModel
            episodeViewModel.updateEpisodeStory(storyId: story.id, newText: storyText)
        }
        
        Form {
            Section("Story headline") {
                TextField("Headline", text: headlineBinding, axis: .vertical)
            }

            Section("Story text") {
                TextField("Story", text: storyTextBinding, axis: .vertical)
            }
            
        }
        .navigationTitle("Story Editor")
        
    }
}

//struct StoryEditViewOld: View {
//    
//    var story: Story
//    @State var headline: String
//    
//    @EnvironmentObject var episodeViewModel: EpisodeViewModel
//    
//    //@State private var path: [Story] = []
//    
//    init(story: Story) {
//        self.story = story
//        _headline = State(initialValue: story.headline)
//    }
//    
//    
//    var body: some View {
//        
//        Form {
//            Section("Story headline") {
//                TextField("Headline", text: $headline, axis: .vertical)
//            }
//            
////            Section("Story text") {
////                TextField("Story text", text: $episode.stories[storyNumber].storyText, axis: .vertical)
////                //.lineLimit(10)
////            }
//        }
//        .navigationTitle("Story Editor")
//        
//    }
//}

struct StoryEditView_Previews: PreviewProvider {
    static var previews: some View {
        let story = Story(usedInIntroduction: true, headline: "Headline", storyText: "Text")
        StoryEditView(story: story)
    }
}
