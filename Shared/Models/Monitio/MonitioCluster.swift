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
    public var availableLanguages: [String]
    public var selectionFrequency: Int
    
    init(id: String, title: String, availableLanguages: [String], selectionFrequency: Int) {
        self.id = id
        self.title = title
        self.availableLanguages = availableLanguages
        self.selectionFrequency = selectionFrequency
    }
    
    init(withAPICluster apiCluster: APICluster) {
        self.id = apiCluster.id
        self.title = apiCluster.title
        self.availableLanguages = apiCluster.availableLanguages
        self.selectionFrequency = apiCluster.selectionFrequency
    }
}

extension MonitioCluster {
    static var mockup0: Self {
        let title = "Difficult negociations in Tokyo"
        return MonitioCluster(id: "0", title: "Cluster Title", availableLanguages: ["en", "pt"], selectionFrequency: 14)
    }
    
    static var mockup1: Self {
        let title = "Macron arrives in Bejing"
        return MonitioCluster(id: "1", title: "Cluster Title", availableLanguages: ["de", "pt"], selectionFrequency: 12)
    }
    
    static var mockup2: Self {
        let title = "Terror in Sudan"
        return MonitioCluster(id: "2", title: "Cluster Title", availableLanguages: ["en", "pt"], selectionFrequency: 7)
    }
    
    static var mockup3: Self {
        let title = "Bolsonaro lleaves for China"
        return MonitioCluster(id: "2", title: "Cluster Title", availableLanguages: ["pt"], selectionFrequency: 3)
    }
    
    static var mockup4: Self {
        let title = "Biden visits Ireland"
        return MonitioCluster(id: "2", title: "Cluster Title", availableLanguages: ["en", "pt", "fr", "de"], selectionFrequency: 2)
    }
}
