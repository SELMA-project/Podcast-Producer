//
//  Episode.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 09.08.22.
//

import Foundation

struct Episode: Identifiable, Hashable {
    var id: UUID = UUID()
    var welcomeText: String
    var stories: [Story]
    var epilogue: String
    var timeSlot: String
}

struct Story: Equatable, Identifiable, Hashable {
    var id: UUID = UUID()
    var usedInIntroduction: Bool
    var headline: String
    var storyText: String
}

extension Episode {
    static func buildFromScript(_ scriptFilename: String) -> Episode {
        
        let parser = ScriptParser(name: scriptFilename)
        
        let scriptDate = parser.extractDatetime() ?? Date()
        let speakerName = parser.extractSpeaker() ?? "<no speaker found>"
        let introText = parser.extractIntro() ?? "<no intro found>"
        let headlines = parser.extractHeadlines()
        let outroText = parser.extractOutro()  ?? "<no outro found>"
        
        // extract stories
        var storyNumber = 1
        var stories = [Story]()
        while true {
            
            // get storyText. Sop if there are no more stories
            guard let storyText = parser.extractStory(storyNumber: storyNumber) else {break}
            
            // get matching headline
            let headlineIndex = storyNumber - 1
            if headlineIndex < headlines.count {
                let headline = headlines[headlineIndex]
                
                // create story and add it to the array
                let story = Story(usedInIntroduction: headline.isHighlighted, headline: headline.text, storyText: storyText)
                stories.append(story)
                
            } else {
                print("Could not match story to headline in \(scriptFilename)")
                break
            }
            
            // go to next story
            storyNumber += 1
            
        }
    
        // convert date to time slot
        let timeSlot = scriptDate.formatted(date: .abbreviated, time: .shortened)
        
        // create episode
        let episode = Episode(welcomeText: introText, stories: stories, epilogue: outroText, timeSlot: timeSlot)
            
        return episode
    }
}
