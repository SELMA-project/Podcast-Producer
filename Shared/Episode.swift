//
//  Episode.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 09.08.22.
//

import Foundation

enum EpisodeSectionType {
    case standard, headlines, story
}

struct EpisodeSection: Identifiable, Hashable {
    var id: UUID = UUID()
    var type: EpisodeSectionType
    var name: String
    var headline: String = "<sectionHeadline>"
    var isHighlight: Bool = false
    var text: String = "<sectionText"
}

struct Episode: Identifiable, Hashable {
    var id: UUID = UUID()
    var creationDate: Date
    
    var timeSlot: String {
        return creationDate.formatted(date: .abbreviated, time: .shortened)
    }
    
    var introductionText: String = "<introductionText>"
//    {
//        sections.filter{$0.name == "welcome"}[0].text ?? "<welcomeText>"
//    }
    var stories: [Story] = [Story]()
//    {
//        let stories = sections.map { section in
//            let story = Story(usedInIntroduction: section.isHighlight ?? false,
//                              headline: section.headline ?? "<noHeadline>",
//                              storyText: section.text ?? "<noText>")
//            return story
//        }
//
//        return stories
//    }
    
    var epilog: String = "<epilogText>"
//    {
//        sections.filter{$0.name == "epilog"}[0].text ?? "<epilogText>"
//    }
    

    
    // the order of all sections
    var sections = [EpisodeSection]()
    
    // adds a new section to the episode
    mutating func addSection(_ section: EpisodeSection) {
        
        sections.append(section)
        
        // temp
        if section.name == "introduction" {
            introductionText = section.text
        }
        
        if section.name == "story" {
            let story = Story(usedInIntroduction: section.isHighlight, headline: section.headline, storyText: section.text)
            stories.append(story)
        }
        
        if section.name == "epilog" {
            epilog = section.text
        }
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
        var episode = Episode(creationDate: scriptDate)
        
        // add introduction
        let introductionSection = EpisodeSection(type: .standard, name: "introduction", text: introTextWithSpeakerToken)
        episode.addSection(introductionSection)

        // next, we want the headlines to be read out
        let headlineSection = EpisodeSection(type: .headlines, name: "headlines")
        episode.addSection(headlineSection)
        
        // add stories
        var storyNumber = 1
        //var stories = [Story]()
        while true {
            
            // get storyText. Sop if there are no more stories
            guard let storyText = parser.extractStory(storyNumber: storyNumber) else {break}
            
            // get matching headline
            let headlineIndex = storyNumber - 1
            if headlineIndex < headlines.count {
                
                // matching headline
                let headline = headlines[headlineIndex]
                
                // add as story section
                let storySection = EpisodeSection(type: .story, name: "story", headline: headline.text, isHighlight: headline.isHighlighted, text: storyText)
                episode.addSection(storySection)

            } else {
                print("Could not match story to headline in \(scriptFilename)")
                break
            }
            
            // go to next story
            storyNumber += 1
            
        }
        
        // add epilog
        let epilogSection = EpisodeSection(type: .standard, name: "epilog", text: outroText)
        episode.addSection(epilogSection)
        
        return episode
    }
}
