//
//  MonitioImportView.swift
//  Podcast Creator (macOS)
//
//  Created by Andy Giefer on 13.04.23.
//

import SwiftUI

struct MonitioImportView: View {
    
    /// The currently chosen episodeId.
    var chosenEpisodeId: UUID
    
    @StateObject private var monitioViewModel = MonitioViewModel()
    @EnvironmentObject private var episodeViewModel: EpisodeViewModel
    @Environment(\.dismiss) private var dismissAction
    
    @AppStorage("numberOfImportedStorylines") private var numberOfImportedStorylines: Int = 5
    @AppStorage("importTitlesAndTeasersOnly") private var importTitlesAndTeasersOnly: Bool = true
    @AppStorage("monitioImportMethod") private var importMethod: ImportMethod = .summary
    
    /// The method to derive stories from the selected MonitioClusters.
    private enum ImportMethod: String {
        case summary, documents
    }
    
    
    /// Fetches clusters via MonitoViewModel.
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
    
    
    /// Imports documents from selected clusters.
    private func importDocuments() {
        Task {
            
            var stories: [Story] = []
            
            // create stories based on chosen summarisation method
            switch importMethod {
            case .summary:
                stories = await monitioViewModel.extractStoriesFromMonitioSummaries()
            case .documents:
                stories = await monitioViewModel.extractStoriesFromMonitioDocuments(numberOfStories: monitioViewModel.numberOfDocumentsToImport, useTitlesAndTeasersOnly: importTitlesAndTeasersOnly)
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
                        .font(.caption)
                        .lineLimit(1)
                    Text(" ") // empty string to reserve space for status message
                }
                
                HStack {
                    Stepper("Number of storylines to fetch:", value: $numberOfImportedStorylines, in: 1...20)
                    Text("\(numberOfImportedStorylines)")
                    
                    Spacer()
                    
                    Button("Fetch") {
                        fetchClusters()
                    }
                }.padding([.top, .bottom], 8)

                
                
                
                // ScrollView with storylines
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
                            Stepper("Import up to", value: $monitioViewModel.numberOfDocumentsToImport, in: 0...monitioViewModel.numberOfAvailableDocuments)
                            Text("\(monitioViewModel.numberOfDocumentsToImport) DW documents per storyline.")
                            Spacer()
                            Toggle("Restrict to titles & teasers", isOn: $importTitlesAndTeasersOnly)
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
                    .disabled(monitioViewModel.numberOfDocumentsToImport == 0)
                    
                }
                .padding([.top], 8)
            }
            
            Spacer()
            
 
        }.frame(width: 550, height: 400)
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
