//
//  StoryListView.swift
//  Podcast Creator
//
//  Created by Andy Giefer on 11.01.23.
//

import SwiftUI

struct StoryListView: View {
    
    @EnvironmentObject var viewModel: EpisodeViewModel
    
//    var stories: [Story] {
//        return $viewModel.chosenEpisode.stories
//    }
    
    private func onDelete(offsets: IndexSet) {
        viewModel.chosenEpisode.stories.remove(atOffsets: offsets)
    }
    
    private func onMove(from source: IndexSet, to destination: Int) {
        viewModel.chosenEpisode.stories.move(fromOffsets: source, toOffset: destination)
    }
    
    private func addStory() {
        
    }
    
    var body: some View {
                    
        Form {
            List {
                Section("Stories") {
                    ForEach($viewModel.chosenEpisode.stories) {$story in
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
                        let story = viewModel.appendEmptyStoryToChosenEpisode()
                        
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
            StoryEditView(story: story)
        }
        .toolbar {
            
            ToolbarItem {
                EditButton()
            }

        }
        .navigationTitle("Stories")

    }
}

struct StoryListView_Previews: PreviewProvider {
    static var previews: some View {
        StoryListView()
    }
}
