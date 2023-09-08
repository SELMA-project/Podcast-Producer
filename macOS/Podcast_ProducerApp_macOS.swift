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
                    // Calling this menu triggers a notification which will be received by ContentView
                    NotificationCenter.default.post(name: .importPresseSpiegel, object: nil)
                }.keyboardShortcut("I")
            }
            
            TextEditingCommands()
        }

        Settings {
            SettingsView()
        }
                
    }
}

// The name of the notification sent when importing the WDR PRessespiegel
extension Notification.Name {
    static let importPresseSpiegel = Notification.Name("importPresseSpiegel")
}
