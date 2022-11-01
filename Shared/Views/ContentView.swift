//
//  ContentView.swift
//  Shared
//
//  Created by Andy Giefer on 04.02.22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @StateObject var episodeViewModel = EpisodeViewModel()
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        
        NavigationSplitView {
            Sidebar(episodeViewModel: episodeViewModel)
        } detail: {
            MainEditView()
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        
                        // present Audio Render View
                        NavigationLink("Create Audio") {
                            AudioRenderView()
                        }
                    }
                }
        }.onAppear {
            episodeViewModel.printAppInformation()
        }
        .environmentObject(episodeViewModel)
    }

}





struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
