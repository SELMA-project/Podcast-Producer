//
//  EpisodeViewModel.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 09.08.22.
//

import Foundation

enum SegmentIdentifier: String, CaseIterable  {
    case welcomeText = "Welcome"
    case headlineIntroduction = "Headline Introduction"
    case headline = "Headline"
    case story = "Story"
    case epilogue = "Epilogue"
}


struct AudioSegment: Identifiable {
    var id = UUID()
    var segmentIdentifer: SegmentIdentifier
    var subIndex: Int = 0
    var isPlaying: Bool = false
    var audioData: Data?
    var text: String
}

@MainActor
class EpisodeViewModel: ObservableObject {
    
    @Published var chosenEpisodeIndex: Int = 0
    @Published var availableEpisodes: [Episode]
    
    // the entire episode in segments
    @Published var episodeStructure: [AudioSegment] = []
    
    var speakerName =  "leila endruweit"
    
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
            case .headline:
                for (index, story) in chosenEpisode.stories.enumerated() {
                    if story.usedInIntroduction {
                        newAudioSegments.append(AudioSegment(segmentIdentifer: .headline, subIndex: index, text: story.headline))
                    }
                }
            case .story:
                for (index, story) in chosenEpisode.stories.enumerated() {
                    newAudioSegments.append(AudioSegment(segmentIdentifer: .story, subIndex: index, text: story.storyText))
                }
            case .epilogue:
                newAudioSegments = [AudioSegment(segmentIdentifer: .epilogue, text: chosenEpisode.epilogue)]
            }
            
            // add the new segment(s) to structure
            structure.append(contentsOf: newAudioSegments)
        }
        
        // pusblish
        self.episodeStructure = structure
    }

    
    func renderEpisodeStructure() async {
        
        for (index, audioSegment) in episodeStructure.enumerated() {
            print("Cancel status: \(Task.isCancelled)")
            print("Rendering: \(index) -> \(audioSegment.segmentIdentifer.rawValue)")
            
            // the text to render
            let text = audioSegment.text
            
            // render audio
            let data = await SelmaManager.shared.renderAudio(speakerName: speakerName, text: text)
            
            // store audio
            if let data = data {
                episodeStructure[index].audioData = data
            } else {
                print("No audio data returned.")
            }
            
        }
        
    }
    
    func playEpisodeStructure() async {
  
        for (index, audioSegment) in episodeStructure.enumerated() {
            
            print("Playing: \(index) -> \(audioSegment.segmentIdentifer.rawValue)")
            
            episodeStructure[index].isPlaying = true

            // TODO: Change! Should be more elegant
            for (i, _) in episodeStructure.enumerated() {
                if i != index {
                    episodeStructure[i].isPlaying = false
                }
            }
            
            // the text to render
            let text = audioSegment.text
            
            // render audio
            let data = await SelmaManager.shared.renderAudio(speakerName: speakerName, text: text)
            
            // play audio
            if let data = data {
                await SelmaManager.shared.playAudio(audioData: data)
            } else {
                print("No audio data returned.")
            }
            
        }
        
    }
    
    func playButtonPressed(forSegment audioSegment: AudioSegment) async {

        // find index of given audioSegment in array
        let currentIndex = episodeStructure.firstIndex { segment in
            segment.id == audioSegment.id
        }
        
        // early return if no index was found (should not happen)
        guard let currentIndex = currentIndex else {return}
        
        // early exit if not audio data is available (shout not happen)
        guard let audioData = audioSegment.audioData else {return}

        // in any case, stop the currently played audio
        SelmaManager.shared.stopAudio()
        
        // currently not playng, so we want to play
        if audioSegment.isPlaying == false {
            
            // switch all audioSegments to 'off' - except the one with the current index
            for (index, _) in episodeStructure.enumerated() {
                episodeStructure[index].isPlaying = currentIndex == index ? true : false
            }
            
            // switch to 'playing'
            //episodeStructure[index].isPlaying = true
            
            // play segment
            await SelmaManager.shared.playAudio(audioData: audioData)
            
            // when returning, switch to 'not playing'
            episodeStructure[currentIndex].isPlaying = false
            
        } else { // segment is currently playing
            
            // switch to 'not playing'
            episodeStructure[currentIndex].isPlaying = false
        }
        
    }
    
}
