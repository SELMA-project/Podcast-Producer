//
//  SummarizationEngine.swift
//  Podcast Creator (macOS)
//
//  Created by Andy Giefer on 01.08.23.
//

import Foundation

enum SummarisationEngine: String, CaseIterable, Identifiable {
    case openAI, alpaca, priberam, titleAndTeaser
    
    var id: String {
        return displayName
    }
    
    var displayName: String {
        switch self {
        case .alpaca:
            return "Alpaca"
        case .openAI:
            return "OpenAI"
        case .priberam:
            return "Priberam"
        case .titleAndTeaser:
            return "Title and Teaser"
        }
    }
}
