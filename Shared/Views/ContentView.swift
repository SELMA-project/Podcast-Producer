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
    //@AppStorage("chosenEpisodeId") private var chosenEpisodeId: UUID?
    @State private var chosenEpisodeId: UUID?

    var body: some View {
        
        NavigationSplitView {
            Sidebar(chosenEpisodeId: $chosenEpisodeId)
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
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
