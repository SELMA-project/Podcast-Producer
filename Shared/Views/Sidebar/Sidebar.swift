//
//  Sidebar.swift
//  Podcast Creator
//
//  Created by Andy Giefer on 01.11.22.
//

import SwiftUI

struct Sidebar: View {
    
    @Binding var chosenEpisodeId: UUID?
    
    @EnvironmentObject var episodeViewModel: EpisodeViewModel
    
    // are we showing the EpisodeCreationSheet?
    @State private var showingSheet = false
    
    private func onDelete(offsets: IndexSet) {
        
        chosenEpisodeId = nil
        
        episodeViewModel.availableEpisodes.remove(atOffsets: offsets)
        
        // set chosenEpisodeId to nil when there are not episodes left
        if episodeViewModel.availableEpisodes.count == 0 {
            chosenEpisodeId = nil
        }
    }
    
    var body: some View {
        
        ZStack {
            
            // show this if we have at least one episode
            List(selection: $chosenEpisodeId) {
                ForEach(episodeViewModel.availableEpisodes) {episode in
                    HStack {
                        Text(episode.timeSlot)
                        Spacer()
                        Text(episode.language.isoCode)
                            .font(.caption)
                            .foregroundColor(Color.secondary)
                    }
                }
                .onDelete(perform: onDelete)
            }
            
            // show this instruction if we don't have any episodes
            if episodeViewModel.availableEpisodes.count == 0 {
                Text("Please tap '+' to add a new episode.")
            }
        }
        .listStyle(.sidebar)
        .toolbar {
            ToolbarItemGroup(placement: .automatic, content: {
                Button {
                    showingSheet.toggle()
                } label: {
                    Image(systemName: "plus")
                }

            })
        }
        .sheet(isPresented: $showingSheet) {
            EpisodeCreationView()
                .environmentObject(episodeViewModel)
        }
        
        .navigationTitle("Episodes")
    }
}

struct Sidebar_Previews: PreviewProvider {
    static var previews: some View {
        
        let episodeViewModel = EpisodeViewModel()
        if episodeViewModel.availableEpisodes.count > 0 {
            let firstEpisodeId = episodeViewModel.availableEpisodes[0].id
            Sidebar(chosenEpisodeId: .constant(firstEpisodeId))
                .environmentObject(EpisodeViewModel())
        } else {
            Text("No episode to display")
        }
            
    }
}
