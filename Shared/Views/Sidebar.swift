//
//  Sidebar.swift
//  Podcast Creator
//
//  Created by Andy Giefer on 01.11.22.
//

import SwiftUI

struct Sidebar: View {
    
    @ObservedObject var episodeViewModel: EpisodeViewModel
    
    // stores selection. needs to be optional!
    //@State private var chosenEpisodeIndex: Int?
    
    // are we showing the EpisodeCreationSheet?
    @State private var showingSheet = false
    
//    init(episodeViewModel: EpisodeViewModel) {
//        self.episodeViewModel = episodeViewModel
//
//        // init chosenEpisodeIndex @State with episodeViewModel
//        _chosenEpisodeIndex = State(initialValue: episodeViewModel.chosenEpisodeIndex)
//    }
    
    private func onDelete(offsets: IndexSet) {
        episodeViewModel.availableEpisodes.remove(atOffsets: offsets)
    }
    
    var body: some View {
        
//        // Binding used for List selection. Linked to chosenEpisodeIndex
//        let chosenEpisodeIndexBinding = Binding {
//            self.chosenEpisodeIndex
//        } set: { newValue in
//            self.chosenEpisodeIndex = newValue
//
//            // update viewmodel based on selection
//            episodeViewModel.chosenEpisodeIndex = newValue ?? 0
//        }
        
        ZStack {
            
            // show this if we have at least one episode
            List(selection: $episodeViewModel.chosenEpisodeIndex) {
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
        Sidebar(episodeViewModel: EpisodeViewModel())
    }
}
