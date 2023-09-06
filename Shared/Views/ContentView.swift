//
//  ContentView.swift
//  Shared
//
//  Created by Andy Giefer on 04.02.22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @StateObject var episodeViewModel = EpisodeViewModel(createPlaceholderEpisode: true)
    @State private var chosenEpisodeId: UUID?
    @StateObject var voiceViewModel = VoiceViewModel()

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
        }
        .onAppear {
            episodeViewModel.runStartupRoutine()
            
            // select the latest episode in the sidebar
            self.chosenEpisodeId = episodeViewModel.lastEpisodeId
        }
        // this is where the episdeViewModel informs the voiceViewModel of the selected episode and therefore of the selected locale
        .onChange(of: chosenEpisodeId, perform: { newValue in
            let chosenEpisode = episodeViewModel[newValue]
            let localeId = chosenEpisode.language.isoCode
            voiceViewModel.selectedLocaleId = localeId
        })
        .environmentObject(episodeViewModel)
        .environmentObject(voiceViewModel)
        #if os(macOS)
        .frame(minWidth: 1200, minHeight: 600)
        #endif
    }

}





struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
