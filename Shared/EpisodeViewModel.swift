//
//  EpisodeViewModel.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 09.08.22.
//

import Foundation

class EpisodeViewModel: ObservableObject {
    
    @Published var chosenEpisode: Episode
    @Published var availableEpisodes: [Episode]
    
    init() {
        // episde0 from example data
        let episode0 = Episode.episode0
        
        // derive episode 1 from e0
        var episode1 = episode0
        episode1.timeSlot = "August 11th am"
        episode1.id = UUID()
        
        // derive episode 2 from e0
        var episode2 = episode0
        episode2.timeSlot = "August 11th pm"
        episode2.id = UUID()
        
        availableEpisodes = [episode0, episode1, episode2]
        
        chosenEpisode = episode0
    }
    
}
