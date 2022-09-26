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
    var displayName: String
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
            displayName = "Roberto"
            selmaName = "roberto crescenti"
            
        case .leila:
            displayName = "Leila"
            selmaName = "leila endruweit"
            
        case .renate:
            displayName = "Renate"
            selmaName = "renate krieger"

        case .alexandre:
            displayName = "Alexandre"
            selmaName = "alexandre schossler"

        case .bruno:
            displayName = "Bruno"
            selmaName = "bruno lupion"

        case .clarissa:
            displayName = "Clarissa"
            selmaName = "clarissa nehere"

        case .marcio:
            displayName = "Marcio"
            selmaName = "marcio damascenoe"

        case .philip:
            displayName = "Philip"
            selmaName = "philip verminnen"
        }
        
    }

}

