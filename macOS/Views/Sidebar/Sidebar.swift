//
//  Sidebar.swift
//  Podcast Creator (macOS)
//
//  Created by Andy Giefer on 20.02.23.
//

import SwiftUI

struct Sidebar: View {
    
    @Binding var chosenEpisodeIndex: Int?
    
    @EnvironmentObject var episodeViewModel: EpisodeViewModel
    
    // are we showing the EpisodeCreationSheet?
    @State private var showingSheet = false
    
    private func onDelete(offsets: IndexSet) {
        episodeViewModel.availableEpisodes.remove(atOffsets: offsets)
        
        // set chosenEpisodeIndex to nil when there are not episodes left
        if episodeViewModel.availableEpisodes.count == 0 {
            chosenEpisodeIndex = nil
        }
    }
    
    var body: some View {
        
        ZStack {
            
            // show this if we have at least one episode
            List(selection: $chosenEpisodeIndex) {
                ForEach(0..<episodeViewModel.availableEpisodes.count, id: \.self) {episodeIndex in
                    NavigationLink(value: episodeIndex) {
                        HStack {
                            Text(episodeViewModel.availableEpisodes[episodeIndex].timeSlot)
                            Spacer()
                            Text(episodeViewModel.availableEpisodes[episodeIndex].language.isoCode)
                                .font(.caption)
                                .foregroundColor(Color.secondary)
                        }
                    }
                }
                .onDelete(perform: onDelete)
            }
            .onDeleteCommand {
                if let chosenEpisodeIndex {
                    let indexSet = IndexSet(integer: chosenEpisodeIndex)
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
        Sidebar(chosenEpisodeIndex: .constant(0))
            .environmentObject(EpisodeViewModel())
    }
}
