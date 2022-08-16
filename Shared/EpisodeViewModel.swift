//
//  EpisodeViewModel.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 09.08.22.
//

import Foundation

enum SegmentIdentifier: CaseIterable {
    case welcomeText
    case headlineIntroduction
    case headlines
    case stories
    case epiloge
}


struct AudioSegment: Identifiable {
    var id = UUID()
    var segmentIdentifer: SegmentIdentifier
    var subIndex: Int = 0
    var isActive: Bool = false
    var text: String
}


class EpisodeViewModel: ObservableObject {
    
    @Published var chosenEpisodeIndex: Int = 0
    @Published var availableEpisodes: [Episode]
    
    // the entire episode in segments
    @Published var episodeStructure: [AudioSegment] = []
    
    init() {
        // episde0 from example data
        let episode0 = Episode.episode0
        
        // derive episode 1 from e0
        var episode1 = episode0
        episode1.timeSlot = "August 11th am"
        episode1.cmsTitle = "Boletim de Notícias (11/08/22) – Primera edição"
        episode1.id = UUID()
        
        // derive episode 2 from e0
        var episode2 = episode0
        episode2.timeSlot = "August 11th pm"
        episode2.cmsTitle = "Boletim de Notícias (11/08/22) – Segunda edição"
        episode2.id = UUID()
        
        availableEpisodes = [episode0, episode1, episode2]
    }
    
    /// After building an Episode Structure, this function will return the individual segments until non are left
    func nextSegment() -> AudioSegment? {
    
        // return nil if no segments are available (any more)
        guard episodeStructure.count > 0 else {return nil}
        
        // result -> default is nil
        var nextSegment: AudioSegment?
        
        // which segment is currently active?
        let activeSegmentIndex = episodeStructure.firstIndex { audioSegment in
            return audioSegment.isActive
        }
                
        // get next segment
        if let activeSegmentIndex = activeSegmentIndex {
            
            // set current segment to inactive
            episodeStructure[activeSegmentIndex].isActive = false
            
            // any segments left?
            if activeSegmentIndex < episodeStructure.count - 1 {
                
                // get next index
                let nextSegmentIndex = episodeStructure.index(after: activeSegmentIndex)
                
                // get associated index
                nextSegment = episodeStructure[nextSegmentIndex]
                
                // set segment to active
                nextSegment?.isActive = true
            }
        }
        
        return nextSegment
    }
    
    
    func buildEpisodeStructure() {

        // result
        var structure = [AudioSegment]()
        
        // episode to build
        let chosenEpisode = availableEpisodes[chosenEpisodeIndex]
        
        // array of all ids
        let allIdentifiers = SegmentIdentifier.allCases
        
        var newAudioSegments: [AudioSegment]
        
        for segmentIdentifier in allIdentifiers {
            
            // reset
            newAudioSegments = []
            
            switch segmentIdentifier {
            case .welcomeText:
                newAudioSegments = [AudioSegment(segmentIdentifer: .welcomeText, text: chosenEpisode.welcomeText)]
            case .headlineIntroduction:
                newAudioSegments = [AudioSegment(segmentIdentifer: .headlineIntroduction, text: chosenEpisode.headlineIntroduction)]
            case .headlines:
                for (index, story) in chosenEpisode.stories.enumerated() {
                    if story.usedInIntroduction {
                        newAudioSegments.append(AudioSegment(segmentIdentifer: .headlines, subIndex: index, text: story.headline))
                    }
                }
            case .stories:
                for (index, story) in chosenEpisode.stories.enumerated() {
                    newAudioSegments.append(AudioSegment(segmentIdentifer: .stories, subIndex: index, text: story.storyText))
                }
            case .epiloge:
                newAudioSegments = [AudioSegment(segmentIdentifer: .epiloge, text: chosenEpisode.epilogue)]
            }
            
            // add the new segment(s) to structure
            structure.append(contentsOf: newAudioSegments)
        }
        
        // pusblish
        self.episodeStructure = structure
    }

}
