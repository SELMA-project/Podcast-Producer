//
//  EpisodeViewModel.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 09.08.22.
//

import Foundation

class EpisodeViewModel: ObservableObject {
    
    @Published var chosenEpisode: Episode
    
    init() {
        chosenEpisode = Episode.episode0()
    }
    
}
