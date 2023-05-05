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
    @AppStorage("monitioViewLanguageSelection") private var monitioLanguageSelection: LanguageSelection = .podcastLanguage
    
    @State var fetchingData = false
    
    /// The method to derive stories from the selected MonitioClusters.
    private enum ImportMethod: String {
        case summary, documents
    }
    
    private enum LanguageSelection: String, CaseIterable {
        case all, podcastLanguage
        
        var displayName: String {
            switch self {
            case .all:
                return "All languages"
            case .podcastLanguage:
                return "Podcast language"
            }
        }
    }

    /// Configures the Monitio Manager to use all the necessary configued patameters
    private func prepareMonitioImport() {
                
        // set language on monitioViewModel
        switch monitioLanguageSelection {
        case .podcastLanguage:
            // get episode language from episodeViewModel and set on MonitioManager
            let episodeLanguage = episodeViewModel[chosenEpisodeId].language
            monitioViewModel.setLanguage(episodeLanguage)
        case .all:
            // all languages allowed
            monitioViewModel.setLanguage(nil)
        }
        
        
        // set date range
        monitioViewModel.setDateRange(dateRange)

        // set view ID
        monitioViewModel.setViewID(monitioViewID)
    }
    
    
    /// Fetches clusters via MonitoViewModel.
    private func fetchClusters() {
        
        Task {
            
            // flag that fetching has begun
            fetchingData = true
            
            // set all necessary parameters on the Monitio Manager
            prepareMonitioImport()
            
            print("Fetching Monitio clusters.")
            await monitioViewModel.fetchClusters(numberOfClusters: numberOfImportedStorylines)
            
            // flag that fetching has ended
            fetchingData = false
        }
    }
    
    
    /// Imports documents from selected clusters.
    private func importDocuments() {
        Task {
            
            // flag that fetching has begun
            fetchingData = true
            
            // set all necessary parameters on the Monitio Manager
            prepareMonitioImport()
            
            var stories: [Story] = []
            
            // create stories based on chosen summarisation method
            switch importMethod {
            case .summary:
                stories = await monitioViewModel.extractStoriesFromMonitioSummaries()
            case .documents:
                // get the episode's language
                let episodeLanguage = episodeViewModel[chosenEpisodeId].language
                
                // get all stories matching the episode language
                stories = await monitioViewModel.extractStoriesFromMonitioDocuments(maximumNumberOfIncludedDocumentsPerStory: monitioViewModel.numberOfDocumentsToImport,
                                                                                    useTitlesAndTeasersOnly: importTitlesAndTeasersOnly,
                                                                                    restrictToLanguage: episodeLanguage
                )
            }
            
            // add each story to the episode's list of stories
            for story in stories {
                _ = episodeViewModel.appendStory(story: story, toChosenEpisode: chosenEpisodeId)
            }
            
            // flag that fetching has ended
            fetchingData = false
            
            // dismiss sheet
            dismissAction()
        }
    }
    
    @ViewBuilder
    /// Displays the parameters to confiure the initial fetch of the clusters
    var clusterFetchView: some View {
        
        Grid() {
            GridRow {
                Text("Collection:")
                    .gridColumnAlignment(.trailing)
                
                // configure Monitio view
                Picker("", selection: $monitioViewID) {
                    ForEach(MonitioManager.ViewID.allCases, id: \.self) {viewID in
                        Text(viewID.displayName).tag(viewID)
                    }
                }.pickerStyle(.menu)
            }
            
            GridRow {
                Text("Article langues:")
                
                // configure the Monitio language
                Picker("", selection: $monitioLanguageSelection) {
                    ForEach(LanguageSelection.allCases, id: \.self) {languageSelection in
                        Text(languageSelection.displayName).tag(languageSelection)
                    }
                }.pickerStyle(.menu)
            }
            
            GridRow {
                Text("Date Range:")
                
                // configure date range
                Picker("", selection: $dateRange) {
                    ForEach(MonitioManager.DateRangeDescriptor.allCases, id: \.self) {range in
                        Text(range.displayName).tag(range)
                    }
                }.pickerStyle(.menu)
            }
            
            GridRow {
                Text("Fetch:")
                HStack {
                    Stepper("", value: $numberOfImportedStorylines, in: 1...20)
                    Text("\(numberOfImportedStorylines) storylines")
                    
                    Spacer()
                    
                    Button("Fetch") {
                        fetchClusters()
                    }.disabled(fetchingData == true)
                }
                
            }

        }.padding([.top, .bottom], 8)
        
    }
    
    
    var numberOfArticlesDescriptor: String {
        
        let noA = monitioViewModel.numberOfDocumentsToImport
        let textForOneArticle = "\(noA) DW article per storyline."
        let textForMultipleArticles = "\(noA) DW articles per storyline."
        
        return  noA == 1 ? textForOneArticle : textForMultipleArticles
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
                Text(numberOfArticlesDescriptor)
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
                }.padding([.top, .bottom])
                         
                Divider()
                
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
                    .disabled(fetchingData == true)
                    
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
