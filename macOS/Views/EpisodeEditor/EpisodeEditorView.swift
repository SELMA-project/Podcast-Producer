//
//  EpisodeEditorView.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 08.08.22.
//

import SwiftUI


struct EpisodeEditorView: View {
    
    var chosenEpisodeId: UUID?
    
    @EnvironmentObject var episodeViewModel: EpisodeViewModel
    
    /// Constrols visibility of the inspector
    @State var inspectorIsVisible: Bool = false
    
    /// Showing PodcastRenderViewSheet?
    @State private var showingSheet = false
    
    // Which story is chosen?
    @State private var chosenStoryId: Story.StoryId?
    
    var chosenStoryBinding: Binding<Story>? {
        // if we have selected a story through it's id
        if let chosenStoryId {
            // get associated story and return it
            if let storyBinding = $episodeViewModel[chosenEpisodeId].stories.first(where: {$0.id == chosenStoryId}) {
                return storyBinding
            }
        }
        
        // by default, return nil
        return nil
    }
    
    var body: some View {
        
        Group {
            if let chosenEpisodeId  {
                
                HStack(spacing: 0) {
                    HStack {
                        VStack {
                            EpisodeEditorSettingsView(chosenEpisodeId: chosenEpisodeId)
                            EpisodeEditorStoriesListView(chosenEpisodeId: chosenEpisodeId, chosenStoryId: $chosenStoryId)
                        }
                        .frame(width: 550)
                        
                        if let chosenStoryBinding {
                            EpisodeEditorStoryView(story: chosenStoryBinding)
                        } else {
                            GroupBox {
                                Text("Please select a story.")
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                            
                    }

                    .padding()
                    
                    Divider()
                    
                    StructureEditorView(chosenEpisodeId: chosenEpisodeId)
                        .padding()
                        .frame(width:  inspectorIsVisible ? 400 : 0)
                        //.clipped()
                        .opacity(inspectorIsVisible ? 1 : 0 )
                    
                }
                
            } else {
                if episodeViewModel.availableEpisodes.count == 0 {
                    Text("Please create an Episode.")
                } else {
                    Text("Please choose an Episode.")
                }
            }
        }
        .toolbar {
            
            // Add new story botton
            ToolbarItem() {
                Button {
                    chosenStoryId = episodeViewModel.appendEmptyStoryToChosenEpisode(chosenEpisodeId: chosenEpisodeId)
                } label: {
                    Image(systemName: "square.and.pencil")
                }
                .disabled(chosenEpisodeId == nil)
            }
            
            // Produce Podcast button
            ToolbarItem() {
                Button {
                    showingSheet = true
                } label: {
                    //Text("Produce Podcast")
                    Image(systemName: "record.circle")
                }
            }
            
            // Show structure inspector button
            ToolbarItem() {
                Button {
                    withAnimation {
                        inspectorIsVisible.toggle()
                    }
                    
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
                .disabled(chosenEpisodeId == nil)
            }
        }
        .sheet(isPresented: $showingSheet) {
            PodcastRenderView(chosenEpisodeId: chosenEpisodeId)
                .padding()
                .frame(width: 450)
                .environmentObject(episodeViewModel)

        }
    }
}

struct EpisodeEditorView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let episodeViewModel = EpisodeViewModel(createPlaceholderEpisode: true)
        if let firstEpisodeId = episodeViewModel.firstEpisodeId {
            
            EpisodeEditorView(chosenEpisodeId: firstEpisodeId)
                .environmentObject(episodeViewModel)
                .frame(width:900, height: 600)
            
        } else {
            Text("No episode to display")
        }
        
    }
}


