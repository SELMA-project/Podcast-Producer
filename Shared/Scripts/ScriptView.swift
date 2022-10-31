//
//  ScriptView.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 27.09.22.
//

import SwiftUI

struct ScriptView: View {
    
    var scriptName: String
    
    func formatDate(_ date: Date?) -> String {
        
        guard let date else {return "<no date detected>"}
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mmZ"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
 
    var displayText: String {
        
        let parser = ScriptParser(name: scriptName)
        let scriptDate = parser.extractDatetime()
        let speakerName = parser.extractSpeaker()
        let teaserText = parser.extractTeaser()
        let introText = parser.extractIntro()
        let headlines = parser.extractHeadlines()
        let storyText = parser.extractStory(storyNumber: 1)
        let outroText = parser.extractOutro()
        
        //var displayText = "\(String(describing: scriptDate))\n\n"
        var displayText = "\(formatDate(scriptDate))\n\n"
        displayText += "\(speakerName ?? "<no speaker>")\n\n"
        displayText += "\(teaserText ?? "<no teaser>")\n\n"
        
        for headline in headlines {
            displayText += headline.isHighlighted ? "**\(headline.text)**\n\n" : "\(headline.text)\n\n"
        }
    
        displayText += "\(introText ?? "<no intro>")\n\n"
        displayText += "\(storyText ?? "<no story>")\n\n"
        displayText += "\(outroText ?? "<no outro>")"
 
        
        return displayText
    }
    
    
    var body: some View {
        ScrollView {
            Text(displayText)
        }
        .padding()
        .onAppear {
            ScriptParser.test()
        }
    }
}

struct ScriptView_Previews: PreviewProvider {
    static var previews: some View {
        ScriptView(scriptName: "2022-09-20-e2.md")
    }
}
