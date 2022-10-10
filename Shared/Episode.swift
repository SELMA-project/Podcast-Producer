//
//  Episode.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 09.08.22.
//

import Foundation
import CryptoKit

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
    var separatorAudioFile: AudioManager.AudioFile = AudioManager.audioFileForDisplayName("None")
    
    var proposedTextAudioURL: URL {
        
        // where to store
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // mix type and text into hash
        let textToBeHashed = "\(type.rawValue)-\(text)"
        let textAsData = Data(textToBeHashed.utf8)
        let hashed = SHA256.hash(data: textAsData)
        let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()

        // create URL
        let fileName = "\(hashString).wav"
        let storageURL = documentsDirectory.appendingPathComponent(fileName)
        
        // return
        return storageURL
    }
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
    

    var proposedHeadlineAudioURL: URL {
        // where to store
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // mix type and headline into hash
        let textToBeHashed = "\(headline)"
        let textAsData = Data(textToBeHashed.utf8)
        let hashed = SHA256.hash(data: textAsData)
        let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()

        // create URL
        let fileName = "\(hashString).wav"
        let storageURL = documentsDirectory.appendingPathComponent(fileName)
        
        // return
        return storageURL
    }
    
    var proposedTextAudioURL: URL {
        
        // where to store
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // mix type and storyText into hash
        let textToBeHashed = "\(storyText)"
        let textAsData = Data(textToBeHashed.utf8)
        let hashed = SHA256.hash(data: textAsData)
        let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()

        // create URL
        let fileName = "\(hashString).wav"
        let storageURL = documentsDirectory.appendingPathComponent(fileName)
        
        // return
        return storageURL
    }
    
}

extension Episode {
    
    /// Builds episode from local Markdown script
    static func buildFromScript(_ scriptFilename: String) -> Episode {
        
        // use this template
        let episodeTemplate = EpisodeTemplate.dwBrazil()
        
        let parser = ScriptParser(name: scriptFilename)
        
        let scriptDate = parser.extractDatetime() ?? Date()
        let speakerName = parser.extractSpeaker() ?? "<no speaker found>"
        let introText = parser.extractIntro() ?? "<no intro found>"
        let headlines = parser.extractHeadlines()
        let outroText = parser.extractOutro()  ?? "<no outro found>"
        
        // mark speakerName as token in introText
        let speakerToken = "{speakerName}"
        let introTextWithSpeakerToken = introText.replacing(speakerName, with: speakerToken)
        
        // start from here
        var episode = Episode(language: .brazilian, creationDate: scriptDate)
        
        // add introduction
        var introductionSection = episodeTemplate.episodeSections[0]
        introductionSection.text = introTextWithSpeakerToken
        episode.addSection(introductionSection)

        // next, we want the headlines to be read out
        let headlineSection = episodeTemplate.episodeSections[1]
        episode.addSection(headlineSection)
        
        // add story section
        let storySection = episodeTemplate.episodeSections[2]
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
        var epilogSection = episodeTemplate.episodeSections[3]
        epilogSection.text = outroText
        episode.addSection(epilogSection)
        
        return episode
    }
}
