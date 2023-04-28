//
//  MonitioCluster.swift
//  Podcast Creator
//
//  Created by Andy on 17.04.23.
//

import Foundation
import MonitioKit

struct MonitioCluster : Identifiable {
    var id: String
    var title: String
    var availableLanguages: [String]
    var selectionFrequency: Int
    var isSelected: Bool = false
    
    init(id: String, title: String, availableLanguages: [String], selectionFrequency: Int) {
        self.id = id
        self.title = title
        self.availableLanguages = availableLanguages
        self.selectionFrequency = selectionFrequency
    }
    
    
    /// Initializes a MonitioCluster with the corresponding API response.
    ///
    /// The inititalizer can fail if the API response does not contain sufficient data.
    /// - Parameter apiCluster: The API Response to use.
    init?(withAPICluster apiCluster: APICluster) {
        
        // do we have sifficient data?
        guard let clusterTitle = apiCluster.title else {
            print("Cluster with id \(apiCluster.id) does not have a title. Ignoring.")
            return nil
        }
        
        self.id = apiCluster.id
        self.title = clusterTitle
        self.availableLanguages = apiCluster.availableLanguages
        self.selectionFrequency = apiCluster.selectionFrequency
    }
}

extension MonitioCluster {
    static var mockup0: Self {
        let title = "Difficult negociations in Tokyo"
        return MonitioCluster(id: "0", title: title, availableLanguages: ["en", "pt"], selectionFrequency: 14)
    }
    
    static var mockup1: Self {
        let title = "Macron arrives in Bejing"
        return MonitioCluster(id: "1", title: title, availableLanguages: ["de", "pt"], selectionFrequency: 12)
    }
    
    static var mockup2: Self {
        let title = "Terror in Sudan"
        return MonitioCluster(id: "2", title: title, availableLanguages: ["en", "pt"], selectionFrequency: 7)
    }
    
    static var mockup3: Self {
        let title = "Bolsonaro leaves for China"
        return MonitioCluster(id: "3", title: title, availableLanguages: ["pt"], selectionFrequency: 3)
    }
    
    static var mockup4: Self {
        let title = "Biden visits Ireland"
        return MonitioCluster(id: "4", title: title, availableLanguages: ["en", "pt", "fr", "de"], selectionFrequency: 2)
    }
}
