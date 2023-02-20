//
//  ContentView.swift
//  Podcast Creator (macOS)
//
//  Created by Andy Giefer on 20.02.23.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var episodeViewModel = EpisodeViewModel()
    @AppStorage("chosenEpisodeIndex") private var chosenEpisodeIndex: Int?
    
    var body: some View {
        
        NavigationSplitView {
            Sidebar(chosenEpisodeIndex: $chosenEpisodeIndex)
        } detail: {
            
            NavigationStack(path: $episodeViewModel.navigationPath) {
                
                EpisodeEditorView(chosenEpisodeIndex: chosenEpisodeIndex)
                    .toolbar {
                        
                        ToolbarItem() {

                            NavigationLink(value: "Structure") {
                                Image(systemName: "slider.horizontal.3")
                            }

                        }
                        
                    }
                    .navigationDestination(for: String.self) { _ in
                        StructureEditorView(chosenEpisodeIndex: chosenEpisodeIndex)
                    }
            }
        }.onAppear {
            episodeViewModel.runStartupRoutine()
        }
        
        .environmentObject(episodeViewModel)
        
    }

    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
