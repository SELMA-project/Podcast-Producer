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

struct SelmaVoice {
    var displayName: String
    var selmaName: String
    
    enum SelmaVoiceId {
        case leila, roberto, renate, alexandre, bruno, clarissa, marcio, philip
    }
    
    init(_ voiceId: SelmaVoiceId) {
 
    
        switch voiceId {
        case .roberto:
            displayName = "Roberto Crescenti"
            selmaName = "roberto crescenti"
            
        case .leila:
            displayName = "Leila Eindruweit"
            selmaName = "leila endruweit"
            
        case .renate:
            displayName = "Renate Krieger"
            selmaName = "renate krieger"

        case .alexandre:
            displayName = "Alexandre Schossler"
            selmaName = "alexandre schossler"

        case .bruno:
            displayName = "Bruno Lupion"
            selmaName = "bruno lupion"

        case .clarissa:
            displayName = "clarissa nehere"
            selmaName = "Clarissa Nehere"

        case .marcio:
            displayName = "Marcio Damascenoe"
            selmaName = "marcio damascenoe"

        case .philip:
            displayName = "Philip Verminnen"
            selmaName = "philip verminnen"
        }
        
    }

}

