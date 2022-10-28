//
//  EpisodeViewModel.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 09.08.22.
//

import Foundation
import Combine

@MainActor
class EpisodeViewModel: ObservableObject {
    
    @Published var chosenEpisodeIndex: Int = 0
    @Published var availableEpisodes: [Episode] = []
    @Published var episodeAvailable: Bool = false
    
    @Published var chosenEpisode: Episode = Episode.standard // default value to avoid making this optional
    
    // the entire episode in segments
    @Published var episodeStructure: [BuildingBlock] = []
    
    // TODO: replace removing Audio part
//    @Published var speaker = SelmaVoice(.leila) {
//        willSet(newValue) {
//            if newValue != speaker {
//                //print("New speaker: \(speaker)")
//                removeAudio(inEpisodeStructure: episodeStructure)
//            }
//        }
//    }
//
    var episodeUrl: URL = Bundle.main.url(forResource: "no-audio.m4a", withExtension: nil)!
    
    // this is used in combine
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        
        // linking published properties via subscriptions
        
        // update $chosenEpisode when chosenEpisodeIndex changes
        $chosenEpisodeIndex.sink { newEpisodeIndex in
            if self.availableEpisodes.count > self.chosenEpisodeIndex {
                self.chosenEpisode = self.availableEpisodes[self.chosenEpisodeIndex]
            }
        }.store(in: &subscriptions)
        
        // if $chosenEpisode changes, update this episode in the array of availableEpisodes
        $chosenEpisode.sink { newEpisode in
            if self.availableEpisodes.count > self.chosenEpisodeIndex {
                self.availableEpisodes[self.chosenEpisodeIndex] = newEpisode
            }
        }.store(in: &subscriptions)
        
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

        // chose first episode
        chosenEpisodeIndex = 0
        
    }
    
    // WARNING: Probably obsolete
//    func buildAndRenderEpisodeStructure() async {
//        
//        // result
//        var structure = [BuildingBlock]()
//        
//        // episode to build
//        let chosenEpisode = availableEpisodes[chosenEpisodeIndex]
//        
//        for episodeSection in chosenEpisode.sections {
//            
//            switch episodeSection.type {
//            case .standard:
//                let name = episodeSection.name
//                
//                // FIXME: this should become obsolete
//                // deduce block identifier form name
//                let blockIdentifier: BlockIdentifier
//                switch name {
//                
//                case "Introduction":
//                    blockIdentifier = .introduction
//                
//                case "Epilog":
//                    blockIdentifier = .epilogue
//                
//                default:
//                    blockIdentifier = .unknown
//                }
//                
//                // text from episode
//                let text = episodeSection.text
//                
//                // replace place holders
//                let textWithReplacedPlaceholders = replacePlaceholders(inText: text)
//                
//                // create building block
//                let buildingBlock = BuildingBlock(blockIdentifier: blockIdentifier, text: textWithReplacedPlaceholders)
//                
//                // render audio -> this updates the buildingBlock's audioURL
//                let updatedBuildingBlock = await renderAudioInBuildingBlock(buildingBlock)
//                
//                // store in structure
//                structure.append(updatedBuildingBlock)
//                
//            case .headlines:
//                for (index, story) in chosenEpisode.stories.enumerated() {
//                    if story.usedInIntroduction {
//                        
//                        // create building block
//                        let buildingBlock = BuildingBlock(blockIdentifier: .headline, subIndex: index, text: story.headline, highlightInSummary: story.usedInIntroduction)
//                        
//                        // render audio -> this updates the buildingBlock's audioURL
//                        let updatedBuildingBlock = await renderAudioInBuildingBlock(buildingBlock)
//                        
//                        structure.append(updatedBuildingBlock)
//                    }
//                }
//
//            case .stories:
//                for (index, story) in chosenEpisode.stories.enumerated() {
//                    
//                    // extract story text
//                    let storyText = story.storyText
//                    
//                    // create building block
//                    let buildingBlock = BuildingBlock(blockIdentifier: .story, subIndex: index, text: storyText)
//                    
//                    // render audio -> this updates the buildingBlock's audioURL
//                    let updatedBuildingBlock = await renderAudioInBuildingBlock(buildingBlock)
//                    
//                    structure.append(updatedBuildingBlock)
//                }
//                
//            }
//        
//        }
//        
//        // publish
//        self.episodeStructure = structure
//    }
    
    
    func buildEpisodeStructure() {

        // result
        var structure = [BuildingBlock]()
        
        // episode to build
        let chosenEpisode = availableEpisodes[chosenEpisodeIndex]
        
        // array of all ids
        //let allIdentifiers = BlockIdentifier.allCases
        
        //var newEpisodeSegments: [BuildingBlock]
        
        // the speaker identifier
        let voiceIdentifier = chosenEpisode.podcastVoice.identifier
        
        for episodeSection in chosenEpisode.sections {
  
            let text = episodeSection.text.trimmingCharacters(in: .whitespacesAndNewlines)
            let textWithReplacedPlaceholders = replacePlaceholders(inText: text)
            
            switch episodeSection.type {
            case .standard:
                let name = episodeSection.name
                
                // FIXME: this should become obsolete
                // deduce block identifier from name
                let blockIdentifier: BlockIdentifier
                switch name {
                
                case "Introduction":
                    blockIdentifier = .introduction
                
                case "Epilog":
                    blockIdentifier = .epilogue
                
                default:
                    blockIdentifier = .unknown
                }
                
                // get the section's audio URL based on the voice Id, the section type and the text
                let textAudioURL = Episode.textAudioURL(forSectionType: episodeSection.type, voiceIndentifier: voiceIdentifier, textContent: episodeSection.text)
                
                let buildingBlock = BuildingBlock(blockIdentifier: blockIdentifier, audioURL: textAudioURL, text: textWithReplacedPlaceholders)
                structure.append(buildingBlock)
                
            case .headlines:
                
                // add headlines text if present
                if textWithReplacedPlaceholders.count > 0 {
                    let textAudioURL = Episode.textAudioURL(forSectionType: episodeSection.type, voiceIndentifier: voiceIdentifier, textContent: episodeSection.text)
                    let buildingBlock = BuildingBlock(blockIdentifier: .introduction, audioURL: textAudioURL, text: textWithReplacedPlaceholders)
                    structure.append(buildingBlock)
                }
                
                for (index, story) in chosenEpisode.stories.enumerated() {
                    if story.usedInIntroduction || !chosenEpisode.restrictHeadlinesToHighLights {
                        let storyHeadline = story.headline
                        let proposedHeadlineAudioUrl = Episode.textAudioURL(forSectionType: episodeSection.type, voiceIndentifier: voiceIdentifier, textContent: storyHeadline)
                        let buildingBlock = BuildingBlock(blockIdentifier: .headline, subIndex: index, audioURL: proposedHeadlineAudioUrl, text: storyHeadline, highlightInSummary: story.usedInIntroduction)
                        structure.append(buildingBlock)
                    }
                }

            case .stories:
                
                // add headlines text if present
                if textWithReplacedPlaceholders.count > 0 {
                    let textAudioURL = Episode.textAudioURL(forSectionType: episodeSection.type, voiceIndentifier: voiceIdentifier, textContent: episodeSection.text)
                    let buildingBlock = BuildingBlock(blockIdentifier: .introduction, audioURL: textAudioURL, text: textWithReplacedPlaceholders)
                    structure.append(buildingBlock)
                }
                
                for (index, story) in chosenEpisode.stories.enumerated() {
                    let storyText = story.storyText
                    let proposedTextAudioUrl = Episode.textAudioURL(forSectionType: episodeSection.type, voiceIndentifier: voiceIdentifier, textContent: storyText)
                    let buildingBlock = BuildingBlock(blockIdentifier: .story, subIndex: index, audioURL: proposedTextAudioUrl, text: storyText)
                    structure.append(buildingBlock)
                }
                
            }
        
        }
        
        // publish
        self.episodeStructure = structure
    }


    func renderEpisodeStructure() async {
        
        for (index, audioSegment) in episodeStructure.enumerated() {
            print("Cancel status: \(Task.isCancelled)")
            print("Rendering: \(index) -> \(audioSegment.blockIdentifier.rawValue)")
  
            // render audio -> this updates the audio segment's property 'audioISRendered'
            let updatedAudioSegment = await renderAudioInBuildingBlock(audioSegment)
            
            // replace original block
            episodeStructure[index] = updatedAudioSegment
                        
        }
        
    }
        
    
    /// Synthesizes audio for provided building block. If successful, the returned block  is marked with auddioISRendered = true
    private func renderAudioInBuildingBlock(_ buildingBlock:  BuildingBlock) async -> BuildingBlock  {
        
        // copy original building block to be able to update the audioURL
        var updatedBuildingBlock = buildingBlock

        // where should the rendered audio be stored?
        //let audioURL = storageURL(forAudioSegment: buildingBlock)
        
        // early exit if we don't have an audioURL (this should not happen, as the URL is proposed by the episode in buildEpisodeStructure()
        guard let audioURL = buildingBlock.audioURL else {return updatedBuildingBlock}
        
        // the text to render
        let text = buildingBlock.text
        
        // the speaker identifier
        let podcastVoice = chosenEpisode.podcastVoice
        
        // render audio if it does not yet exist
        var success = true
        if !fileExists(atURL: audioURL) {
            success = await AudioManager.shared.synthesizeAudio(podcastVoice: podcastVoice, text: text, toURL: audioURL)
        }
        
        if !success {
            print("No audio data available.")
        }

//        if success {
//            //episodeStructure[index].audioURL = audioURL
//            //updatedBuildingBlock.audioURL = audioURL
//            //updatedBuildingBlock.audioIsRendered = true
//        } else {
//
//        }
        
        return updatedBuildingBlock
    }
    
    
    func playButtonPressed(forSegment audioSegment: BuildingBlock) async {

        // find index of given audioSegment in array
        let currentIndex = episodeStructure.firstIndex { segment in
            segment.id == audioSegment.id
        }
        
        // early return if no index was found (should not happen)
        guard let currentIndex = currentIndex else {return}
        
        // early exit if no audio data is available (should not happen)
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
        //episodeUrl = AudioManager.shared.createAudioEpisode(basedOnBuildingBlocks: self.episodeStructure)
        let episode = self.availableEpisodes[chosenEpisodeIndex]
        episodeUrl = AudioManager.shared.createAudioEpisodeBasedOnEpisode(episode)
        print("Audio file saved here: \(String(describing: episodeUrl))")
        
        // publish existance of the new audio URL in viewmodel
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
    
    func updateEpisodeStory(storyId: UUID, newHeadline: String? = nil, newText: String? = nil, markAsHighlight: Bool? = nil) {
        
        // which episode are we currently working with?
        let chosenEpisode = availableEpisodes[chosenEpisodeIndex]
        
        // associated stories
        let stories = chosenEpisode.stories
        
        // copy them
        var updatedStories = stories
        
        // index for given storyId
        if let storyIndex = stories.firstIndex(where:  {$0.id == storyId}) {
            
            // get a copy the story itself
            var updatedStory = stories[storyIndex]
            
            // update properties if they exist
            if let newHeadline {updatedStory.headline = newHeadline}
            if let newText {updatedStory.storyText = newText}
            if let markAsHighlight {updatedStory.usedInIntroduction = markAsHighlight}
            
            // update array of stories
            updatedStories[storyIndex] = updatedStory
            
            // update episode with new stories
            availableEpisodes[chosenEpisodeIndex].stories = updatedStories
            
        }
        
    }
    

    /// Updates the currently chosen episode. The non-nil attributes of the episode's section, identified by *sectionId*, are updated.
    func updateEpisodeSection(sectionId: UUID,
                              newName: String? = nil,
                              newText: String? = nil,
                              newPrefixAudioFile: AudioManager.AudioFile? = nil,
                              newMainAudioFile: AudioManager.AudioFile? = nil,
                              newSuffixAudioFile: AudioManager.AudioFile? = nil,
                              newSeparatorAudioFile: AudioManager.AudioFile? = nil) {
        
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
            if let newSeparatorAudioFile {updatedSection.separatorAudioFile = newSeparatorAudioFile}
            
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
                
                // mark audio as not rendered
                //newSegment.audioIsRendered = false
            }
            
            // store in new episode structure
            newEpisodeStructure.append(newSegment)
        }
        
        // update structure
        self.episodeStructure = newEpisodeStructure
        
    }
    
    /// Replaces all place holders
    private func replacePlaceholders(inText text: String) -> String {
        let narratorName = chosenEpisode.podcastVoice.name
        let newText = text.replacing("{speakerName}", with: narratorName)
        return newText
    }
}
