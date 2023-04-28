//
//  MonitioViewModel.swift
//  Podcast Creator
//
//  Created by Andy Giefer on 13.04.23.
//

import Foundation
import MonitioKit

@MainActor
class MonitioViewModel: ObservableObject {
    
    @Published var statusMessage: String = ""
    @Published var monitioClusters: [MonitioCluster] = []//[.mockup0, .mockup1, .mockup2, .mockup3, .mockup4]
    
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
    
    func fetchClusters(numberOfClusters: Int) {
        self.statusMessage = "Fetching storylines..."
        
        // delete old clusters
        monitioClusters = []
        
        Task {
            // get clusters from API
            let apiClusters = await monitioManager.getClusters(numberOfClusters: numberOfClusters)
            
            // convert API clusters to MonitioClusters
            for apiCluster in apiClusters {
                if let monitioCluster = MonitioCluster(withAPICluster: apiCluster) {
                    monitioClusters.append(monitioCluster)
                }
            }
            
            self.statusMessage = "Fetched \(monitioClusters.count) storylines."
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
    
    
    
    
    func extractStories(numberOfDocuments: Int, useTeasersOnly: Bool) async -> [Story] {
        
        let stories = [Story]()
        
        return stories
    }

}

// MARK: Summarising clusters
extension MonitioViewModel {
    
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

