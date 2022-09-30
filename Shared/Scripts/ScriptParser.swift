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
    
//    func extractSpeaker() -> String {
//        
//        // define regex
//        
//        let regex = /#+\s*[Ii]ntro\s*(\s|.)+[Ee]u sou (?<name>.+) e esta(\s|.)+\s+#+/
//        
//        // default
//        var capturedText = ""
//        
//        do {
//
//            if let match = try regex.firstMatch(in: scriptText) {
//                capturedText = String(match.name)
//            }
//        } catch {
//            print(error)
//        }
//        
//        return capturedText
//    }
    

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
        //let regex = /#+\s*[Ss]tory\s+\d\s*(\s|.*?)\s+#+/
        let regex = try! Regex(#"#+\s*[Ss]tory\s+\#(storyNumber)\s*(\s|.*?)\s+#+"#)
        
        // default
        var capturedText = ""
        
        do {

            if let match = try regex.firstMatch(in: scriptText) {
                if let matchTuples = match.output.extractValues(as: (Substring, Substring).self) {
                    capturedText = String(matchTuples.1)
                }
            }
        } catch {
            print(error)
        }
        
        return capturedText
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
                        hour = 14 // pm
                    }
                }

                if let day, let month, let year {
                    
                    // add 2000 to year if necessary
                    var fourDigitYear = 2000 + year
                    if year >= 2000 {
                        fourDigitYear = year
                    }
                    
                    var calendar = Calendar.current
                    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
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
