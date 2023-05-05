//
//  MonitioImportView.swift
//  Podcast Creator (macOS)
//
//  Created by Andy Giefer on 13.04.23.
//

import SwiftUI
import MonitioKit

struct MonitioImportView: View {
    
    /// The currently chosen episodeId.
    var chosenEpisodeId: UUID
    
    @StateObject private var monitioViewModel = MonitioViewModel()
    @EnvironmentObject private var episodeViewModel: EpisodeViewModel
    @Environment(\.dismiss) private var dismissAction
    
    @AppStorage("numberOfImportedStorylines") private var numberOfImportedStorylines: Int = 5
    @AppStorage("importTitlesAndTeasersOnly") private var importTitlesAndTeasersOnly: Bool = true
    @AppStorage("monitioImportMethod") private var importMethod: ImportMethod = .summary
    @AppStorage("monitioImportedDateRange") private var dateRange: MonitioManager.DateRangeDescriptor = .last24h
    @AppStorage("monitioViewID") private var monitioViewID: MonitioManager.ViewID = .dw
    
    /// The method to derive stories from the selected MonitioClusters.
    private enum ImportMethod: String {
        case summary, documents
    }
    
    
    /// Fetches clusters via MonitoViewModel.
    private func fetchClusters() {
        
        Task {
            
            // set all necessary parameters on the Monitio Manager
            prepareMonitioImport()
            
            print("Fetching Monitio clusters.")
            await monitioViewModel.fetchClusters(numberOfClusters: numberOfImportedStorylines)
        }
    }
    
    /// Configures the Monitio Manager to use all the necessary configued patameters
    private func prepareMonitioImport() {
        
        // get episode language from episodeViewModel
        let episodeLanguage = episodeViewModel[chosenEpisodeId].language
        
        // set language on monitioViewModel
        monitioViewModel.setLanguage(episodeLanguage)
        
        // set date range
        monitioViewModel.setDateRange(dateRange)

        // set view ID
        monitioViewModel.setViewID(monitioViewID)
    }
    
    /// Imports documents from selected clusters.
    private func importDocuments() {
        Task {
            
            // set all necessary parameters on the Monitio Manager
            prepareMonitioImport()
            
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
    
    @ViewBuilder
    /// Displays the parameters to confiure the initial fetch of the clusters
    var clusterFetchView: some View {
        
        HStack(alignment: .top) {
            VStack(alignment: .trailing) {
                
                // configure Monitio view
                Picker(selection: $monitioViewID) {
                    ForEach(MonitioManager.ViewID.allCases, id: \.self) {viewID in
                        Text(viewID.displayName).tag(viewID)
                    }
                } label: {
                    Text("Collection:")
                }.pickerStyle(.menu)
                
                
                // configure date range
                Picker(selection: $dateRange) {
                    ForEach(MonitioManager.DateRangeDescriptor.allCases, id: \.self) {range in
                        Text(range.displayName).tag(range)
                    }
                } label: {
                    Text("Date Range:")
                }.pickerStyle(.menu)
                
                
                // configure number of storylines to import
                HStack {
                    Stepper(value: $numberOfImportedStorylines, in: 1...20) {
                        Text("Number of storylines to fetch: \(numberOfImportedStorylines)")
                    }
                    
                    //Spacer()
                }
                
                
            }.frame(width: 230)
            
            Spacer()
            Button("Fetch") {
                fetchClusters()
            }
        }.padding([.top, .bottom], 8)
    }
    
    @ViewBuilder
    /// Configures how the selected clusters should be imported
    var clusterImportView: some View {
        Text("How should a selected storyline be imported?")
            .padding(.top, 16)
        
        Picker("", selection: $importMethod) {
            
            // first option: storyline summary
            Text("Import storyline summary").tag(ImportMethod.summary)
            
            // second option: import documents
            HStack {
                Stepper("Import up to", value: $monitioViewModel.numberOfDocumentsToImport, in: 0...monitioViewModel.numberOfAvailableDocuments)
                Text("\(monitioViewModel.numberOfDocumentsToImport) DW articles per storyline.")
                Spacer()
                Toggle("Restrict to titles & teasers", isOn: $importTitlesAndTeasersOnly)
                    .disabled(importMethod == .summary)
            }.tag(ImportMethod.documents)
            
        }
        .pickerStyle(.radioGroup)
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
                
                // view to select import parameters
                clusterFetchView

                Divider()
                
                
                // ScrollView with storylines
                ScrollView(.vertical) {
                    ForEach($monitioViewModel.monitioClusters) {$cluster in
                        ClusterLineView(cluster: $cluster)
                    }
                }
                                
                
                // Cluster import
                if monitioViewModel.monitioClusters.count > 0 {
                    clusterImportView
                }
                
                Spacer()
                
                // Buttons at the bottom
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
            
 
        }.frame(width: 550, height: 500)
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
