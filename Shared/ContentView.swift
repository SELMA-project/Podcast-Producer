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
            MainEditView(episodeViewModel: episodeViewModel)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        
                        // present Audio Render View
                        NavigationLink("Create Audio") {
                            AudioRenderView(episodeViewModel: episodeViewModel)
                        }
                    }
                }
        }.onAppear {
            //AudioManager.shared.deleteContentsOfDocumentDirectory()
        }
        .environmentObject(episodeViewModel)
    }

}


struct Sidebar: View {
    
    @ObservedObject var episodeViewModel: EpisodeViewModel
    
    // stores selection. needs to be optional!
    @State private var chosenEpisodeIndex: Int?
    
    init(episodeViewModel: EpisodeViewModel) {
        self.episodeViewModel = episodeViewModel
        
        // init chosenEpisodeIndex @State with episodeViewModel
        _chosenEpisodeIndex = State(initialValue: episodeViewModel.chosenEpisodeIndex)
    }
    
    var body: some View {
        
        // Binding used for List selection. Linked to chosenEpisodeIndex
        let chosenEpisodeIndexBinding = Binding {
            self.chosenEpisodeIndex
        } set: { newValue in
            self.chosenEpisodeIndex = newValue
            
            // update viewmodel based on selection
            episodeViewModel.chosenEpisodeIndex = newValue ?? 0
        }
        
        List(selection: chosenEpisodeIndexBinding) {
            ForEach(0..<episodeViewModel.availableEpisodes.count, id: \.self) {episodeIndex in
                NavigationLink(episodeViewModel.availableEpisodes[episodeIndex].timeSlot, value: episodeIndex)
            }
        }
        .listStyle(.sidebar)
        .toolbar {
            ToolbarItemGroup(placement: .automatic, content: {
                
                Button(action: githubSync) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                }
                
                Button(action: addEntry) {
                    Image(systemName: "plus")
                }
            })
        }
        .navigationTitle("Episodes")
    }
    
    private func addEntry() {
        print("Added entry")
    }
                       
   private func githubSync() {
       print("Synchronize with Github")
   }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
