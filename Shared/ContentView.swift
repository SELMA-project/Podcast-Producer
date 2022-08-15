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
    @State private var selectedTab = 1
    
    var body: some View {
        NavigationSplitView {
            Sidebar()
        } detail: {
            Group {
                if selectedTab == 0 {
                    Text("Collect View")
                }
                if selectedTab == 1 {
                    MainEditView()
                }
                if selectedTab == 2 {
                    Text("Publish View")
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {

                    Button {
                        print("Render button pressed")
                    } label: {
                        Image(systemName: "square.and.arrow.down")
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
    @State private var chosenEpisode: Episode?
    
    var body: some View {
        List(selection: $chosenEpisode) {
            Section("Latest on GitHub") {
                ForEach(episodeViewModel.availableEpisodes) {episode in
                    NavigationLink(episode.timeSlot, value: episode)
                }
            }
            Section("Locally created") {
            }
        }
        .listStyle(.sidebar)
        .toolbar {
            ToolbarItemGroup {
                Spacer()
                Button(action: addEntry, label : {
                    Image(systemName: "plus")
                })
            }
        }
    }
    
    private func addEntry() {
        print("Added entry")
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
