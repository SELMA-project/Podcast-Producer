//
//  LanguageManager.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 09.10.22.
//

import Foundation

class LanguageManager {
    
    static var shared = LanguageManager()
    
    enum Language: String, CaseIterable {
        case brazilian, english, german
        
        var displayName: String {
            return rawValue.capitalized
        }
        
        var isoCode: String {
            
            var isoCode: String
            
            switch(self) {
            case .english:
                isoCode = "en-US"
            case .brazilian:
                isoCode = "pt-BR"
            case .german:
                isoCode = "de-DE"
            }
            
            return isoCode
        }
    }
}
