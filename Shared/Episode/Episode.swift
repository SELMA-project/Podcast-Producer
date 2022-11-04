//
//  Episode.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 09.08.22.
//

import Foundation
import CryptoKit

enum EpisodeSectionType: String {
    case standard = "Standard"
    case headlines = "Headlines"
    case stories = "Stories"
}

struct Story: Equatable, Identifiable, Hashable {
    var id: UUID = UUID()
    var usedInIntroduction: Bool
    var headline: String
    var storyText: String
    var owningEpisode: Episode?
    
    var headlineAudioURL: URL? {
        
        var storageURL: URL?

        // we need to be able to link to the owning episode
        if let owningEpisode {
            storageURL = owningEpisode.textAudioURL(forSectionType: .stories, textContent: self.headline)
        } else {
            fatalError("This episode section should have an owning episode by now")
        }

        // return result
        return storageURL
    }
    
    var storyTextAudioURL: URL? {
        var storageURL: URL?

        // we need to be able to link to the owning episode
        if let owningEpisode {
            storageURL = owningEpisode.textAudioURL(forSectionType: .stories, textContent: self.storyText)
        } else {
            fatalError("This episode section should have an owning episode by now")
        }

        // return result
        return storageURL
    }
}


struct EpisodeSection: Identifiable, Hashable {
    var id: UUID = UUID()
    var type: EpisodeSectionType
    var name: String
    var owningEpisode: Episode?
    var rawText: String = ""

    var prefixAudioFile: AudioManager.AudioFile = AudioManager.audioFileForDisplayName("None")
    var mainAudioFile: AudioManager.AudioFile = AudioManager.audioFileForDisplayName("None")
    var suffixAudioFile: AudioManager.AudioFile = AudioManager.audioFileForDisplayName("None")
    var separatorAudioFile: AudioManager.AudioFile = AudioManager.audioFileForDisplayName("None")
    
    var finalText: String {
        
        // make a copy
        var textWithReplacements = rawText
        
        // we need to be able to link to the owning episode
        if let owningEpisode {
                        
            // get relevant properties from owning episode
            let episodeCreationDate = owningEpisode.creationDate
            let episodeNarrator = owningEpisode.narrator
            let episodeLanguage = owningEpisode.language
            
            // replace narrator
            textWithReplacements = textWithReplacements.replacing("{narrator}", with: episodeNarrator)
            
            // replace date
            let languageCode = episodeLanguage.isoCode
            let appleLocale = languageCode.replacingOccurrences(of: "-", with: "_")
            
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: appleLocale)
            formatter.setLocalizedDateFormatFromTemplate("EEEE, dd MMMM YYYY")
            let dateString = formatter.string(from: episodeCreationDate)
            
            textWithReplacements = textWithReplacements.replacing("{date}", with: dateString)

        } else {
            fatalError("This episode section should have an owning episode by now")
        }
        
        return textWithReplacements
    }
    
    var textAudioURL: URL?
    {
        var storageURL: URL?

        // we need to be able to link to the owning episode
        if let owningEpisode {
            storageURL = owningEpisode.textAudioURL(forSectionType: self.type, textContent: self.finalText)
        } else {
            fatalError("This episode section should have an owning episode by now")
        }

        // return result
        return storageURL
    }
}

struct Episode: Identifiable, Hashable {
    var id: UUID = UUID()
    
    var language: LanguageManager.Language
    var narrator: String
    
    var podcastVoice: PodcastVoice
    
    var creationDate: Date
    var restrictHeadlinesToHighLights: Bool
    
    var timeSlot: String {
        return creationDate.formatted(date: .abbreviated, time: .shortened)
    }
    
    var stories: [Story] = [Story]()
    
    // the order of all sections
    var sections = [EpisodeSection]()
    
    // adds a new section to the episode
    mutating func addSection(_ section: EpisodeSection) {
        
        sections.append(section)
    }
    
    func generateBuildingBlocks() -> [BuildingBlock] {
        return [BuildingBlock]()
    }
    
    static var standard: Episode {
        let podcastVoice = VoiceManager.shared.proposedVoice(forLanguageCode: "en-US")
        let episode = Episode(language: .english, narrator: "<no narrator>", podcastVoice: podcastVoice, creationDate: Date(), restrictHeadlinesToHighLights: true)
        return episode
    }
    
    fileprivate func textAudioURL(forSectionType sectionType: EpisodeSectionType, textContent: String) -> URL {

        // where to store
        let documentsDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]

        // voice identifier
        let voiceIdentifier = podcastVoice.identifier
        
        // mix type and text into hash
        let textToBeHashed = "\(sectionType.rawValue)-\(voiceIdentifier)-\(textContent)"
        let textAsData = Data(textToBeHashed.utf8)
        let hashed = SHA256.hash(data: textAsData)
        let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()

        // create URL
        let fileName = "\(hashString).wav"
        let storageURL = documentsDirectory.appendingPathComponent(fileName)

        // return result
        return storageURL
    }
    
//    /// Replaces all place holders
//    func replacePlaceholders(inText text: String) -> String {
//
//        // narrator
//        let narratorName = self.narrator
//        var newText = text.replacing("{narrator}", with: narratorName)
//
//        // date
//        let creationDate = self.creationDate
//        let languageCode = self.language.isoCode
//        let appleLocale = languageCode.replacingOccurrences(of: "-", with: "_")
//
//        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: appleLocale)
//        formatter.setLocalizedDateFormatFromTemplate("EEEE, dd MMMM YYYY")
//        let dateString = formatter.string(from: creationDate)
//
//        newText = newText.replacing("{date}", with: dateString)
//
//        return newText
//    }
}






extension Episode {
    
    /// Builds episode from template
    static func buildFromTemplate(_ episodeTemplate: EpisodeTemplate, narrator: String) -> Episode {
        
        // prepare parameters for episode
        let language = episodeTemplate.language
        let podcastVoice = VoiceManager.shared.proposedVoice(forLanguageCode: language.isoCode)
        let creationDate = Date()
        let restrictHeadlinesToHighLights = episodeTemplate.restrictHeadlinesToHighLights
                
        // create episode
        var episode = Episode(language: language, narrator: narrator, podcastVoice: podcastVoice, creationDate: creationDate, restrictHeadlinesToHighLights: restrictHeadlinesToHighLights)
        
        // add introduction & headlines
        var introductionSection = episodeTemplate.episodeSections[0]
        introductionSection.owningEpisode = episode // the section needs information from its episode, such as creation date and narrator
        episode.addSection(introductionSection)
        
        // add story section
        var storySection = episodeTemplate.episodeSections[1]
        storySection.owningEpisode = episode
        episode.addSection(storySection)
                
        // add epilog
        var epilogSection = episodeTemplate.episodeSections[2]
        epilogSection.owningEpisode = episode
        episode.addSection(epilogSection)
        
        return episode
    }
}


extension Episode {
    
    /// Builds episode from local Markdown script
    static func buildFromScript(_ scriptFilename: String) -> Episode {
        
        // use this template
        let episodeTemplate = EpisodeTemplate.template(forLanguage: .brazilian)
        
        let parser = ScriptParser(name: scriptFilename)
        
        let scriptDate = parser.extractDatetime() ?? Date()
        let narrator = parser.extractSpeaker() ?? "<no speaker found>"
        let introText = parser.extractIntro() ?? "<no intro found>"
        let headlines = parser.extractHeadlines()
        let outroText = parser.extractOutro()  ?? "<no outro found>"
        
        // mark speakerName as token in introText
        let speakerToken = "{narrator}"
        let introTextWithSpeakerToken = introText.replacing(narrator, with: speakerToken)
        
        // start from here
        //var episode = Episode(language: .brazilian, creationDate: scriptDate, restrictHeadlinesToHighLights: true)
        let podcastVoice = VoiceManager.shared.voiceForSelmaNarrator(narrator) ?? VoiceManager.shared.voiceForSelmaNarrator("Leila Endruweit")!
        var episode = Episode(language: .brazilian, narrator: narrator, podcastVoice: podcastVoice, creationDate: scriptDate, restrictHeadlinesToHighLights: true)
        
        // add introduction & headlines
        var introductionSection = episodeTemplate.episodeSections[0]
        introductionSection.owningEpisode = episode
        introductionSection.rawText = introTextWithSpeakerToken
        episode.addSection(introductionSection)
        
        // add story section
        var storySection = episodeTemplate.episodeSections[1]
        storySection.owningEpisode = episode
        episode.addSection(storySection)
        
        // create stories
        var storyNumber = 1
        var stories = [Story]()
        while true {
            
            // get storyText. Sop if there are no more stories
            guard let storyText = parser.extractStory(storyNumber: storyNumber) else {break}
            
            // get matching headline
            let headlineIndex = storyNumber - 1
            if headlineIndex < headlines.count {
                
                // matching headline
                let headline = headlines[headlineIndex]
                
                // create story
                let story = Story(usedInIntroduction: headline.isHighlighted, headline: headline.text, storyText: storyText, owningEpisode: episode)
                
                // append to other stories
                stories.append(story)
            } else {
                print("Could not match story to headline in \(scriptFilename)")
                break
            }
            
            // go to next story
            storyNumber += 1
        }
        
        // add stories to episode
        episode.stories = stories
        
        // add epilog
        var epilogSection = episodeTemplate.episodeSections[2]
        epilogSection.owningEpisode = episode
        epilogSection.rawText = outroText
        episode.addSection(epilogSection)
        
        return episode
    }
}
