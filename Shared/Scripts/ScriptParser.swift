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
    
    /// Returns an array of locallay available script names
    static func availableScriptNames() -> [String] {
        
        var names = [String]()
        
        if let urls = Bundle.main.urls(forResourcesWithExtension: "md", subdirectory: nil) {
            for url in urls {
                let name = url.lastPathComponent
                names.append(name)
            }
        }
        
        let sortedNames = names.sorted { e0, e1 in
            return e0 > e1
        }
        
        return sortedNames
        
    }
    
    static func test() {
        
        // build array of locallay available scripts
        let fileNames = ScriptParser.availableScriptNames()

        for fileName in fileNames {
            let parser = ScriptParser(name: fileName)
            
            let scriptDate = parser.extractDatetime()
            let speakerName = parser.extractSpeaker()
            let teaserText = parser.extractTeaser()
            let introText = parser.extractIntro()
            let headlines = parser.extractHeadlines()
            let storyText = parser.extractStory(storyNumber: 1)
            let outroText = parser.extractOutro()
            
            if scriptDate == nil {print("Missing scriptDate: \(fileName)")}
            if speakerName == nil {print("Missing speakerName: \(fileName)")}
            if teaserText == nil {print("Missing teaserText: \(fileName)")}
            if introText == nil {print("Missing introText: \(fileName)")}
            if headlines.count == 0 {print("Missing headlines: \(fileName)")}
            if storyText == nil {print("Missing storyText: \(fileName)")}
            if outroText == nil {print("Missing outroText: \(fileName)")}

        }
 
    }
    
    func extractTeaser() -> String? {
        
        // define regex
        
        //let regex = /#+\s*[Tt]easer\s*((\s|.)*?)\s+#+/
        let regex = /#+\s*teaser\s*(.*?)\s+#+/.dotMatchesNewlines().ignoresCase()
        
        // default
        var capturedText: String?
        
        do {

            if let match = try regex.firstMatch(in: scriptText) {
                capturedText = String(match.1).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } catch {
            print(error)
        }
        
        return capturedText
    }
    
    func extractIntro() -> String? {
        
        // define regex
        
        //let regex = /#+\s*[Ii]ntro\s*((\s|.)*?)\s+#+/
        let regex = /#+\s*intro\s*(.*?)\s+#+/.dotMatchesNewlines().ignoresCase()
        
        // default
        var capturedText: String?
        
        do {

            if let match = try regex.firstMatch(in: scriptText) {
                capturedText = String(match.1).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } catch {
            print(error)
        }
        
        return capturedText
    }
    
    func extractSpeaker() -> String? {
        
        // define regex
        
        //let regex = /Eu\ssou\s(?<name>.+)\se\sest[ae]/
        let regex = /#\s*intro.*Eu\ssou\s(?<name>.+?)\se\s/.dotMatchesNewlines().ignoresCase()
        
        // default
        var capturedText: String?
        
        do {

            if let match = try regex.firstMatch(in: scriptText) {
                capturedText = String(match.name).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } catch {
            print(error)
        }
        
        return capturedText
    }
    

    func extractHeadlines() -> [(isHighlighted: Bool, text: String)] {
        
        // define regex
        
        //let regex = /#+\s*[hH]eadlines\s*((\s|.)*?)\s+#+/
        let regex = /#+\s*headlines\s*(.*?)\s+#+/.dotMatchesNewlines().ignoresCase()
        
        // default
        var capturedText = ""
        
        do {

            if let match = try regex.firstMatch(in: scriptText) {
                capturedText = String(match.1).trimmingCharacters(in: .whitespacesAndNewlines)
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
                //print("\(headlineEmphasisStarted) -> \(headlineText) -> \(headlineEmphasisEnded)")
                
                // create headline tuple
                let isHighlighted = headlineEmphasisStarted || headlineEmphasisEnded
                let headline = (isHighlighted: isHighlighted, text: headlineText)
                
                // addd to result array
                headlines.append(headline)
            }
        }
        
        return headlines
    }
    
    
    func extractOutro() -> String? {
        
        // define regex
        let regex = /#+\s*outro\s+(.*)\s+/.dotMatchesNewlines().ignoresCase()
        
        // default
        var capturedText: String?
        
        do {

            if let match = try regex.firstMatch(in: scriptText) {
                capturedText = String(match.1).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } catch {
            print(error)
        }
        
        return capturedText
    }
    
    func extractStory(storyNumber: Int) -> String? {
                
        // define regex
        //let regex = /#+\s*[Ss]tory\s+\d\s*(\s|.*?)\s+#+/
        // let regex = try! Regex(#"#+\s*[Ss]tory\s+\#(storyNumber)\s*(\s|.*?)\s+#+"#)
        let regex = try! Regex(#"#+\s*story\s*\#(storyNumber)(.*?)#"#).dotMatchesNewlines().ignoresCase()
        
        // default
        var capturedText: String?
        
        do {

            if let match = try regex.firstMatch(in: scriptText) {
                if let matchTuples = match.output.extractValues(as: (Substring, Substring).self) {
                    capturedText = String(matchTuples.1).trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        } catch {
            print(error)
        }
        
        let textWithNewlines = capturedText?.replacingOccurrences(of: ".", with: ".\n\n")
        
        return textWithNewlines
    }
    
    //Boletim de Notícias (21/09/22) – 1 edição
    func extractDatetime() -> Date? {
        
        // define regex
        //let regex = /#+\s*[Oo]utro\s*(.*)\s*/
        //let regex = /Boletim de Notícias \((?<day>\d+)\/(?<month>\d+)\/(?<year>\d+)\)\s*–?\s*([Ss]egunda)?\s+edição/
        let regex = /Boletim de Notícias \((?<day>\d+)\/(?<month>\d+)\/(?<year>\d+)\)(.+)?/
        
        // default
        var capturedDate: Date?
        
       do {

            if let match = try regex.firstMatch(in: scriptText) {

                let day = Int(match.day)
                let month = Int(match.month)
                let year = Int(match.year)

                // if there is something after the date we have a 'pm' episode
                var hour = 10 // default: am
                if match.4 != nil {
                    let suffix = String(match.4!).trimmingCharacters(in: .whitespacesAndNewlines)
                    if suffix.count > 0 {
                        hour = 18 // pm
                    }
                }

                if let day, let month, let year {
                    
                    // add 2000 to year if necessary
                    var fourDigitYear = 2000 + year
                    if year >= 2000 {
                        fourDigitYear = year
                    }
                    
                    let calendar = Calendar.current
                    //calendar.timeZone = TimeZone(secondsFromGMT: 0)!
                    let components = DateComponents(year: fourDigitYear, month: month, day: day, hour: hour)
                    capturedDate = calendar.date(from: components)!
                }


            }
        } catch {
            print(error)
        }
        
        return capturedDate
    }
}
