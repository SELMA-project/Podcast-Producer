//
//  StoryListView.swift
//  Podcast Creator
//
//  Created by Andy Giefer on 11.01.23.
//

import SwiftUI

struct StoryListView: View {
    
    @Binding var chosenEpisodeIndex: Int?
    
    @EnvironmentObject var viewModel: EpisodeViewModel
    
//    var stories: [Story] {
//        return $viewModel.chosenEpisode.stories
//    }
    
//    var chosenEpisode: Episode {
//        return viewModel[viewModel.chosenEpisodeIndex]
//    }
    
    var chosenEpisodeBinding: Binding<Episode> {
        return $viewModel[chosenEpisodeIndex]
    }
    
    private func onDelete(offsets: IndexSet) {
        var chosenEpisode = viewModel[chosenEpisodeIndex]
        chosenEpisode.stories.remove(atOffsets: offsets)
    }
    
    private func onMove(from source: IndexSet, to destination: Int) {
        var chosenEpisode = viewModel[chosenEpisodeIndex]
        chosenEpisode.stories.move(fromOffsets: source, toOffset: destination)
    }
    
    private func addStory() {
        
    }
    
    var body: some View {
                    
        Form {
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
            
        }
        .navigationDestination(for: Story.self) { story in
            StoryEditView(chosenEpisodeIndex: $chosenEpisodeIndex, story: story)
        }
        .toolbar {
            
            ToolbarItem {
                #if os(iOS)
                EditButton()
                #endif
            }

        }
        .navigationTitle("Stories")

    }
}

struct StoryListView_Previews: PreviewProvider {
    static var previews: some View {
        StoryListView(chosenEpisodeIndex: .constant(0))
    }
}
