//
//  EpisodeTemplate.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 09.10.22.
//

import Foundation

struct EpisodeTemplate: Hashable, Identifiable {
    
    enum Edition: String {
        case morning, evening, standard
    }
    
    var id: String {return name}
    var name: String
    var language: LanguageManager.Language
    var restrictHeadlinesToHighLights = false
    var episodeSections: [EpisodeSection]
}
