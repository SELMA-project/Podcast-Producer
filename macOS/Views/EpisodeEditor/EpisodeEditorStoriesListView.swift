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

                HStack {
                    Text("Stories").font(.title2)
                    
                    Spacer()
                    
                    // Import stories button
                    Button {
                        print("Import stories")
                    } label: {
                        Image(systemName: "square.and.arrow.down.on.square")
                    }
                    .help("Import MONITIO stories")
                    
                    // Add story button
                    Button {
                        chosenStoryId = episodeViewModel.appendEmptyStoryToChosenEpisode(chosenEpisodeId: chosenEpisodeId)
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                    .help("Add story")
                }
                
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
                
            }.padding()
        }
        .dropDestination(for: Data.self) { dataArray, _ in
            Task {
                if let dwArticle = await DWManager.shared.extractDWArticle(fromDataArray: dataArray) {
                    let _ = episodeViewModel.appendStory(parsedFromDWArticle: dwArticle, toChosenEpisode: chosenEpisodeId)
                }
                
            }
            return true
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
