//
//  EpisodeViewModel.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 09.08.22.
//

import Foundation
import CryptoKit

enum SegmentIdentifier: String, CaseIterable  {
    case welcomeText = "Welcome"
    case headlineIntroduction = "Headline Introduction"
    case headline = "Headline"
    case story = "Story"
    case epilogue = "Epilogue"
}


struct EpisodeSegment: Identifiable {
    var id: String {
        //return "audio_\(self.hashValue)"
        let textToBeHashed = "\(segmentIdentifer.rawValue)-\(text)"
        let textAsData = Data(textToBeHashed.utf8)
        let hashed = SHA256.hash(data: textAsData)
        let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }
    var segmentIdentifer: SegmentIdentifier
    var subIndex: Int = 0
    var isPlaying: Bool = false
    //var audioData: Data?
    var audioURL: URL?
    var text: String
    var highlightInSummary: Bool = false
    
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(self.segmentIdentifer.rawValue)
//        hasher.combine(text)
//    }
//
//    var hashValue: Int {
//        var hasher = Hasher()
//        self.hash(into: &hasher)
//        return hasher.finalize()
//    }
}


@MainActor
class EpisodeViewModel: ObservableObject {
    
    @Published var chosenEpisodeIndex: Int = 0
    @Published var availableEpisodes: [Episode]
    @Published var episodeAvailable: Bool = false
    
    
    // the entire episode in segments
    @Published var episodeStructure: [EpisodeSegment] = []
    
    var speakerName =  SelmaVoice(.leila).selmaName
    
    var episodeUrl: URL = Bundle.main.url(forResource: "no-audio.m4a", withExtension: nil)!
    
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
        var structure = [EpisodeSegment]()
        
        // episode to build
        let chosenEpisode = availableEpisodes[chosenEpisodeIndex]
        
        // array of all ids
        let allIdentifiers = SegmentIdentifier.allCases
        
        var newEpisodeSegments: [EpisodeSegment]
        
        for segmentIdentifier in allIdentifiers {
            
            // reset
            newEpisodeSegments = []
            
            switch segmentIdentifier {
            case .welcomeText:
                newEpisodeSegments = [EpisodeSegment(segmentIdentifer: .welcomeText, text: chosenEpisode.welcomeText)]
            case .headlineIntroduction:
                newEpisodeSegments = [EpisodeSegment(segmentIdentifer: .headlineIntroduction, text: chosenEpisode.headlineIntroduction)]
            case .headline:
                for (index, story) in chosenEpisode.stories.enumerated() {
                    if story.usedInIntroduction {
                        newEpisodeSegments.append(EpisodeSegment(segmentIdentifer: .headline, subIndex: index, text: story.headline, highlightInSummary: story.usedInIntroduction))
                    }
                }
            case .story:
                for (index, story) in chosenEpisode.stories.enumerated() {
                    newEpisodeSegments.append(EpisodeSegment(segmentIdentifer: .story, subIndex: index, text: story.storyText))
                }
            case .epilogue:
                newEpisodeSegments = [EpisodeSegment(segmentIdentifer: .epilogue, text: chosenEpisode.epilogue)]
            }
            
            // add the new segment(s) to structure
            structure.append(contentsOf: newEpisodeSegments)
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
            
            // where should the rendered audio be stored?
            let audioURL = storageURL(forAudioSegment: audioSegment)
            
            // render audio if it does not yet exist
            var success = true
            if !fileExists(atURL: audioURL) {
                success = await AudioManager.shared.synthesizeAudio(speakerName: speakerName, text: text, toURL: audioURL)
            }
            
            // store audio URL
            if success {
                episodeStructure[index].audioURL = audioURL
            } else {
                print("No audio data available.")
            }
            
        }
        
    }
    
    
    func playButtonPressed(forSegment audioSegment: EpisodeSegment) async {

        // find index of given audioSegment in array
        let currentIndex = episodeStructure.firstIndex { segment in
            segment.id == audioSegment.id
        }
        
        // early return if no index was found (should not happen)
        guard let currentIndex = currentIndex else {return}
        
        // early exit if not audio data is available (should not happen)
        guard let audioUrl = audioSegment.audioURL else {return}

        // in any case, stop the currently played audio
        AudioManager.shared.stopAudio()
        
        // currently not playng, so we want to play
        if audioSegment.isPlaying == false {
            
            // switch all audioSegments to 'off' - except the one with the current index
            for (index, _) in episodeStructure.enumerated() {
                episodeStructure[index].isPlaying = currentIndex == index ? true : false
            }
            
            // switch to 'playing'
            //episodeStructure[index].isPlaying = true
            
            // play segment
            await AudioManager.shared.playAudio(audioUrl: audioUrl)
            
            // when returning, switch to 'not playing'
            episodeStructure[currentIndex].isPlaying = false
            
        } else { // segment is currently playing
            
            // switch to 'not playing'
            episodeStructure[currentIndex].isPlaying = false
        }
        
    }
    
    func buildAudio() {
        print("Build audio pressed")
  
        // create entire episode
        episodeUrl = AudioManager.shared.createAudioEpisode(basedOnEpisodeStructure: self.episodeStructure)
        print("Audio file saved here: \(String(describing: episodeUrl))")
        
        // publish existance of the new audio URL in viemodel
        episodeAvailable = true
        
//        guard let audioURL = episodeStructure[0].audioURL else {return}
//
//        let processedAudioURL = AudioManager.shared.createDownloadableAudio(audioUrl: audioURL)
//        if let fileUrl = processedAudioURL {
//            print("Audio file saved here: \(fileUrl)")
//        }
    }
    
    private func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }
    
    /// Should the rendered audio be stored?
    private func storageURL(forAudioSegment audioSegment: EpisodeSegment) -> URL {

        let documentsDirectory = getDocumentsDirectory()
        let fileName = "\(audioSegment.id).wav"
        let audioURL = documentsDirectory.appendingPathComponent(fileName)
        return audioURL
    }
    
    private func fileExists(atURL url:URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.path)
    }
}
