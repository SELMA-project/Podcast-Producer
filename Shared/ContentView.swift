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
    @State private var chosenEpisode: Episode?
    
    var body: some View {
        NavigationSplitView {
            Sidebar(chosenEpisode: $chosenEpisode)
        } detail: {
            MainEditView(chosenEpisode: $chosenEpisode)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        
                        Button {
                            print("Render button pressed")
                        } label: {
                            //Image(systemName: "square.and.arrow.down")
                            Text("Create Audio")
                        }
                    }
                }
        }

        .environmentObject(episodeViewModel)
    }
    
    //    private func toggleSidebar() { // 2
    //#if os(iOS)
    //#else
    //        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    //#endif
    //    }
    
    
}


struct Sidebar: View {
    
    @EnvironmentObject var episodeViewModel: EpisodeViewModel
    //@State private var chosenEpisode: Episode?
    @Binding var chosenEpisode: Episode?
    
    var body: some View {
        List(selection: $chosenEpisode) {
            ForEach(episodeViewModel.availableEpisodes) {episode in
                NavigationLink(episode.timeSlot, value: episode)
            }
        }
        .listStyle(.sidebar)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar, content: {
                
                Button(action: githubSync) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                }
                
                Button(action: addEntry) {
                    Image(systemName: "plus")
                }
            })
        }
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
