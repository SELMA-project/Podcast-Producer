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

    subscript(episodeId: UUID?) -> Episode {
        get {
            if let episodeId {
                if let episode = availableEpisodes.first(where: {$0.id == episodeId}) {
                    return episode
                }
            }
            return Episode.standard
        }
        set {
            if let episodeIndex = episodeIndexForId(episodeId: episodeId) {
                availableEpisodes[episodeIndex] = newValue
            }
            
            // save episodes to disk whenever the array changes
            saveEpisodes()
        }
    }
    
    // returns index inside availableEpisodes for given id
    func episodeIndexForId(episodeId: UUID?) -> Int? {
        return availableEpisodes.firstIndex(where: {$0.id == episodeId})
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
    
    /// The id of the first episode
    var firstEpisodeId: UUID? {
        
        var firstEpisodeId: UUID? = nil
        if availableEpisodes.count > 0 {
            firstEpisodeId = availableEpisodes[0].id
        }
        return firstEpisodeId
    }
    
        
    init(createPlaceholderEpisode: Bool = false) {
        
        // restore UserDefaults
        newTemplateNarratorName = UserDefaults.standard.string(forKey: "newTemplateNarratorName") ?? ""
                
        // load episode data - if there is any
        if let episodesFromDisk = loadEpisodes() {
            self.availableEpisodes = episodesFromDisk
        } else {
            // if no data is avaiable from disk we start with an empty array of available episodes
            self.availableEpisodes = [Episode]()
        }
        
        // if there are no episodes -> create an english episode and append it to the list of episodes
        if createPlaceholderEpisode && self.availableEpisodes.count == 0 {
            let template = TemplateManager.shared.availableTemplates(forLanguage: .english)[0]
            addEpisode(basedOnTemplate: template)
        }
    }
    
    /// Uses the given template to create a new episode and adds it to the array of available Episodes
    func addEpisode(basedOnTemplate template: EpisodeTemplate) {
        
        // create episode
        let newEpisode = Episode.buildFromTemplate(template, narrator: newTemplateNarratorName)
        
        // add to existing episodes
        availableEpisodes.append(newEpisode)
        
        // save
        saveEpisodes()
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
        
        // save
        saveEpisodes()
    }
    
    func appendEmptyStoryToChosenEpisode(chosenEpisodeId: UUID?) -> Story.StoryId {
                
        let storyNumber =  self[chosenEpisodeId].stories.count + 1
        
        // create empty story
        let headline = "" //"Headline \(storyNumber)"
        let storyText = ""
        let story = Story(usedInIntroduction: true, headline: headline, storyText: storyText)
        
        // add  to chosen episode
        self[chosenEpisodeId].stories.append(story)
        
        return story.id
    }
        
    /// Save all availableEpisodes to disk as JSON
    func saveEpisodes() {
        
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
    func renderEpisodeSection(chosenEpisodeId: UUID?, sectionId: EpisodeSection.SectionId) async -> URL? {
    
        var sectionAudioUrl: URL?
        
        // get the section's index
        if let episodeSectionIndex = indexOfEpisodeSection(chosenEpisodeId: chosenEpisodeId, relevantId: sectionId) {
            
            // create an audio episode which just contains the episode we want to preview
            let chosenEpisode = self[chosenEpisodeId]
            sectionAudioUrl = await AudioManager.shared.createAudioEpisodeBasedOnEpisode(chosenEpisode, selectedSectionIndex: episodeSectionIndex)
        }
        
        return sectionAudioUrl
    }
    
    /// Called by the PodcastRenderView to render the entire episode
    func renderEpisode(chosenEpisodeId: UUID?) async -> URL {
        
        let chosenEpisode = self[chosenEpisodeId]
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
    private func indexOfEpisodeSection(chosenEpisodeId: UUID?, relevantId: EpisodeSection.SectionId) -> Int? {
        
        guard let chosenEpisodeId else {return nil}
        
        // which episode are we currently working with?
        let chosenEpisode = self[chosenEpisodeId]
        
        // get its sections
        let sections = chosenEpisode.sections
    
        // find episode index for given id
        let episodeIndex = sections.firstIndex(where:  {$0.id == relevantId})
        
        return episodeIndex
    }
    


}


