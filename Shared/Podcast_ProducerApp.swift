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
    
    var body: some Scene {
        
        WindowGroup {
            //ScriptView()

            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(.dark)
        }
    }
}
