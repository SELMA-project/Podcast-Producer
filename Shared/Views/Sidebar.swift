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
    @State private var chosenEpisodeIndex: Int?
    
    // are we showing the EpisodeCreationSheet?
    @State private var showingSheet = false
    
//    init(episodeViewModel: EpisodeViewModel) {
//        self.episodeViewModel = episodeViewModel
//
//        // init chosenEpisodeIndex @State with episodeViewModel
//        _chosenEpisodeIndex = State(initialValue: episodeViewModel.chosenEpisodeIndex)
//    }
    
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
