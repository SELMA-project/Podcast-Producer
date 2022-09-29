//
//  ScriptParser.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 27.09.22.
//

import Foundation
import RegexBuilder

class ScriptParser {
    
    var scriptText: String
    
    init(name scriptName: String) {
        
        // create URL
        let scriptUrl = Bundle.main.url(forResource: scriptName, withExtension: nil)!
        
        // read file content as string
        self.scriptText = try! String(contentsOf: scriptUrl)
    }
    
    func extractTeaser() -> String {
        
        // define regex
        
        let regex = /#+\s*[Tt]easer\s*((\s|.)*?)\s+#+/
        
        // default
        var capturedText = ""
        
        do {

            if let match = try regex.firstMatch(in: scriptText) {
                capturedText = String(match.1)
            }
        } catch {
            print(error)
        }
        
        return capturedText
    }
    
    func extractIntro() -> String {
        
        // define regex
        
        let regex = /#+\s*[Ii]ntro\s*((\s|.)*?)\s+#+/
        
        // default
        var capturedText = ""
        
        do {

            if let match = try regex.firstMatch(in: scriptText) {
                capturedText = String(match.1)
            }
        } catch {
            print(error)
        }
        
        return capturedText
    }
    

    func extractHeadlines() -> [(isHighlighted: Bool, text: String)] {
        
        // define regex
        
        let regex = /#+\s*[hH]eadlines\s*((\s|.)*?)\s+#+/
        
        // default
        var capturedText = ""
        
        do {

            if let match = try regex.firstMatch(in: scriptText) {
                capturedText = String(match.1)
            }
        } catch {
            print(error)
        }
        
        // go through each line of the captured text
        
        // store result here
        var headlines = [(isHighlighted: Bool, text: String)]()
        
        // regex for each line
        let lineRegex = /-\s*(\**)([^*]+)(\**)/
        
        // split capture text in headlines section
        let lines = capturedText.split(separator: /[\n\r]/)
        
        // go through each line
        for line in lines {
            
            // if we have a match
            if let match = try? lineRegex.firstMatch(in: line) {
                
                // does the headline start with an emphasis (**)?
                let headlineEmphasisStarted = match.1.count > 0
                
                // the headline itself
                let headlineText = String(match.2).trimmingCharacters(in: .whitespacesAndNewlines)
                
                // does the headline end with an emphasis (**)?
                let headlineEmphasisEnded = match.3.count > 0
                
                // debug
                print("\(headlineEmphasisStarted) -> \(headlineText) -> \(headlineEmphasisEnded)")
                
                // create headline tuple
                let isHighlighted = headlineEmphasisStarted || headlineEmphasisEnded
                let headline = (isHighlighted: isHighlighted, text: headlineText)
                
                // addd to result array
                headlines.append(headline)
            }
        }
        
        return headlines
    }
    
    
    func extractOutro() -> String {
        
        // define regex
        let regex = /#+\s*[Oo]utro\s*(.*)\s*/
        
        // default
        var capturedText = ""
        
        do {

            if let match = try regex.firstMatch(in: scriptText) {
                capturedText = String(match.1)
            }
        } catch {
            print(error)
        }
        
        return capturedText
    }
    
    func extractStory(storyNumber: Int) -> String {
                
        // define regex
        let regex = /#+\s*[Ss]tory\s+\d\s*((\s|.)*?)\s+#+/
        //let regex = #"#+\s*[Ss]tory\s+\d\s*((\s|.)*?)\s+#+"#
        
        // default
        var capturedText = ""
        
        do {

            if let match = try regex.firstMatch(in: scriptText) {
                capturedText = String(match.1)
            }
        } catch {
            print(error)
        }
        
        return capturedText
    }
}
