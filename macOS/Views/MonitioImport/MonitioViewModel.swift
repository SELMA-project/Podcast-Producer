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
            numberOfDocumentsToImport = 1
            
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
    
    /// Sets the viewID that should be used to import Monitio storylines.
    /// - Parameter dateRange: The daterange.
    func setViewID(_ viewID: MonitioManager.ViewID) {
        monitioManager.setViewId(viewID)
    }
    
    /// Sets the language to use with the Monitio API.
    ///
    /// Setting the value to *nil* sets the MonitioManager to allow all languages.
    func setLanguage(_ language: LanguageManager.Language?) {
        
        // by default, we allow all languages (= empty array)
        var monitioLanguageIds = [MonitioLanguageId]()
        
        // if a language was set...
        if let language {
            // convert to monitioLanguageId
            if let monitioLanguageId = MonitioLanguageId(rawValue: language.monitioCode) {
                // store in array of monitioLanguages
                monitioLanguageIds = [monitioLanguageId]
            }
        }
        
        // set monitioManager accordingly
        monitioManager.setLanguageIds(languageIds: monitioLanguageIds)
    }
}


// MARK: Public: Fetching Clusters
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
        
        self.statusMessage = "Fetched \(monitioClusters.count) storylines containing up to \(numberOfAvailableDocuments) articles each."
        
    }
}

// MARK: Public: Fetching Stories from Summaries
extension MonitioViewModel {

    /// Downloads the details of the selected MonitoClusters and converts them into stories, using the Monitio summaries.
    /// - Returns: An array of Stories
    func extractStoriesFromMonitioSummaries() async -> [Story] {
        
        // prepare result
        var stories = [Story]()
        
        // get cluster details from Monitio API.
        let clusterDetails = await fetchClusterDetails(restrictToFeed: nil)
        
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
    
}


// MARK: Public: Extracting Stories from Documents
extension MonitioViewModel {
    
    /// Downloads the details of the selected MonitoClusters and converts them into stories, using text from DW Articles.
    ///
    /// Note that for each cluster, only DW Articles contain can be used to derived the story's text.
    /// - Parameters:
    ///   - maximumNumberOfIncludedDocumentsPerStory: The maximum number of documents to include for every story.
    ///   - useTitlesAndTeasersOnly: Only use document titles and teasers to create story text.
    ///   - restrictToLanguage: Optionally, only include documents with the specified language. *nil* includes documents regardless of their language.
    ///   - feedName: Optionally, the name of the feed that should be used as additional filter when retrieving the cluster details.
    /// - Returns: An array of stories.
    func extractStoriesFromMonitioDocuments(maximumNumberOfIncludedDocumentsPerStory: Int, useTitlesAndTeasersOnly: Bool, restrictToLanguage documentLanguage: LanguageManager.Language?, restrictToFeed feedName: String?) async -> [Story] {
        
        // prepare result
        var stories = [Story]()

        // get cluster details from Monitio API _without_ feed restriction
        let unfilteredClusterDetails = await fetchClusterDetails(restrictToFeed: nil)
        
        // get cluster details from Monitio API _with_ Feed restriction
        let filteredClusterDetails = await fetchClusterDetails(restrictToFeed: feedName)
        
        // go through each of clusters
        for unfilteredClusterDetail in unfilteredClusterDetails {

            // the unfiltered cluster title becomes the headline of the story
            let storyHeadline = unfilteredClusterDetail.cluster.title.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Identify the filtered cluster detail mathing the unfiltered clusterDetail.
            // The matching is done via the resprctive clusters' ids
            let filteredClusterDetail = filteredClusterDetails.first(where: {$0.cluster.id == unfilteredClusterDetail.cluster.id})
            
            // We want to extract the story text. Te default is an empty string.
            var storyText = ""
            
            // if there is a matching filtered cluster detail, extract the story text from its documents
            if let filteredClusterDetail {
                
                // get story text from cluster documents
                storyText = await extractStoryText(fromClusterDetail: filteredClusterDetail,
                                                   maximumNumberOfIncludedDocumentsPerStory: maximumNumberOfIncludedDocumentsPerStory,
                                                   useTitlesAndTeasersOnly: useTitlesAndTeasersOnly,
                                                   restrictToLanguage: documentLanguage)
            }
            
            // add default disclaimer if no sotry text is available. This happens when no DW articles where found inside the clusers
            if storyText.isEmpty {
                storyText = "No DW articles are available in the chosen episode language."
            }
            
            // create story
            let story = Story(usedInIntroduction: false, headline: storyHeadline, storyText: storyText)
            
            // append to result
            stories.append(story)
        }
        
        // return result
        return stories
    }
    
    
    /// Extracts story text from the provided clusterDetail.
    /// - Parameters:
    ///   - clusterDetail: The API response describing the the details of the cluster.
    ///   - maximumNumberOfIncludedDocumentsPerStory: The maximum number of documents to include for every story.
    ///   - useTitlesAndTeasersOnly: Only use document titles and teasers to create story text.
    ///   - documentLanguage: Optionally, only include documents with the specified language. *nil* includes documents regardless of their language.
    /// - Returns: A String containg the extracted documents texts.
    private func extractStoryText(fromClusterDetail clusterDetail:  APIClusterDetail,
                                  maximumNumberOfIncludedDocumentsPerStory: Int,
                                  useTitlesAndTeasersOnly: Bool,
                                  restrictToLanguage documentLanguage: LanguageManager.Language?) async -> String {
        
        // create DWManager to get access to DW arcticles
        let dwManager = DWManager()
        
        // extract the contained document
        let documents = clusterDetail.result.documents
        
        // the document headlines and texts are extracted into the storyText
        var storyTextParagraphs = [String]()
        
        // counts how many documents were included
        var documentCounter = 0
        
        // go through each document
        for document in documents {
            
            //print(document.header.sourceItemPageUrl)
                            
            // Do not extract more documents if there are already enough documents in the current story.
            if documentCounter == maximumNumberOfIncludedDocumentsPerStory {
                break
            }
            
            // check language
            
            // if a document language was specified...
            if let documentLanguage {
                
                // convert to the language code string used by Monitio
                let monitioLanguageCode = documentLanguage.monitioCode
                
                // skip to next document if the document language and specified code do not match
                if document.language != monitioLanguageCode {
                    print("Skipping: \(document.title) -> \(document.header.dwShortPageUrl ?? "No DW Article")")
                    continue
                }
            }
            
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
                            var articleHeadlineWithFullStop = articleHeadline
                            
                            // add full stop at the end if one is missing
                            if articleHeadlineWithFullStop.last != "." {
                                articleHeadlineWithFullStop += "."
                            }
                            
                            storyTextParagraphs.append(articleHeadlineWithFullStop)
                        }
                        
                        // append article text to the storyText
                        if let articleText {
                            storyTextParagraphs.append(articleText)
                        }
                        
                        // separate articles by extra newline
                        storyTextParagraphs.append("\n")
                        
                        // if have added one more document to the story
                        documentCounter += 1
                    }
                }
            }
        
        }
        
        // join storyTextParagraphs into the storyText
        let storyText = storyTextParagraphs.joined(separator: "\n\n").trimmingCharacters(in: .whitespacesAndNewlines)
        
        // return as single string
        return storyText
    }
    
}



// MARK: Private Functions
extension MonitioViewModel {
    
    /// Returns the number of documents that are contained in the biggest selected cluster.
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
    
    /// Fetches the details for the selected MonitioClusters.
    /// - Returns: An Array of cluster details as returned by the Monitio API.
    private func fetchClusterDetails(restrictToFeed feedName: String?) async -> [APIClusterDetail] {
        
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
                if let clusterDetail = await monitioManager.getClusterDetail(clusterId: clusterId, restrictToFeed: feedName) {
                                        
                    // append the downloaded detail to the result
                    clusterDetails.append(clusterDetail)
                } else {
                    // we could create a fake APIClusterDetail here which only contains the cluster title and, as article text, the note that 'no DW article could be found'.
                }
                
                statusMessage = "All clusters are downloaded."
            }
        }
        
        // return result
        return clusterDetails
        
    }
}

