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
            let apiClusters = await monitioManager.getClusters(numberOfClusters: numberOfClusters)
            
            for apiCluster in apiClusters {
                if let monitioCluster = MonitioCluster(withAPICluster: apiCluster) {
                    monitioClusters.append(monitioCluster)
                }
            }
            
            self.statusMessage = "Fetched \(apiClusters.count) storylines."
        }
    }
    
}


