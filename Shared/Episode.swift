//
//  Episode.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 09.08.22.
//

import Foundation

enum EpisodeSectionType: String {
    case standard = "Standard"
    case headlines = "Headlines"
    case stories = "Stories"
}

struct EpisodeSection: Identifiable, Hashable {
    var id: UUID = UUID()
    var type: EpisodeSectionType
    var name: String
    var text: String = ""
    var prefixAudioFile: AudioManager.AudioFile = AudioManager.audioFileForDisplayName("None")
    var mainAudioFile: AudioManager.AudioFile = AudioManager.audioFileForDisplayName("None")
    var suffixAudioFile: AudioManager.AudioFile = AudioManager.audioFileForDisplayName("None")
}

struct Episode: Identifiable, Hashable {
    var id: UUID = UUID()
    var language: LanguageManager.Language
    var creationDate: Date
    
    var timeSlot: String {
        return creationDate.formatted(date: .abbreviated, time: .shortened)
    }
    
    var stories: [Story] = [Story]()
    
    
    // the order of all sections
    var sections = [EpisodeSection]()
    
    // adds a new section to the episode
    mutating func addSection(_ section: EpisodeSection) {
        
        sections.append(section)
    }
    
    func generateBuildingBlocks() -> [BuildingBlock] {
        return [BuildingBlock]()
    }
    
}




struct Story: Equatable, Identifiable, Hashable {
    var id: UUID = UUID()
    var usedInIntroduction: Bool
    var headline: String
    var storyText: String
}

extension Episode {
    
    /// Builds episode from local Markdown script
    static func buildFromScript(_ scriptFilename: String) -> Episode {
        
        let parser = ScriptParser(name: scriptFilename)
        
        let scriptDate = parser.extractDatetime() ?? Date()
        let speakerName = parser.extractSpeaker() ?? "<no speaker found>"
        let introText = parser.extractIntro() ?? "<no intro found>"
        let headlines = parser.extractHeadlines()
        let outroText = parser.extractOutro()  ?? "<no outro found>"
        
        // mark speakerName as token in introText
        let speakerToken = "{\(speakerName)}"
        let introTextWithSpeakerToken = introText.replacing(speakerName, with: speakerToken)
        
        // convert date to time slot
        //let timeSlot = scriptDate.formatted(date: .abbreviated, time: .shortened)
        
        // create episode
        //let episode = Episode(welcomeText: introTextWithSpeakerToken, stories: stories, epilogue: outroText, timeSlot: timeSlot)
        
        // start from here
        var episode = Episode(language: .brazilian, creationDate: scriptDate)
        
        // add introduction
        let introductionSection = EpisodeSection(type: .standard, name: "Introduction", text: introTextWithSpeakerToken)
        episode.addSection(introductionSection)

        // next, we want the headlines to be read out
        let headlineSection = EpisodeSection(type: .headlines, name: "Headlines")
        episode.addSection(headlineSection)
        
        // add story section
        let storySection = EpisodeSection(type: .stories, name: "Stories")
        episode.addSection(storySection)
        
        // create stories
        var storyNumber = 1
        var stories = [Story]()
        while true {
            
            // get storyText. Sop if there are no more stories
            guard let storyText = parser.extractStory(storyNumber: storyNumber) else {break}
            
            // get matching headline
            let headlineIndex = storyNumber - 1
            if headlineIndex < headlines.count {
                
                // matching headline
                let headline = headlines[headlineIndex]
                
                // create story
                let story = Story(usedInIntroduction: headline.isHighlighted, headline: headline.text, storyText: storyText)
                
                // append to other stories
                stories.append(story)
            } else {
                print("Could not match story to headline in \(scriptFilename)")
                break
            }
            
            // go to next story
            storyNumber += 1
        }
        
        // add stories to episode
        episode.stories = stories
        
        // add epilog
        let epilogSection = EpisodeSection(type: .standard, name: "Epilog", text: outroText)
        episode.addSection(epilogSection)
        
        return episode
    }
}
