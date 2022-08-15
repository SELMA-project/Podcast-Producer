//
//  Podcast_ProducerApp.swift
//  Shared
//
//  Created by Andy Giefer on 04.02.22.
//

import SwiftUI

@main
struct Podcast_ProducerApp: App {
    let persistenceController = PersistenceController.shared

    //@State var episode0 = Episode.episode0
    
    var body: some Scene {
        
        WindowGroup {
            //TestView()
            
            //StoryEditView(episode: $episode0)
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .frame(minWidth: 1024, minHeight: 1024*9/16)
        }
    }
}
