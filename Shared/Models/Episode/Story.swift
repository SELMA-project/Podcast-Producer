//
//  Story.swift
//  Podcast Creator
//
//  Created by Andy Giefer on 28.04.23.
//

import Foundation

/// The model used to descibed a story.
struct Story: Equatable, Identifiable, Hashable, Codable {

    struct StoryId: Codable, Hashable {
        var internalId = UUID()
    }
    
    /// The story's id.
    var id: StoryId = StoryId()
    
    /// Determines whether a story is mentioned during the introduction.
    var usedInIntroduction: Bool
    
    /// The story's headline.
    var headline: String
    
    /// The story's body text
    var storyText: String
    
    /// An example story.
    static var mockup: Story {
        let story = Story(usedInIntroduction: true,
                          headline: "Kyiv denies Russian forces have captured Yahidne",
                          storyText: "Moscow's mercenary Wagner group has been 'unsuccessful' in seizing several areas around the eastern city of Bakhmut, Ukraine's military said. Putin repeats claims the West wants to liquidate Russia.")
        return story
    }
    
}
