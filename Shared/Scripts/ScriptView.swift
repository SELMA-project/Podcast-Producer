//
//  ScriptView.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 27.09.22.
//

import SwiftUI

struct ScriptView: View {
    
    var displayText: String {
        
        let parser = ScriptParser(name: "2022-09-26-e2.md")
        let scriptDate = parser.extractDatetime()
        let speakerName = parser.extractSpeaker()
        let teaserText = parser.extractTeaser()
        let introText = parser.extractIntro()
        let headlines = parser.extractHeadlines()
        let storyText = parser.extractStory(storyNumber: 6)
        let outroText = parser.extractOutro()
        
        var displayText = "\(String(describing: scriptDate))\n\n\(speakerName ?? "<no speaker>")\n\n"
        for headline in headlines {
            displayText += headline.isHighlighted ? "**\(headline.text)**\n\n" : "\(headline.text)\n\n"
        }
        
        displayText += "\(teaserText)\n\n\(introText)\n\n\(storyText)\n\n\(outroText)"
        //let displayText = "\(introText)"
        
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
