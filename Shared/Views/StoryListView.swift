//
//  StoryListView.swift
//  Podcast Creator
//
//  Created by Andy Giefer on 10.02.23.
//

import SwiftUI

struct StoryListView: View {
    
    var chosenEpisodeIndex: Int?
    @EnvironmentObject var viewModel: EpisodeViewModel
    
    var chosenEpisodeBinding: Binding<Episode> {
        return $viewModel[chosenEpisodeIndex]
    }
    
    private func onDelete(offsets: IndexSet) {
        viewModel[chosenEpisodeIndex].stories.remove(atOffsets: offsets)
    }
    
    private func onMove(from source: IndexSet, to destination: Int) {
        viewModel[chosenEpisodeIndex].stories.move(fromOffsets: source, toOffset: destination)
    }
    
    var body: some View {
        List {
            Section("Stories") {
                ForEach(chosenEpisodeBinding.stories) {$story in
                    NavigationLink(value: story) {
                        Text(story.headline)
                    }
                }
                .onDelete(perform: onDelete)
                .onMove(perform: onMove)

            }
            
            Section {
                Button {
                    
                    // create empty story
                    let story = viewModel.appendEmptyStoryToChosenEpisode(chosenEpisodeIndex: chosenEpisodeIndex)
                    
                    // put story on the navigation stack - this way, StoryEditView is called
                    viewModel.navigationPath.append(story)
                } label: {
                    Text("Add Story")
                }
                
                Button {
                    print("Add code to import episode here.")
                } label: {
                    Text("Import Story")
                }
            }
        }
        .navigationDestination(for: Story.self) { story in
            StoryEditView(chosenEpisodeIndex: chosenEpisodeIndex, story: story)
        }

    }
}

struct StoryListView_Previews: PreviewProvider {
    static var previews: some View {
        StoryListView(chosenEpisodeIndex: 0)
    }
}
