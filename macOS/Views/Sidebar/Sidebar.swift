//
//  Sidebar.swift
//  Podcast Creator (macOS)
//
//  Created by Andy Giefer on 20.02.23.
//

import SwiftUI

struct Sidebar: View {
    
    @Binding var chosenEpisodeId: UUID?
    
    @EnvironmentObject var episodeViewModel: EpisodeViewModel
    
    // are we showing the EpisodeCreationSheet?
    @State private var showingSheet = false
    
    private func onDelete(offsets: IndexSet) {
        // deselect currently chosen episode
        chosenEpisodeId = nil
        
        // remove
        episodeViewModel.availableEpisodes.remove(atOffsets: offsets)
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
            .onDeleteCommand {
                if let episodeIndex = episodeViewModel.episodeIndexForId(episodeId: chosenEpisodeId) {
                    let indexSet = IndexSet(integer: episodeIndex)
                    onDelete(offsets: indexSet)
                }
            }
            
            // show this instruction if we don't have any episodes
            if episodeViewModel.availableEpisodes.count == 0 {
                Text("Please tap '+' to add a new episode.")
                    .padding()
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
