//
//  StoryEditView.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 08.08.22.
//

import SwiftUI

struct StoryEditView: View {

    @ObservedObject var episodeViewModel: EpisodeViewModel
    var storyNumber: Int = 0
        
    var body: some View {
//        Form {
//            Section("Story headline") {
//                TextField("Headline", text: $episode.stories[storyNumber].headline, axis: .vertical)
//            }
//
//            Section("Story text") {
//                TextField("Story text", text: $episode.stories[storyNumber].storyText, axis: .vertical)
//                    //.lineLimit(10)
//            }
//        }
        
            VStack(alignment: .leading) {
                Text("Story headline")
                    .font(.headline)
                //TextEditor(text: $episode.stories[storyNumber].headline)
                TextField("Headline", text: $episodeViewModel.availableEpisodes[episodeViewModel.chosenEpisodeIndex].stories[storyNumber].headline, axis: .vertical)
                
                Text("Story text")
                    .font(.headline)
                TextEditor(text: $episodeViewModel.availableEpisodes[episodeViewModel.chosenEpisodeIndex].stories[storyNumber].storyText)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Story Editor")
        
        
    }
}

struct StoryEditView_Previews: PreviewProvider {
    static var previews: some View {
        StoryEditView(episodeViewModel: EpisodeViewModel())
    }
}
