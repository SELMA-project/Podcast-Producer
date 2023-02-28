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
    @State var inspectorIsVisible: Bool = true
    
    /// Showing PodcastRenderViewSheet?
    @State private var showingSheet = false
    
    var body: some View {
        
        Group {
            if let chosenEpisodeId  {
                
                HStack(spacing: 0) {
                    HStack {
                        MainEditView(chosenEpisodeId: chosenEpisodeId)
                            .frame(width: 550)
                    
                        EpisodeEditorStoryView()
                            
                    }

                    .padding()
                    
                    StructureEditorView(chosenEpisodeId: chosenEpisodeId)
                        .frame(width: inspectorIsVisible ? 200 : 0)
                    
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
            
            ToolbarItem() {
                Button {
                    showingSheet = true
                } label: {
                    //Text("Produce Podcast")
                    Image(systemName: "record.circle")
                }
            }
            
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


struct MainEditView: View {
    
    var chosenEpisodeId: UUID
    
    @EnvironmentObject var episodeViewModel: EpisodeViewModel


        
    var body: some View {
        
        VStack {
            
            EpisodeEditorSettingsView(chosenEpisodeId: chosenEpisodeId)
            EpisodeEditorStoriesListView(chosenEpisodeId: chosenEpisodeId)
        }


    }
}

struct MainEditView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let episodeViewModel = EpisodeViewModel(createPlaceholderEpisode: true)
        if let firstEpisodeId = episodeViewModel.firstEpisodeId {
            
            MainEditView(chosenEpisodeId: firstEpisodeId)
                .environmentObject(episodeViewModel)
                .frame(width:550, height: 600)
            
        } else {
            Text("No episode to display")
        }
        
    }
}
