//
//  Podcast_ProducerApp.swift
//  Shared
//
//  Created by Andy Giefer on 04.02.22.
//

import SwiftUI

@main
struct Podcast_ProducerApp: App {

    @StateObject var episodeViewModel = EpisodeViewModel(createPlaceholderEpisode: true)
    
    var body: some Scene {
        
        WindowGroup {
            //ScriptView()

            ContentView()
                .environmentObject(episodeViewModel)
        }
        .commands {
            CommandGroup(after: .newItem) {
                Button("Import Pressespiegel") {
                    episodeViewModel.openPresseSpiegel()
                }.keyboardShortcut("I")
            }
            
            TextEditingCommands()
        }

        Settings {
            SettingsView()
        }
                
    }
}
