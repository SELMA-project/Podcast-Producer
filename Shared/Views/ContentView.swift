//
//  ContentView.swift
//  Shared
//
//  Created by Andy Giefer on 04.02.22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @StateObject var episodeViewModel = EpisodeViewModel(createPlaceholderEpisode: false)
    @State private var chosenEpisodeId: UUID?

    var body: some View {
        
        NavigationSplitView {
            Sidebar(chosenEpisodeId: $chosenEpisodeId)
            #if os(macOS)
                .navigationSplitViewColumnWidth(230)
            #endif
        } detail: {
            
            NavigationStack(path: $episodeViewModel.navigationPath) {
                
                EpisodeEditorView(chosenEpisodeId: chosenEpisodeId)

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
