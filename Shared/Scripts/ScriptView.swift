//
//  ScriptView.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 27.09.22.
//

import SwiftUI

struct ScriptView: View {
    
    var displayText: String {
        
        let parser = ScriptParser(name: "2022-09-27-e1.md")
        let teaserText = parser.extractTeaser()
        let introText = parser.extractIntro()
        let headlines = parser.extractHeadlines()
        let storyText = parser.extractStory(storyNumber: 2)
        let outroText = parser.extractOutro()
        
        //let displayText = "\(teaserText)\n\n\(introText)\n\n\(storyText)\n\n\(outroText)"
        let displayText = "\(introText)\n\n\(headlines)"
        
        return displayText
    }
    
    
    
    
    var body: some View {
        ScrollView {
            Text(displayText)
        }.padding()
    }
}

struct ScriptView_Previews: PreviewProvider {
    static var previews: some View {
        ScriptView()
    }
}
