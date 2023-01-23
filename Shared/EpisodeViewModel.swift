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
    
    @Published var chosenEpisodeIndex: Int?
    @Published var availableEpisodes: [Episode] = []
    //@Published var episodeAvailable: Bool = false
    
    @Published var chosenEpisode: Episode = Episode.standard // default value to avoid making this optional
    
    // the entire episode in segments
    //@Published var episodeStructure: [BuildingBlock] = []
    
    // the narrator name use when creating a new template. Is stored in user defaults.
    @Published var newTemplateNarratorName: String = "" {
        didSet {
            
            // store in user defaults
            UserDefaults.standard.set(newTemplateNarratorName, forKey: "newTemplateNarratorName")
            
            // set in current chosenEpisode
            //chosenEpisode.narrator = narratorName
        }
    }
    
    //var episodeUrl: URL = Bundle.main.url(forResource: "no-audio.m4a", withExtension: nil)!
    
    // this is used in combine
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        
        // restore UserDefaults
        newTemplateNarratorName = UserDefaults.standard.string(forKey: "newTemplateNarratorName") ?? ""
        
        // linking published properties via subscriptions
        
        // update $chosenEpisode when chosenEpisodeIndex changes
        $chosenEpisodeIndex.sink { newEpisodeIndex in
            if let newEpisodeIndex {
                if self.availableEpisodes.count > newEpisodeIndex {
                    self.chosenEpisode = self.availableEpisodes[newEpisodeIndex]
                }
            }
        }.store(in: &subscriptions)
        
        // if $chosenEpisode changes, update this episode in the array of availableEpisodes
        $chosenEpisode.sink { newEpisode in
            if let chosenEpisodeIndex = self.chosenEpisodeIndex {
                if self.availableEpisodes.count > chosenEpisodeIndex {
                    self.availableEpisodes[chosenEpisodeIndex] = newEpisode
                }
            }
                        
        }.store(in: &subscriptions)
        

        
        // test available scripts
        //ScriptParser.test()

        // build array of locallay available scripts
        //let fileNames = ScriptParser.availableScriptNames()
        
        // we start with an empty array of available episodes
        availableEpisodes = [Episode]()
        
        // add episodes for each filename
//        for (index, fileName) in fileNames.enumerated() {
//            if index == 0 {
//                //addEpisode(parsedFromGithubScriptName: fileName)
//            }
//        }

        // sort available episodes by date
//        availableEpisodes.sort { e0, e1 in
//            return e0.creationDate > e1.creationDate
//        }
        
        // chose first episode
        //chosenEpisodeIndex = 0
        
    }
    
    /// Uses the given template to create a new episode and adds it to the array of available Episodes
    func addEpisode(basedOnTemplate template: EpisodeTemplate) {
        
        // create episode
        let newEpisode = Episode.buildFromTemplate(template, narrator: newTemplateNarratorName)
        
        // add to existing episodes
        availableEpisodes.append(newEpisode)
    }
    
    /// Generates a new episode based on the given Github script and adds it to the array of available Episodes
    func addEpisode(parsedFromGithubScriptName scriptName: String) {
        
        // parse
        let newEpisode = Episode.buildFromScript(scriptName)
                
        // does an episode with the same creation Date already exist
        let matchingEpisodeIndex = availableEpisodes.firstIndex {$0.creationDate == newEpisode.creationDate}
                
        // if we have a matching episode, replace it
        if let matchingEpisodeIndex {
            availableEpisodes[matchingEpisodeIndex] = newEpisode
            
        } else { // otherwise add as new episode
            
            // add to existing episodes
            availableEpisodes.append(newEpisode)
        }
    }
    
    func appendEmptyStoryToChosenEpisode() {
        let story = Story(usedInIntroduction: true, headline: "", storyText: "")
        
        chosenEpisode.stories.append(story)

        //episode.stories = stories
    }
    
    
    /// Called when ContentView appears
    func runStartupRoutine() {
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        
        print("Documents are in: \(documentsDir)")
        print("Caches are in: \(cachesDir)")
                
        //AudioManager.shared.deleteCachedFiles()
    }
    
 

    
    /// Called when play button is sectionEditView is pressed
    func renderEpisodeSection(withId episodeId: UUID) async -> URL? {
    
        var sectionAudioUrl: URL?
        
        // get the section's index
        if let episodeIndex = indexOfEpisodeSection(withId: episodeId) {
            
            // create an audio episode which just contains the episode we want to preview
            sectionAudioUrl = await AudioManager.shared.createAudioEpisodeBasedOnEpisode(chosenEpisode, selectedSectionIndex: episodeIndex)
        }
        
        return sectionAudioUrl
    }
    
    /// Called by the PodcastRenderView to render the entire episode
    func renderEpisode() async -> URL {
        
        let episodeUrl = await AudioManager.shared.createAudioEpisodeBasedOnEpisode(chosenEpisode, selectedSectionIndex: nil)
        print("Audio file saved here: \(String(describing: episodeUrl))")
        
        return episodeUrl
    }
    
    /// Play audio at the given URL
    func playAudioAtURL(_ audioURL: URL) async {
        // play segment
        await AudioManager.shared.playAudio(audioUrl: audioURL)
    }
    
    /// Stop audio playback
    func stopAudioPlayback() {
        AudioManager.shared.stopAudio()
    }
    
    /// Returns the index of the given section within the current chosenEpisode
    private func indexOfEpisodeSection(withId relevantId: UUID) -> Int? {
        
        guard let chosenEpisodeIndex else {return nil}
        
        // which episode are we currently working with?
        let chosenEpisode = availableEpisodes[chosenEpisodeIndex]
        
        // get its sections
        let sections = chosenEpisode.sections
    
        // find episode index for given id
        let episodeIndex = sections.firstIndex(where:  {$0.id == relevantId})
        
        return episodeIndex
    }
    
    
    /// Called by StoryEditView to update story details for given storyId inside the chosenEpisode
    func updateEpisodeStory(storyId: UUID, newHeadline: String? = nil, newText: String? = nil, markAsHighlight: Bool? = nil) {
                
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
            chosenEpisode.stories = updatedStories
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
        
        // get its sections
        var sections = chosenEpisode.sections
        
        // get the section's index
        if let sectionIndex = indexOfEpisodeSection(withId: sectionId) {
            // the section itself
            let section = sections[sectionIndex]
            
            // copy the section
            var updatedSection = section
            
            // update properties if they exist
            if let newName {updatedSection.name = newName}
            if let newText {updatedSection.rawText = newText}
            if let newPrefixAudioFile {updatedSection.prefixAudioFile = newPrefixAudioFile}
            if let newMainAudioFile {updatedSection.mainAudioFile = newMainAudioFile}
            if let newSuffixAudioFile {updatedSection.suffixAudioFile = newSuffixAudioFile}
            if let newSeparatorAudioFile {updatedSection.separatorAudioFile = newSeparatorAudioFile}
            
            // write back to array of sections
            sections[sectionIndex] = updatedSection
            
            // write sections back to chosenEpisode
            chosenEpisode.sections = sections
        }
        
    }
    

    /// Tells the caller whether a URL exists at the given location
//    private func fileExists(atURL url:URL) -> Bool {
//        return FileManager.default.fileExists(atPath: url.path)
//    }
    
 
    
}



//// MARK: - Legacy BuildingBlock Code
//// this should be obsolete soon
//extension EpisodeViewModel {
//
////    /// Called when 'Create Audio' button is pressed in AudioRenderView
////    func buildAudio() async {
////
////        // create entire episode
////        let episode = self.availableEpisodes[chosenEpisodeIndex]
////        episodeUrl = await AudioManager.shared.createAudioEpisodeBasedOnEpisode(episode, selectedSectionIndex: nil)
////        print("Audio file saved here: \(String(describing: episodeUrl))")
////
////        // publish existance of the new audio URL in viewmodel
////        episodeAvailable = true
////    }
//
//    /// Remove all rendered audio pointed to by the episode structure
//    /// Thids might be obsolte, as there is no caller
//    private func removeAudio(inEpisodeStructure episodeStructure: [BuildingBlock]) {
//
//        var newEpisodeStructure = [BuildingBlock]()
//
//        for segment in episodeStructure {
//
//            // make a copy
//            let newSegment = segment
//
//            if let audioURL = newSegment.audioURL {
//
//                // remove audio
//                try? FileManager.default.removeItem(at: audioURL)
//
//                // mark audio as not rendered
//                //newSegment.audioIsRendered = false
//            }
//
//            // store in new episode structure
//            newEpisodeStructure.append(newSegment)
//        }
//
//        // update structure
//        self.episodeStructure = newEpisodeStructure
//
//    }
//
//
//    func buildEpisodeStructure() {
//
//        // result
//        var structure = [BuildingBlock]()
//
//        // episode to build
//       // let chosenEpisode = availableEpisodes[chosenEpisodeIndex]
//
//        for episodeSection in chosenEpisode.sections {
//
//            // calculate the section's audio URL the section type and the text
//            let episodeSectionText = chosenEpisode.replaceTokens(inText: episodeSection.rawText)
//            //let episodeSectionType = episodeSection.type
//            let textAudioURL = chosenEpisode.textAudioURL(forSection: episodeSection)
//
//            switch episodeSection.type {
//            case .standard:
//                let name = episodeSection.name
//
//                // FIXME: this should become obsolete
//                // deduce block identifier from name
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
//                // calculate the section's audio URL the section type and the text
//                //let textAudioURL = chosenEpisode.textAudioURL(forSectionType: episodeSectionType, textContent: episodeSectionText)
//
//                let buildingBlock = BuildingBlock(blockIdentifier: blockIdentifier, audioURL: textAudioURL, text: episodeSectionText)
//                structure.append(buildingBlock)
//
//            case .headlines:
//
//                // add headlines text if present
//                if episodeSectionText.count > 0 {
//                    //let textAudioURL = episodeSection.textAudioURL
//                    let buildingBlock = BuildingBlock(blockIdentifier: .introduction, audioURL: textAudioURL, text: episodeSectionText)
//                    structure.append(buildingBlock)
//                }
//
//                for (index, story) in chosenEpisode.stories.enumerated() {
//                    if story.usedInIntroduction || !chosenEpisode.restrictHeadlinesToHighLights {
//                        let storyHeadline = story.headline
//                        let proposedHeadlineAudioUrl = chosenEpisode.headlineAudioURL(forStory: story)
//                        let buildingBlock = BuildingBlock(blockIdentifier: .headline, subIndex: index, audioURL: proposedHeadlineAudioUrl, text: storyHeadline, highlightInSummary: story.usedInIntroduction)
//                        structure.append(buildingBlock)
//                    }
//                }
//
//            case .stories:
//
//                // add headlines text if present
//                if episodeSectionText.count > 0 {
//                    //let textAudioURL = episodeSection.textAudioURL
//                    let buildingBlock = BuildingBlock(blockIdentifier: .introduction, audioURL: textAudioURL, text: episodeSectionText)
//                    structure.append(buildingBlock)
//                }
//
//                for (index, story) in chosenEpisode.stories.enumerated() {
//                    let storyText = story.storyText
//                    let proposedTextAudioUrl = chosenEpisode.storyTextAudioURL(forStory: story)
//                    let buildingBlock = BuildingBlock(blockIdentifier: .story, subIndex: index, audioURL: proposedTextAudioUrl, text: storyText)
//                    structure.append(buildingBlock)
//                }
//
//            }
//
//        }
//
//        // publish
//        self.episodeStructure = structure
//    }
//
//
//    func renderEpisodeStructure() async {
//
//        for (index, audioSegment) in episodeStructure.enumerated() {
//            print("Cancel status: \(Task.isCancelled)")
//            print("Rendering: \(index) -> \(audioSegment.blockIdentifier.rawValue)")
//
//            // render audio -> this updates the audio segment's property 'audioISRendered'
//            let updatedAudioSegment = await renderAudioInBuildingBlock(audioSegment)
//
//            // replace original block
//            episodeStructure[index] = updatedAudioSegment
//
//        }
//
//    }
//
//
//    /// Synthesizes audio for provided building block.
//    private func renderAudioInBuildingBlock(_ buildingBlock:  BuildingBlock) async -> BuildingBlock  {
//
//        // copy original building block to be able to update the audioURL
//        let updatedBuildingBlock = buildingBlock
//
//        // early exit if we don't have an audioURL (this should not happen, as the URL is proposed by the episode in buildEpisodeStructure()
//        guard let audioURL = buildingBlock.audioURL else {return updatedBuildingBlock}
//
//        // the text to render
//        let text = buildingBlock.text
//
//        // the speaker identifier
//        let podcastVoice = chosenEpisode.podcastVoice
//
//        // render audio if it does not yet exist
//        var success = true
//        if !fileExists(atURL: audioURL) {
//            success = await AudioManager.shared.synthesizeSpeech(podcastVoice: podcastVoice, text: text, toURL: audioURL)
//        }
//
//        if !success {
//            print("No audio data available.")
//        }
//
////        if success {
////            //episodeStructure[index].audioURL = audioURL
////            //updatedBuildingBlock.audioURL = audioURL
////            //updatedBuildingBlock.audioIsRendered = true
////        } else {
////
////        }
//
//        return updatedBuildingBlock
//    }
//
//
//
//    func playButtonPressed(forSegment audioSegment: BuildingBlock) async {
//
//        // find index of given audioSegment in array
//        let currentIndex = episodeStructure.firstIndex { segment in
//            segment.id == audioSegment.id
//        }
//
//        // early return if no index was found (should not happen)
//        guard let currentIndex = currentIndex else {return}
//
//        // early exit if no audio data is available (should not happen)
//        guard let audioUrl = audioSegment.audioURL else {return}
//
//        // in any case, stop the currently played audio
//        AudioManager.shared.stopAudio()
//
//        // currently not playng, so we want to play
//        if audioSegment.isPlaying == false {
//
//            // switch all audioSegments to 'off' - except the one with the current index
//            for (index, _) in episodeStructure.enumerated() {
//                episodeStructure[index].isPlaying = currentIndex == index ? true : false
//            }
//
//            // switch to 'playing'
//            //episodeStructure[index].isPlaying = true
//
//            // play segment
//            await AudioManager.shared.playAudio(audioUrl: audioUrl)
//
//            // when returning, switch to 'not playing'
//            episodeStructure[currentIndex].isPlaying = false
//
//        } else { // segment is currently playing
//
//            // switch to 'not playing'
//            episodeStructure[currentIndex].isPlaying = false
//        }
//
//    }
//}
