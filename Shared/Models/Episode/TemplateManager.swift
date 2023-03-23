//
//  TemplateManager.swift
//  Podcast Creator
//
//  Created by Andy Giefer on 27.01.23.
//

import Foundation

class TemplateManager {
    
    static let shared = TemplateManager()
    
    var cachedTemplates = [LanguageManager.Language: [EpisodeTemplate]]()
    
    func availableTemplates(forLanguage language: LanguageManager.Language) -> [EpisodeTemplate] {
    
        // early return with cached result
        if let templates = cachedTemplates[language] {
            return templates
        }
        
        var templates = [EpisodeTemplate]()
        
        if language == .brazilian {
            
            let morningTemplate = template(forLanguage: .brazilian, edition: .morning)
            templates.append(morningTemplate)
            
            let eveningTemplate = template(forLanguage: .brazilian, edition: .evening)
            templates.append(eveningTemplate)
        }
        
        if language == .german {
            let template = template(forLanguage: .german)
            templates.append(template)
        }
        
        if language == .english {
            let template = template(forLanguage: .english)
            templates.append(template)
        }

        if language == .french {
            let template = template(forLanguage: .french)
            templates.append(template)
        }
        
        // store result in cache
        cachedTemplates[language] = templates
        
        // return result
        return templates
    }
    
    func template(forLanguage language: LanguageManager.Language, edition: EpisodeTemplate.Edition? = nil) -> EpisodeTemplate {
        
        let template: EpisodeTemplate
        
        let templateName: String
        let restrictHeadlinesToHighLights: Bool
        let introText: String
        let outroText: String
        
        switch language {
        case .brazilian:
            
            restrictHeadlinesToHighLights = true
            
            switch edition {
            case .morning, .none:
                templateName = "DW Brasil (am)"
                introText = "Olá, hoje é {date}. Eu sou {narrator} e este é o Boletim de Notícias da DW Brasil. Confira nesta edição:"
                outroText = "Novas informações você pode conferir mais tarde na segunda edição do Boletim de Notícias da DW Brasil."
            
            case .evening:
                templateName = "DW Brasil (pm)"
                introText = "Olá, hoje é {date}. Eu sou {narrator} e esta é a segunda edição do Boletim de Notícias da DW Brasil. Confira nesta edição:"
                outroText = "Mais informações, confira no nosso site: dw.com/brasil"
            }
        
        
        case .german:
            templateName = "DW Nachrichten"
            restrictHeadlinesToHighLights = true
            introText = "Guten Tag, heute ist {date}. Mein Name ist {narrator} hier sind die neusten Nachrichten."
            outroText = "Das waren die Nachrichten."

        case .english:
            templateName = "DW News"
            restrictHeadlinesToHighLights = true
            introText = "Greetings. It's {date} and this is DW with the latest news. My name is {narrator}."
            outroText = "These were the news. Come back for more."
            
        case .french:
            templateName = "Info Matin"
            restrictHeadlinesToHighLights = true
            introText = "DW Info Matin du {date}. Je m'appelle {narrator}. Bonjour."
            outroText = "Excellente journée à toutes et à tous et rendez-vous demain matin pour une nouvelle émission de Info Matin. A demain!"
        }
        
        template = createTemplate(name: templateName, forLanguage: language, restrictHeadlinesToHighLights: restrictHeadlinesToHighLights, introText: introText, outroText: outroText)
        
        return template
        
    }
    
    private func createTemplate(name templateName: String, forLanguage templateLanguage: LanguageManager.Language, restrictHeadlinesToHighLights: Bool, introText: String, outroText: String) -> EpisodeTemplate {
        
        var sectionText: String
        var prefixAudioFile: AudioManager.AudioFile
        var mainAudioFile: AudioManager.AudioFile
        var suffixAudioFile: AudioManager.AudioFile
        var separatorAudioFile: AudioManager.AudioFile
                
        // section 0 -> Introduction & Headlines
        prefixAudioFile = AudioManager.audioFileForDisplayName("Intro Start")
        mainAudioFile = AudioManager.audioFileForDisplayName("Intro Main")
        suffixAudioFile = AudioManager.audioFileForDisplayName("Intro End")
        let section0 = EpisodeSection(type: .headlines,
                                      name: "Introduction & Headlines",
                                      rawText: introText,
                                      prefixAudioFile: prefixAudioFile,
                                      mainAudioFile: mainAudioFile,
                                      suffixAudioFile: suffixAudioFile)
        
        // section 1 -> Stories
        separatorAudioFile = AudioManager.audioFileForDisplayName("Sting")
        let section1 = EpisodeSection(type: .stories, name: "Stories", separatorAudioFile: separatorAudioFile)


        // section 2 -> Epilog
        sectionText = outroText
        prefixAudioFile = AudioManager.audioFileForDisplayName("Outro Start")
        mainAudioFile = AudioManager.audioFileForDisplayName("Outro Main")
        suffixAudioFile = AudioManager.audioFileForDisplayName("Outro End")
        let section2 = EpisodeSection(type: .standard,
                                      name: "Epilog",
                                      rawText: sectionText,
                                      prefixAudioFile: prefixAudioFile,
                                      mainAudioFile: mainAudioFile,
                                      suffixAudioFile: suffixAudioFile)
        
        // build template
        let episodeTemplate = EpisodeTemplate(name: templateName, language: templateLanguage, restrictHeadlinesToHighLights: restrictHeadlinesToHighLights, episodeSections: [section0, section1, section2])
        
        print("Returning template with name \(episodeTemplate.name)")
        
        // return it
        return episodeTemplate
        
    }
    
}
