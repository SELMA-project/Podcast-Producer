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
    
    var body: some View {
        
        
        if let chosenEpisodeId  {
                        
            GeometryReader{geometry in
                HStack {
                    MainEditView(chosenEpisodeId: chosenEpisodeId)
                        .frame(width: 550)
        
                    
                    Text("Right")//.frame(minWidth:200, idealWidth: 200, maxWidth: .infinity)
                }//.frame(width: geometry.size.width, height: geometry.size.height)
            }
                        
        } else {
            if episodeViewModel.availableEpisodes.count == 0 {
                Text("Please create an Episode.")
            } else {
                Text("Please choose an Episode.")
            }
        }
    }
}

struct MainEditView: View {
    
    var chosenEpisodeId: UUID
    
    @EnvironmentObject var episodeViewModel: EpisodeViewModel

    /// Showing PodcastRenderViewSheet?
    @State private var showingSheet = false
        
    var body: some View {
        
        VStack {
            
            EpisodeEditorSettingsView(chosenEpisodeId: chosenEpisodeId)
            EpisodeEditorStoriesListView(chosenEpisodeId: chosenEpisodeId)
        }.padding()
        .sheet(isPresented: $showingSheet) {
            PodcastRenderView(chosenEpisodeId: chosenEpisodeId)
                .environmentObject(episodeViewModel)
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
