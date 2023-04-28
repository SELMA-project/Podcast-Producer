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
    
    @Published var statusMessage: String = ""
    @Published var monitioClusters: [MonitioCluster] = [] {//[.mockup0, .mockup1, .mockup2, .mockup3, .mockup4]
        didSet {
            // check whether at least one cluster is selected
            atLeastOneClusterIsSelected = monitioClusters.reduce(false, {$0 || $1.isSelected})
            
            // adjust the number of available documents
            numberOfAvailableDocuments = monitioClusters.reduce(0) { partialResult, cluster in
                // only selected clusters are counted
                if cluster.isSelected {
                    return partialResult + cluster.selectionFrequency
                } else {
                    return partialResult
                }
            }
            
            // adjust the number of documents to import
            numberOfDocumentsToImport = numberOfAvailableDocuments //min(numberOfDocumentsToImport, numberOfAvailableDocuments)
        }
    }
    
    @Published var numberOfDocumentsToImport: Int = 3
    @Published var numberOfAvailableDocuments: Int = 0
    @Published var atLeastOneClusterIsSelected: Bool = false
    
    private var monitioManager: MonitioManager
    
    init() {
        self.monitioManager = MonitioManager()
        monitioManager.setViewId(MonitioManager.dwViewId)
        monitioManager.setDateInterval(forDescriptor: .last24h)
        //monitioManager.setLanguageIds(languageIds: [.pt])
    }
    
    func setLanguage(_ language: LanguageManager.Language) {
        
        // convert to monitioLanguageId
        if let monitioLanguageId = MonitioLanguageId(rawValue: language.monitioCode) {
            
            // set monitioManager accordingly
            monitioManager.setLanguageIds(languageIds: [monitioLanguageId])
        }
    }
    

    
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
    
    func extractStoriesFromMonitioDocuments(numberOfStories: Int, useTeasersOnly: Bool) async -> [Story] {
        
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
                            let articleText = useTeasersOnly ? dwArticle?.teaser : dwArticle?.formattedText
                            
                            // append article headline to the storyText
                            if let articleHeadline {
                                storyTextParagraphs.append(articleHeadline)
                            }
                            
                            // append article text to the storyText
                            if let articleText {
                                storyTextParagraphs.append(articleText)
                            }
                            
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

// MARK: Fetching clusters and their details
extension MonitioViewModel {
    
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

