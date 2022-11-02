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
            
            let languageCode = isoCode.replacingOccurrences(of: "-", with: "_")
            
            let locale = Locale(identifier: "en_US")
            let languageName = locale.localizedString(forLanguageCode: languageCode)!
            
//            switch(self) {
//            case .brazilian:
//                return "Portuguese (Brazil)"
//            case .german:
//                return "German"
//            case .english:
//                return "English"
//            }
            
            return languageName
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

    /// Returns Language based on isoCode
    func language(fromIsoCode isoCode: String) -> Language? {
        
        let result = Language.allCases.filter { language in
            language.isoCode == isoCode
        }.first
        
        return result
    }
}
