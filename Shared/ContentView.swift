//
//  ContentView.swift
//  Shared
//
//  Created by Andy Giefer on 04.02.22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab = 1
    
    var body: some View {
        NavigationView {
            Sidebar()
            
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
                    ToolbarItem(placement: .navigation) {
                        Button(action: toggleSidebar, label: {
                            Image(systemName: "sidebar.leading")
                        })
                    }
                    
                    ToolbarItem(placement: .principal) {
                        Picker(selection: $selectedTab, label: Text("Picker")) {
                            Text("Collect").tag(0)
                            Text("Edit").tag(1)
                            Text("Publish").tag(2)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .labelsHidden()
                    }
                    
                }
        }
    }
    
    private func toggleSidebar() { // 2
#if os(iOS)
#else
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
#endif
    }
    
    
}


struct Sidebar: View {
    
    var body: some View {
        List {
            Text("Fri, Feb 4th pm")
            Text("Fri, Feb 4th am")
            Text("Thu, Feb 3rd pm")
            Text("Thu, Feb 3rd am")
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
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
