//
//  EpisodeViewModel.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 09.08.22.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class EpisodeViewModel: ObservableObject {
    
    @Published var navigationPath = NavigationPath()
    @Published var availableEpisodes: [Episode] = []

    subscript(episodeIndex: Int?) -> Episode {
        get {
            if let index = episodeIndex {
                if availableEpisodes.count > index {
                    return availableEpisodes[index]
                }
            }
            return Episode.standard
        }
        set {
            if let index = episodeIndex {
                availableEpisodes[index] = newValue
                
                // save episodes to disk whenever the array changes
                saveEpisodes()
            }
        }
    }
        
    
    // the narrator name use when creating a new template. Is stored in user defaults.
    var newTemplateNarratorName: String = "" {
        willSet {
            objectWillChange.send()
        }
        didSet {
            
            // store in user defaults
            UserDefaults.standard.set(newTemplateNarratorName, forKey: "newTemplateNarratorName")
            
            // set in current chosenEpisode
            //chosenEpisode.narrator = narratorName
        }
    }
        
    /// The URL under which the all Episode data is stored
    private var episodeDataURL: URL {
        let fileName = "episodeData.json"
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileUrl = documentsDir.appending(path: fileName)
        return fileUrl
    }
    
    
    // this is used in combine
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        
        // restore UserDefaults
        newTemplateNarratorName = UserDefaults.standard.string(forKey: "newTemplateNarratorName") ?? ""
        
        // linking published properties via subscriptions
        
        // load episode data - if there is any
        if let episodesFromDisk = loadEpisodes() {
            self.availableEpisodes = episodesFromDisk
        } else {
            // if no data is avaiable from disk we start with an empty array of available episodes
            self.availableEpisodes = [Episode]()
        }
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
    
    func appendEmptyStoryToChosenEpisode(chosenEpisodeIndex: Int?) -> Int {
                
        let storyNumber =  self[chosenEpisodeIndex].stories.count + 1
        
        // create empty story
        let story = Story(usedInIntroduction: true, headline: "Headline \(storyNumber)", storyText: "")
        
        // add  to chosen episode
        self[chosenEpisodeIndex].stories.append(story)
        
        return self[chosenEpisodeIndex].stories.endIndex - 1
    }
        
    /// Save all availableEpisodes to disk as JSON
    private func saveEpisodes() {
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(availableEpisodes) {
            
            do {
                try encoded.write(to: self.episodeDataURL)
                print("Saved episode data to disk: \(self.episodeDataURL)")
            } catch {
                print("Error while saving episode data to disk: \(error)")
            }
            
        }
        
    }
    
    /// Load all availableEpisodes from disk as JSON
    func loadEpisodes() -> [Episode]? {
        
        var result: [Episode]?
        
        let decoder = JSONDecoder()
        
        do {
            let episodeData = try Data(contentsOf: self.episodeDataURL)
            
            if let decoded = try? decoder.decode([Episode].self, from: episodeData) {
                result = decoded
            }
            
        } catch {
            print("Error while reading episode data to disk: \(error)")
        }
        
        return result
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
    func renderEpisodeSection(chosenEpisodeIndex: Int?, sectionId: UUID) async -> URL? {
    
        var sectionAudioUrl: URL?
        
        // get the section's index
        if let episodeIndex = indexOfEpisodeSection(chosenEpisodeIndex: chosenEpisodeIndex, relevantId: sectionId) {
            
            // create an audio episode which just contains the episode we want to preview
            let chosenEpisode = self[chosenEpisodeIndex]
            sectionAudioUrl = await AudioManager.shared.createAudioEpisodeBasedOnEpisode(chosenEpisode, selectedSectionIndex: episodeIndex)
        }
        
        return sectionAudioUrl
    }
    
    /// Called by the PodcastRenderView to render the entire episode
    func renderEpisode(chosenEpisodeIndex: Int?) async -> URL {
        
        let chosenEpisode = self[chosenEpisodeIndex]
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
    private func indexOfEpisodeSection(chosenEpisodeIndex: Int?, relevantId: UUID) -> Int? {
        
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
    func updateEpisodeStory(chosenEpisodeIndex: Int?, storyId: UUID, newHeadline: String? = nil, newText: String? = nil, markAsHighlight: Bool? = nil) {
                
        // associated stories
        let stories = self[chosenEpisodeIndex].stories
        
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
            self[chosenEpisodeIndex].stories = updatedStories
        }
        
    }
    

    /// Updates the currently chosen episode. The non-nil attributes of the episode's section, identified by *sectionId*, are updated.
    func updateEpisodeSection(chosenEpisodeIndex: Int?,
                              sectionId: UUID,
                              newName: String? = nil,
                              newText: String? = nil,
                              newPrefixAudioFile: AudioManager.AudioFile? = nil,
                              newMainAudioFile: AudioManager.AudioFile? = nil,
                              newSuffixAudioFile: AudioManager.AudioFile? = nil,
                              newSeparatorAudioFile: AudioManager.AudioFile? = nil) {
        
        // get its sections
        var sections = self[chosenEpisodeIndex].sections
        
        // get the section's index
        if let sectionIndex = indexOfEpisodeSection(chosenEpisodeIndex: chosenEpisodeIndex, relevantId: sectionId) {
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
            self[chosenEpisodeIndex].sections = sections
        }
        
    }
    
}

