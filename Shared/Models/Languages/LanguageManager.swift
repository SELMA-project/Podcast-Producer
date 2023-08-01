//
//  LanguageManager.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 09.10.22.
//

import Foundation

class LanguageManager {
    
    static var shared = LanguageManager()
    
    enum Language: String, CaseIterable, Codable {
        case brazilian, english, german, french, spanish, hindi, urdu
        
        var displayName: String {
            
            let languageCode = isoCode.replacingOccurrences(of: "-", with: "_")
            
            let locale = Locale(identifier: "en_US")
            let languageName = locale.localizedString(forLanguageCode: languageCode)!
            

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
            case .french:
                isoCode = "fr-FR"
            case .spanish:
                isoCode = "es-ES"
            case .hindi:
                isoCode = "hi-IN"
            case .urdu:
                isoCode = "ur-PK"
            }
        
            
            return isoCode
        }
        
        /// The String code used by Monitio.
        var monitioCode: String {
            return String(isoCode.split(separator: "-").first!)
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
