//
//  EpisodeEditorStoriesListView.swift
//  Podcast Creator (macOS)
//
//  Created by Andy Giefer on 28.02.23.
//

import SwiftUI

struct EpisodeEditorStoriesListView: View {
    
    var chosenEpisodeId: UUID
    @Binding var chosenStoryId: Story.StoryId?
    
    @EnvironmentObject var episodeViewModel: EpisodeViewModel
    //@State var providerName: String = "SELMA"
    
    /// Showing PodcastRenderViewSheet?
    @State private var showingSheet = false
    
    /// The episode are we working on
    var chosenEpisode: Episode {
        return episodeViewModel[chosenEpisodeId]
    }
    
    /// Binding to currently chosen episode
    var chosenEpisodeBinding: Binding<Episode> {
        return $episodeViewModel[chosenEpisodeId]
    }
    
    /// Removes story
    private func onDelete(offsets: IndexSet) {
        episodeViewModel[chosenEpisodeId].stories.remove(atOffsets: offsets)
    }
    
    /// Moves a story to change story order
    private func onMove(from source: IndexSet, to destination: Int) {
        episodeViewModel[chosenEpisodeId].stories.move(fromOffsets: source, toOffset: destination)
    }
    
    var body: some View {
        GroupBox {
            
            VStack(alignment: .leading) {

                Text("Stories").font(.title3)
                
                List(selection: $chosenStoryId) {
                    ForEach(chosenEpisode.stories) {story in
                        Label {
                            Text(story.headline)
                        } icon: {
                            Image(systemName: story.usedInIntroduction ? "star.fill" : "star")
                        }
                    }
                    .onDelete(perform: onDelete)
                    .onMove(perform: onMove)
                }
                .listStyle(.inset(alternatesRowBackgrounds: true))
//                .navigationDestination(for: Story.StoryId.self) { storyId in
//                    if let storyBinding = $episodeViewModel[chosenEpisodeId].stories.first(where: {$0.id == storyId}) {
//                        //StoryEditView(story: storyBinding)
//
//                    }
//                }
                
            }.padding()
            
        }

    }
}

struct EpisodeEditorStoriesListView_Previews: PreviewProvider {
    static var previews: some View {

        let episodeViewModel = EpisodeViewModel(createPlaceholderEpisode: true)
        if let firstEpisodeId = episodeViewModel.firstEpisodeId {
            
            EpisodeEditorStoriesListView(chosenEpisodeId: firstEpisodeId, chosenStoryId: .constant(nil))
                .padding()
                .environmentObject(episodeViewModel)
                .frame(width:550, height: 600)
            
        } else {
            Text("No episode to display")
        }
    }
}
