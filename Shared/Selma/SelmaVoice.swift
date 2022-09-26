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
    var selmaName: String
    
    enum SelmaVoiceId: CaseIterable  {
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
            selmaName = "roberto crescenti"
            
        case .leila:
            shortName = "Leila"
            fullName = "Leila Endruweit"
            selmaName = "leila endruweit"
            
        case .renate:
            shortName = "Renate"
            fullName = "Renate Krieger"
            selmaName = "renate krieger"

        case .alexandre:
            shortName = "Alexandre"
            fullName = "Alexandre Schossler"
            selmaName = "alexandre schossler"

        case .bruno:
            shortName = "Bruno"
            fullName = "Bruno Lupion"
            selmaName = "bruno lupion"

        case .clarissa:
            shortName = "Clarissa"
            fullName = "Clarissa Nehere"
            selmaName = "clarissa nehere"

        case .marcio:
            shortName = "Marcio"
            fullName = "Marcio Damascenoe"
            selmaName = "marcio damascenoe"

        case .philip:
            shortName = "Philip"
            fullName = "Philip Verminnen"
            selmaName = "philip verminnen"
        }
        
    }

}

