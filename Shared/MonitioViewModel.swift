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

    private var monitioManager: MonitioManager
    
    init() {
        self.monitioManager = MonitioManager()
        monitioManager.setViewId(MonitioManager.dwViewId)
        monitioManager.setDateInterval(forDescriptor: .last24h)
        monitioManager.setLanguageIds(languageIds: [.pt])
    }
    
    func fetchClusters() {
        self.statusMessage = "Fetching storylines..."
        
        Task {
            let apiClusters = await monitioManager.getClusters()
            
            self.statusMessage = "Fetched \(apiClusters.count) storylines"
        }
    }
    
}
