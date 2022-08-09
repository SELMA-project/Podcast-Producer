//
//  Episode.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 09.08.22.
//

import Foundation

struct Episode {
    var cmsTitle: String
    var cmsTeaser: String
    var welcomeText: String
    var headlineIntroduction: String
    var stories: [Story]
    var epilogue: String
}

struct Story {
    var usedInIntroduction: Bool
    var headline: String
    var storyText: String
}

