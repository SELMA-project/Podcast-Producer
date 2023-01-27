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
    
    // Showing PodcastRenderViewSheet?
    @State private var showingSheet = false
    
    @State private var path = NavigationPath()
    
    var body: some View {
        
        NavigationSplitView {
            Sidebar(episodeViewModel: episodeViewModel)
        } detail: {
            
            NavigationStack(path: $path) {
                
                EpisodeEditorView()
                    .toolbar {
                        
//                        ToolbarItem() {
//
//                            NavigationLink(value: "StoryList") {
//                                Image(systemName: "square.fill.text.grid.1x2")
//                            }
//
//                        }
                        
                        ToolbarItem(placement: .primaryAction) {
                            Button {
                                showingSheet = true
                            } label: {
                                Text("Build")
                                //Image(systemName: "antenna.radiowaves.left.and.right")
                            }
                        }
                        
                        
                    }
//                    .navigationDestination(for: String.self) { _ in
//                        StoryListView()
//                    }
            }
        }.onAppear {
            episodeViewModel.runStartupRoutine()
        }
        
        .environmentObject(episodeViewModel)
        
        .sheet(isPresented: $showingSheet) {
            PodcastRenderView()
                .environmentObject(episodeViewModel)
        }
    }

}





struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
