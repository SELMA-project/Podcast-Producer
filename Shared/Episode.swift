//
//  Episode.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 09.08.22.
//

import Foundation

struct Episode: Identifiable, Hashable {
    var id: UUID = UUID()
    var cmsTitle: String
    var cmsTeaser: String
    var welcomeText: String
    var headlineIntroduction: String
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

