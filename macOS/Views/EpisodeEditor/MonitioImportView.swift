//
//  MonitioImportView.swift
//  Podcast Creator (macOS)
//
//  Created by Andy Giefer on 13.04.23.
//

import SwiftUI

struct MonitioImportView: View {
    
    /// The currently chosen episodeId
    var chosenEpisodeId: UUID
    
    @StateObject var monitioViewModel = MonitioViewModel()
    @EnvironmentObject var episodeViewModel: EpisodeViewModel
    @Environment(\.dismiss) var dismissAction
    
    @AppStorage("numberOfImportedStorylines") var numberOfImportedStorylines: Int = 5
    //@AppStorage("numberOfDocumentsToImport") var numberOfDocumentsToImport: Int = 3
    @AppStorage("importTeaserOnly") var importTeaserOnly: Bool = true
    @AppStorage("monitioImportMethod") var importMethod: ImportMethod = .summary
    
    enum ImportMethod: String {
        case summary, documents
    }
    

    
    private func fetchClusters() {
        
        Task {
            
            // get episode language from episodeViewModel
            let episodeLanguage = episodeViewModel[chosenEpisodeId].language
            
            // set language on monitioViewModel
            monitioViewModel.setLanguage(episodeLanguage)
            
            print("Fetching Monitio clusters.")
            await monitioViewModel.fetchClusters(numberOfClusters: numberOfImportedStorylines)
        }
    }
    
    private func importDocuments() {
        Task {
            
            var stories: [Story] = []
            
            // create stories based on chosen summarisation method
            switch importMethod {
            case .summary:
                stories = await monitioViewModel.extractStoriesFromMonitioSummaries()
            case .documents:
                stories = await monitioViewModel.extractStoriesFromMonitioDocuments(numberOfStories: monitioViewModel.numberOfDocumentsToImport, useTeasersOnly: importTeaserOnly)
            }
            
            // add each story to the episode's list of stories
            for story in stories {
                _ = episodeViewModel.appendStory(story: story, toChosenEpisode: chosenEpisodeId)
            }
            
            // dismiss sheet
            dismissAction()
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                
                Text("MONITIO Importer").font(.title)
                
                ZStack {
                    Text(monitioViewModel.statusMessage)
                        .lineLimit(1)
                    Text(" ") // empty string to reserve space for status message
                }
                
                HStack {
                    Stepper("Number of storylines to fetch:", value: $numberOfImportedStorylines)
                    Text("\(numberOfImportedStorylines)")
                    
                    Spacer()
                    
                    Button("Fetch") {
                        fetchClusters()
                    }
                }
                
                // ScrollView with stories
                ScrollView(.vertical) {
                    ForEach($monitioViewModel.monitioClusters) {$cluster in
                        ClusterLineView(cluster: $cluster)
                    }
                }
                
                
                if monitioViewModel.monitioClusters.count > 0 {
                    Text("How should a selected storyline be imported?")
                        .padding(.top, 16)
                    
                    Picker("", selection: $importMethod) {
                        
                        // first option: storyline summary
                        Text("Import storyline summary").tag(ImportMethod.summary)
                        
                        // second option: import documents
                        HStack {
                            Stepper("Import", value: $monitioViewModel.numberOfDocumentsToImport, in: 0...monitioViewModel.numberOfAvailableDocuments)
                            Text("\(monitioViewModel.numberOfDocumentsToImport) documents")
                            Spacer()
                            Toggle("Restrict to teasers", isOn: $importTeaserOnly)
                                .disabled(importMethod == .summary)
                        }.tag(ImportMethod.documents)
                        
                    }
                    .pickerStyle(.radioGroup)
                    
                }
                
                Spacer()
                
                HStack {
                    
                    Button("Cancel") {
                        dismissAction()
                    }
                    
                    Spacer()
                                        
                    Button("Import") {
                        print("Importing Monitio clusters.")
                        importDocuments()
                    }
                    
                }
            }
            
            Spacer()
            
 
        }.frame(width: 400, height: 400)
    }
}

struct MonitioImportView_Previews: PreviewProvider {
    static var previews: some View {
        
        let episodeViewModel = EpisodeViewModel(createPlaceholderEpisode: true)
        
        if let firstEpisodeId = episodeViewModel.firstEpisodeId {
            MonitioImportView(chosenEpisodeId: firstEpisodeId)
                .padding()
                .environmentObject(episodeViewModel)
        }
    }
}


struct ClusterLineView:  View {
    
    @Binding var cluster: MonitioCluster
    
    var body: some View {
        HStack {
            Toggle(isOn: $cluster.isSelected) {
                VStack(alignment: .leading) {
                    Text(cluster.title)
                    Text("\(cluster.selectionFrequency) documents. Languages: \(cluster.availableLanguages.joined(separator: ", "))")
                        .font(.caption)
                }
            }
            Spacer()
            
        }
    }
}
