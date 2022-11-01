//
//  EpisodeTemplate.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 09.10.22.
//

import Foundation

struct EpisodeTemplate: Hashable, Identifiable {
    var id: String {return name}
    
    var name: String
    var language: LanguageManager.Language
    var restrictHeadlinesToHighLights = false
    var episodeSections: [EpisodeSection]
}

extension EpisodeTemplate {

    static func templates(forLanguage language: LanguageManager.Language) -> [EpisodeTemplate] {
        
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
        
        return templates
    }
    
}

extension EpisodeTemplate {
    
    enum Edition: String {
        case morning, evening
    }
    
    static func template(forLanguage language: LanguageManager.Language, edition: Edition? = nil) -> EpisodeTemplate {
        
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
                templateName = "DW Brasil (morning)"
                introText = "Olá, hoje é {date}. Eu sou {narrator} e este é o Boletim de Notícias da DW Brasil. Confira nesta edição:"
                outroText = "Novas informações você pode conferir mais tarde na segunda edição do Boletim de Notícias da DW Brasil."
            
            case .evening:
                templateName = "DW Brasil (evening)"
                introText = "Olá, hoje é {date}. Eu sou {narrator} e esta é a segunda edição do Boletim de Notícias da DW Brasil. Confira nesta edição:"
                outroText = "Mais informações, confira no nosso site: dw.com/brasil"
            }
        
        
        case .german:
            templateName = "DW Nachrichten"
            restrictHeadlinesToHighLights = false
            introText = "Guten Tag, hier sind die neusten Nachrichten vom {date}."
            outroText = "Das waren die Nachrichten"

        case .english:
            templateName = "DW News"
            restrictHeadlinesToHighLights = false
            introText = "Greetings. It's {date}. These are the latest news."
            outroText = "The were the latest news. Come back for more."
            
        }
        
        template = createTemplate(name: templateName, forLanguage: language, restrictHeadlinesToHighLights: restrictHeadlinesToHighLights, introText: introText, outroText: outroText)
        
        return template
        
    }
    
    private static func createTemplate(name: String, forLanguage language: LanguageManager.Language, restrictHeadlinesToHighLights: Bool, introText: String, outroText: String) -> EpisodeTemplate {
        
        var templateName: String
        var templateLanguage: LanguageManager.Language
        var sectionText: String
        var prefixAudioFile: AudioManager.AudioFile
        var mainAudioFile: AudioManager.AudioFile
        var suffixAudioFile: AudioManager.AudioFile
        var separatorAudioFile: AudioManager.AudioFile
        
        templateName = name
        templateLanguage = language
        
        // section 0 -> Introduction & Headlines
        prefixAudioFile = AudioManager.audioFileForDisplayName("Intro Start")
        mainAudioFile = AudioManager.audioFileForDisplayName("Intro Main")
        suffixAudioFile = AudioManager.audioFileForDisplayName("Intro End")
        let section0 = EpisodeSection(type: .headlines,
                                      name: "Introduction & Headlines",
                                      text: introText,
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
                                      text: sectionText,
                                      prefixAudioFile: prefixAudioFile,
                                      mainAudioFile: mainAudioFile,
                                      suffixAudioFile: suffixAudioFile)
        
        // build template
        let episodeTemplate = EpisodeTemplate(name: templateName, language: templateLanguage, restrictHeadlinesToHighLights: restrictHeadlinesToHighLights, episodeSections: [section0, section1, section2])
        
        // return it
        return episodeTemplate
        
    }
    
}
