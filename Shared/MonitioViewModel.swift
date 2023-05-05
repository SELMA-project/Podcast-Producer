//
//  MonitioViewModel.swift
//  Podcast Creator
//
//  Created by Andy Giefer on 13.04.23.
//

import Foundation
import MonitioKit
import DWUtilities

@MainActor
class MonitioViewModel: ObservableObject {
    
    /// The status message to display in the UI.
    @Published var statusMessage: String = ""
    
    /// An array containing all MonitioClusters that have been fetched via the API.
    @Published var monitioClusters: [MonitioCluster] = [] {//[.mockup0, .mockup1, .mockup2, .mockup3, .mockup4]
        didSet {

            // adjust the number of available documents
            numberOfAvailableDocuments = calculateNumberOfOfAvailableDocumentsInBiggestSelectedCluster()

            // adjust the number of documents to import
            numberOfDocumentsToImport = numberOfAvailableDocuments
            
            // adjust the number of documents to import
            numberOfDocumentsToImport = numberOfAvailableDocuments
        }
    }
    
    // derived properties
    
    /// The number of documents that *should* be imported from the selected clusters.
    @Published var numberOfDocumentsToImport: Int = 0
    
    /// The number of documents that *can* be imported from the selected clusters.
    @Published var numberOfAvailableDocuments: Int = 0
    
    // The manager used to access the Monitio API
    private var monitioManager: MonitioManager
    
    init() {
        self.monitioManager = MonitioManager(viewId: .dw)
        monitioManager.setDateInterval(forDescriptor: .last24h) // is overwritten by view 
        //monitioManager.setLanguageIds(languageIds: [.pt])
    }
    
    /// Sets the data range that should be used to import Monitio storylines.
    /// - Parameter dateRange: The daterange.
    func setDateRange(_ dateRange: MonitioManager.DateRangeDescriptor) {
        monitioManager.setDateInterval(forDescriptor: dateRange)
    }
    
    /// Sets the language to use with the Monitio API.
    func setLanguage(_ language: LanguageManager.Language) {
        
        // convert to monitioLanguageId
        if let monitioLanguageId = MonitioLanguageId(rawValue: language.monitioCode) {
            
            // set monitioManager accordingly
            monitioManager.setLanguageIds(languageIds: [monitioLanguageId])
        }
    }
    
    /// Returns the number of documents that are contained in the buggest selected cluster.
    /// - Returns: The number of documents.
    private func calculateNumberOfOfAvailableDocumentsInBiggestSelectedCluster() -> Int {
        
        // fpcus on selected clusters
        let selectedClusters = monitioClusters.filter({ $0.isSelected })
        
        // sort by numberOfDocuments in descending order
        let sortedByNumberOfDocuments = selectedClusters.sorted(by: {$0.selectionFrequency > $1.selectionFrequency})
        
        // the first cluster has the highest number of documents
        let numberOfDocuments = sortedByNumberOfDocuments.first?.selectionFrequency ?? 0
        
        return numberOfDocuments
    }
    
}

// MARK: Fetching clusters and their details
extension MonitioViewModel {
    
    /// Fetches clusters from the Monitio API.
    /// - Parameter numberOfClusters: The number of clusters to fetch.
    func fetchClusters(numberOfClusters: Int) async {
        self.statusMessage = "Fetching storylines..."
        
        // delete old clusters
        monitioClusters = []
        
        // get clusters from API
        let apiClusters = await monitioManager.getClusters(numberOfClusters: numberOfClusters)
        
        // convert API clusters to MonitioClusters
        for apiCluster in apiClusters {
            if let monitioCluster = MonitioCluster(withAPICluster: apiCluster) {
                
                // by default, a cluster is selected
                var selectedCluster = monitioCluster
                selectedCluster.isSelected = true
                
                // append to array
                monitioClusters.append(selectedCluster)
            }
        }
                
        self.statusMessage = "Fetched \(monitioClusters.count) storylines containing \(numberOfAvailableDocuments) documents."

    }
    
    /// Fetches the details for the selected MonitioClusters.
    /// - Returns: An Array of cluster details as returned by the Monitio API.
    private func fetchClusterDetails() async -> [APIClusterDetail] {
        
        // prepare result
        var clusterDetails = [APIClusterDetail]()
        
        // go through each cluster
        for monitioCluster in monitioClusters {
            
            // only use the selected clusters
            if monitioCluster.isSelected {
                
                // extract the cluster's id and title
                let clusterId = monitioCluster.id
                let clusterTitle = monitioCluster.title
                
                // update status message
                statusMessage = "Fetching cluster: \(clusterTitle)"
                
                // download its detail
                if let clusterDetail = await monitioManager.getClusterDetail(clusterId: clusterId) {
                    
                    // append the downloaded detail to the result
                    clusterDetails.append(clusterDetail)
                }
                
                statusMessage = "All clusters are downloaded."
            }
        }
        
        // return result
        return clusterDetails
        
    }
}

// MARK: Story extraction
extension MonitioViewModel {
    
    /// Downloads the details of the selected MonitoClusters and converts them into stories, using the Monitio summaries.
    /// - Returns: An array of Stories
    func extractStoriesFromMonitioSummaries() async -> [Story] {
        
        // prepare result
        var stories = [Story]()
        
        // get cluster details from Monitio API
        let clusterDetails = await fetchClusterDetails()
        
        // go through each of them
        for clusterDetail in clusterDetails {
            
            // extract details
            let headline = clusterDetail.cluster.title
            let storyText = clusterDetail.summarySentences.joined(separator: " ")
            
            // create story
            let story = Story(usedInIntroduction: false, headline: headline, storyText: storyText)
            
            // append to result
            stories.append(story)
        }
        
        return stories
    }
    
    /// Downloads the details of the selected MonitoClusters and converts them into stories, using text from DW Articles.
    ///
    /// Note that for each cluster, only DW Articles contain can be used to derived the story's text.
    /// - Parameters:
    ///   - numberOfStories: The maximum number of stories to create.
    ///   - useTitlesAndTeasersOnly: Only use document titles and teasers to create story text.
    /// - Returns: <#description#>
    func extractStoriesFromMonitioDocuments(numberOfStories: Int, useTitlesAndTeasersOnly: Bool) async -> [Story] {
        
        // prepare result
        var stories = [Story]()
        
        // create DWManager to get access to DW arcticles
        let dwManager = DWManager()
        
        // get cluster details from Monitio API
        let clusterDetails = await fetchClusterDetails()
        
        // go through each of clusters
        for clusterDetail in clusterDetails {
                        
            // extract the contained document
            let documents = clusterDetail.result.documents
            
            // the document headlines and texts are extracted into the storyText
            var storyTextParagraphs = [String]()
            
            // go through each document
            for document in documents {
                                
                // if the document references a DW Article...
                if let dwShortPageURLString = document.header.dwShortPageUrl {
                    
                    // ... convert URL string to proper URL
                    if let dwShortPageURL = URL(string: dwShortPageURLString) {
                        
                        // convert to dwItemURL
                        if let dwItemURL = DWItemURL(url: dwShortPageURL) {
                            
                            // ... retrieve the associated article from the DW API
                            let dwArticle = await dwManager.dwArticle(dwURL: dwItemURL)
                            
                            // extract headline and text from article
                            let articleHeadline = dwArticle?.name
                            let articleText = useTitlesAndTeasersOnly ? dwArticle?.teaser : dwArticle?.formattedText
                            
                            // append article headline to the storyText
                            if let articleHeadline {
                                storyTextParagraphs.append(articleHeadline)
                            }
                            
                            // append article text to the storyText
                            if let articleText {
                                storyTextParagraphs.append(articleText)
                            }
                            
                            // separate articles by extra newline
                            storyTextParagraphs.append("\n")
                            
                        }
                    }
                }
                
                // check whether we have accumulated enough stories
                if stories.count == numberOfStories {
                    break
                }
            }
            
            // the cluster title becomes the headline of the story
            let storyHeadline = clusterDetail.cluster.title
            
            // join storyTextParagraphs into the storyText
            let storyText = storyTextParagraphs.joined(separator: "\n\n")
            
            // create story
            let story = Story(usedInIntroduction: false, headline: storyHeadline, storyText: storyText)
            
            // append to result
            stories.append(story)
        }
        
        // return result
        return stories
    }
    
}
