//
//  SelmaVoice.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 23.09.22.
//

import Foundation


//        "alexandre schossler": 0,
//        "bruno lupion": 1,
//        "clarissa nehere": 2,
//        "leila endruweit": 3,
//        "marcio damascenoe": 4,
//        "philip verminnen": 5,
//        "renate krieger": 6,
//        "roberto crescenti": 7

struct SelmaVoice: Identifiable, Hashable {
    var id: SelmaVoiceId
    var shortName: String
    var fullName: String
    var apiName: String
    var language: String
    
    enum SelmaVoiceId: String, CaseIterable  {
        case leila, roberto, renate, alexandre, bruno, clarissa, marcio, philip
    }
    
    static var allVoices: [SelmaVoice] {
        
        var voiceList = [SelmaVoice]()
        
        for voiceId in SelmaVoiceId.allCases {
            voiceList.append(SelmaVoice(voiceId))
        }
        
        return voiceList
    }
    
    init(_ voiceId: SelmaVoiceId) {
        
        id = voiceId
 
        switch voiceId {
        case .roberto:
            shortName = "Roberto"
            fullName = "Roberto Crescenti"
            apiName = "roberto crescenti"
            language = "pt-BR"
            
        case .leila:
            shortName = "Leila"
            fullName = "Leila Endruweit"
            apiName = "leila endruweit"
            language = "pt-BR"
            
        case .renate:
            shortName = "Renate"
            fullName = "Renate Krieger"
            apiName = "renate krieger"
            language = "pt-BR"

        case .alexandre:
            shortName = "Alexandre"
            fullName = "Alexandre Schossler"
            apiName = "alexandre schossler"
            language = "pt-BR"

        case .bruno:
            shortName = "Bruno"
            fullName = "Bruno Lupion"
            apiName = "bruno lupion"
            language = "pt-BR"

        case .clarissa:
            shortName = "Clarissa"
            fullName = "Clarissa Nehere"
            apiName = "clarissa nehere"
            language = "pt-BR"

        case .marcio:
            shortName = "Marcio"
            fullName = "Marcio Damascenoe"
            apiName = "marcio damascenoe"
            language = "pt-BR"

        case .philip:
            shortName = "Philip"
            fullName = "Philip Verminnen"
            apiName = "philip verminnen"
            language = "pt-BR"
        }
        
    }

}
