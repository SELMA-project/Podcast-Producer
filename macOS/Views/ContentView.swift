//
//  ContentView.swift
//  Podcast Creator (macOS)
//
//  Created by Andy Giefer on 20.02.23.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var episodeViewModel = EpisodeViewModel()
    @State private var chosenEpisodeId: UUID?
    
    var body: some View {
        
        NavigationSplitView {
            Sidebar(chosenEpisodeId: $chosenEpisodeId)
                .navigationSplitViewColumnWidth(230)
        } detail: {
            
            NavigationStack(path: $episodeViewModel.navigationPath) {
                
                EpisodeEditorView(chosenEpisodeId: chosenEpisodeId)
                    .toolbar {
                        
                        ToolbarItem() {

                            NavigationLink(value: "Structure") {
                                Image(systemName: "slider.horizontal.3")
                            }

                        }
                        
                    }
                    .navigationDestination(for: String.self) { _ in
                        if let chosenEpisodeId {
                            StructureEditorView(chosenEpisodeId: chosenEpisodeId)
                        }
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
