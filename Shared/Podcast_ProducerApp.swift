//
//  Podcast_ProducerApp.swift
//  Shared
//
//  Created by Andy Giefer on 04.02.22.
//

import SwiftUI

@main
struct Podcast_ProducerApp: App {
    var body: some Scene {
        
        @StateObject var episodeViewModel = EpisodeViewModel(createPlaceholderEpisode: true)
        
        WindowGroup {
            //ScriptView()

            ContentView()
                .environmentObject(episodeViewModel)

        }
    }
}
