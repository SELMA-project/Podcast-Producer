//
//  EpisodeViewModel.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 09.08.22.
//

import Foundation


@MainActor
class EpisodeViewModel: ObservableObject {
    
    @Published var chosenEpisodeIndex: Int = 0
    @Published var availableEpisodes: [Episode]
    @Published var episodeAvailable: Bool = false
    
    // the entire episode in segments
    @Published var episodeStructure: [BuildingBlock] = []
    
    @Published var speaker = SelmaVoice(.leila) {
        willSet(newValue) {
            if newValue != speaker {
                //print("New speaker: \(speaker)")
                removeAudio(inEpisodeStructure: episodeStructure)
            }
        }
    }
    
    var episodeUrl: URL = Bundle.main.url(forResource: "no-audio.m4a", withExtension: nil)!
    
    init() {
        
        // test available scripts
        ScriptParser.test()

        // build array of locallay available scripts
        let fileNames = ScriptParser.availableScriptNames()
        
        // prepare result
        availableEpisodes = [Episode]()
        
        // add episodes for each filename
        for fileName in fileNames {
            let episode = Episode.buildFromScript(fileName)
            availableEpisodes.append(episode)
        }

    }
    

    
    
    func buildEpisodeStructure() {

        // result
        var structure = [BuildingBlock]()
        
        // episode to build
        let chosenEpisode = availableEpisodes[chosenEpisodeIndex]
        
        // array of all ids
        //let allIdentifiers = BlockIdentifier.allCases
        
        //var newEpisodeSegments: [BuildingBlock]
        
        for episodeSection in chosenEpisode.sections {
            
            switch episodeSection.type {
            case .standard:
                let name = episodeSection.name
                
                // FIXME: this should become obsolete
                // deduce block identifier form name
                let blockIdentifier: BlockIdentifier
                switch name {
                
                case "Introduction":
                    blockIdentifier = .introduction
                
                case "Epilog":
                    blockIdentifier = .epilogue
                
                default:
                    blockIdentifier = .unknown
                }
                
                let text = episodeSection.text
                let textWithReplacedPlaceholders = replacePlaceholders(inText: text)
                let buildingBlock = BuildingBlock(blockIdentifier: blockIdentifier, text: textWithReplacedPlaceholders)
                structure.append(buildingBlock)
                
            case .headlines:
                for (index, story) in chosenEpisode.stories.enumerated() {
                    if story.usedInIntroduction {
                        let buildingBlock = BuildingBlock(blockIdentifier: .headline, subIndex: index, text: story.headline, highlightInSummary: story.usedInIntroduction)
                        structure.append(buildingBlock)
                    }
                }

            case .stories:
                for (index, story) in chosenEpisode.stories.enumerated() {
                    let storyText = story.storyText
                    let buildingBlock = BuildingBlock(blockIdentifier: .story, subIndex: index, text: storyText)
                    structure.append(buildingBlock)
                }
                
            }
        
        }
        
        
//        for segmentIdentifier in allIdentifiers {
//
//            // reset
//            newEpisodeSegments = []
//
//            switch segmentIdentifier {
//            case .introduction:
//                let text = chosenEpisode.introductionText
//                let textWithReplacedPlaceholders = replacePlaceholders(inText: text)
//                print("\n\(textWithReplacedPlaceholders)")
//                newEpisodeSegments = [BuildingBlock(blockIdentifier: .introduction, text: textWithReplacedPlaceholders)]
//            case .headline:
//                for (index, story) in chosenEpisode.stories.enumerated() {
//                    if story.usedInIntroduction {
//                        newEpisodeSegments.append(BuildingBlock(blockIdentifier: .headline, subIndex: index, text: story.headline, highlightInSummary: story.usedInIntroduction))
//                    }
//                }
//            case .story:
//                for (index, story) in chosenEpisode.stories.enumerated() {
//                    let storyText = story.storyText
//                    newEpisodeSegments.append(BuildingBlock(blockIdentifier: .story, subIndex: index, text: storyText))
//                }
//            case .epilogue:
//                newEpisodeSegments = [BuildingBlock(blockIdentifier: .epilogue, text: chosenEpisode.epilog)]
//            default:
//                break
//            }
//
//            // add the new segment(s) to structure
//            structure.append(contentsOf: newEpisodeSegments)
//        }
        
        // publish
        self.episodeStructure = structure
    }


    
    func renderEpisodeStructure() async {
        
        for (index, audioSegment) in episodeStructure.enumerated() {
            print("Cancel status: \(Task.isCancelled)")
            print("Rendering: \(index) -> \(audioSegment.blockIdentifier.rawValue)")
            
            // the text to render
            let text = audioSegment.text
            
            // where should the rendered audio be stored?
            let audioURL = storageURL(forAudioSegment: audioSegment)
            
            // render audio if it does not yet exist
            var success = true
            if !fileExists(atURL: audioURL) {
                success = await AudioManager.shared.synthesizeAudio(speakerName: speaker.selmaName, text: text, toURL: audioURL)
            }
            
            // store audio URL
            if success {
                episodeStructure[index].audioURL = audioURL
            } else {
                print("No audio data available.")
            }
            
        }
        
    }
    
    
    func playButtonPressed(forSegment audioSegment: BuildingBlock) async {

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
    
    private func indexOfEpisodeSection(withId relevantId: UUID) -> Int? {
        
        // which episode are we currently working with?
        let chosenEpisode = availableEpisodes[chosenEpisodeIndex]
        
        // get its sections
        let sections = chosenEpisode.sections
    
        // find episode index for given id
        let episodeIndex = sections.firstIndex(where:  {$0.id == relevantId})
        
        return episodeIndex
    }
    

    /// Updates the currently chosen episode. The non-nil attributes of the episode's section, identified by *sectionId*, are updated.
    func updateEpisodeSection(sectionId: UUID,
                              newName: String? = nil,
                              newText: String? = nil,
                              newPrefixAudioFile: AudioManager.AudioFile? = nil,
                              newMainAudioFile: AudioManager.AudioFile? = nil,
                              newSuffixAudioFile: AudioManager.AudioFile? = nil) {
        
        // which episode are we currently working with?
        let chosenEpisode = availableEpisodes[chosenEpisodeIndex]
        
        // get its sections
        let sections = chosenEpisode.sections
        
        // get the section's index
        if let episodeIndex = indexOfEpisodeSection(withId: sectionId) {
            // the section itself
            let section = sections[episodeIndex]
            
            // copy ther section
            var updatedSection = section
            
            // update properties if they exist
            if let newName {updatedSection.name = newName}
            if let newText {updatedSection.text = newText}
            if let newPrefixAudioFile {updatedSection.prefixAudioFile = newPrefixAudioFile}
            if let newMainAudioFile {updatedSection.mainAudioFile = newMainAudioFile}
            if let newSuffixAudioFile {updatedSection.suffixAudioFile = newSuffixAudioFile}
            
            // write back to array of sections
            availableEpisodes[chosenEpisodeIndex].sections[episodeIndex] = updatedSection
            
        }
        
    }
    
    
    
    
    private func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }
    
    /// Should the rendered audio be stored?
    private func storageURL(forAudioSegment audioSegment: BuildingBlock) -> URL {

        let documentsDirectory = getDocumentsDirectory()
        let fileName = "\(audioSegment.id).wav"
        let audioURL = documentsDirectory.appendingPathComponent(fileName)
        return audioURL
    }
    
    private func fileExists(atURL url:URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    /// Remove all rendered audio pointed to by the episode structure
    private func removeAudio(inEpisodeStructure episodeStructure: [BuildingBlock]) {
        
        var newEpisodeStructure = [BuildingBlock]()
        
        for segment in episodeStructure {
            
            // make a copy
            var newSegment = segment
            
            if let audioURL = newSegment.audioURL {
                
                // remove audio
                try? FileManager.default.removeItem(at: audioURL)
                
                // set audio URL to nil
                newSegment.audioURL = nil
            }
            
            // store in new episode structure
            newEpisodeStructure.append(newSegment)
        }
        
        // update structure
        self.episodeStructure = newEpisodeStructure
        
    }
    
    /// Replaces all place holders
    private func replacePlaceholders(inText text: String) -> String {
        let newText = text.replacing("{speakerName}", with: speaker.fullName)
        return newText
    }
}
