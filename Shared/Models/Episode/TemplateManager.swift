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
            
            let standardTemplate = template(forLanguage: .brazilian, edition: .standard)
            templates.append(standardTemplate)
            
            let morningTemplate = template(forLanguage: .brazilian, edition: .morning)
            templates.append(morningTemplate)
            
            let eveningTemplate = template(forLanguage: .brazilian, edition: .evening)
            templates.append(eveningTemplate)

            
        } else { // all other languages
        
            let standardTemplate = template(forLanguage: language, edition: .standard)
            templates.append(standardTemplate)
            
            let newsTemplate = template(forLanguage: language)
            templates.append(newsTemplate)
        }
        
        // store result in cache
        cachedTemplates[language] = templates
        
        // return result
        return templates
    }
    
    func template(forLanguage language: LanguageManager.Language, edition: EpisodeTemplate.Edition? = nil) -> EpisodeTemplate {
        
        let template: EpisodeTemplate
        
        // default fvalues for standard template
        var templateName: String = "Standard"
        let restrictHeadlinesToHighLights: Bool = true
        var introText: String = ""
        var outroText: String = ""
        
        
        switch language {
        case .brazilian:
                        
            switch edition {
            case .standard, .none:
                templateName = "Standard"
                introText = "Olá, hoje é {date}. Eu sou {narrator}."
                outroText = ""
                
            case .morning:
                templateName = "DW Brasil (am)"
                introText = "Olá, hoje é {date}. Eu sou {narrator} e este é o Boletim de Notícias da DW Brasil. Confira nesta edição:"
                outroText = "Novas informações você pode conferir mais tarde na segunda edição do Boletim de Notícias da DW Brasil."
            
            case .evening:
                templateName = "DW Brasil (pm)"
                introText = "Olá, hoje é {date}. Eu sou {narrator} e esta é a segunda edição do Boletim de Notícias da DW Brasil. Confira nesta edição:"
                outroText = "Mais informações, confira no nosso site: dw.com/brasil"
            }
        
        
        case .german:
            
            switch edition {
            case .standard, .none:
                templateName = "Standard"
                introText = "Guten Tag, heute ist {date}. Mein Name ist {narrator}."
                outroText = ""
                
            default:
                templateName = "DW Nachrichten"
                introText = "Guten Tag, heute ist {date}. Mein Name ist {narrator} hier sind die neusten Nachrichten."
                outroText = "Das waren die Nachrichten."
            }

        case .english:
            switch edition {
            case .standard, .none:
                templateName = "Standard"
                introText = "Greetings. It's {date}. My name is {narrator}."
                outroText = ""
                
            default:
                templateName = "DW News"
                introText = "Greetings. It's {date} and this is DW with the latest news. My name is {narrator}."
                outroText = "These were the news. Come back for more."
            }
            
        case .french:
            switch edition {
            case .standard, .none:
                templateName = "Standard"
                introText = "Bonjour, il est {date}. Je m'appelle {narrator}."
                outroText = ""
                
            default:
                templateName = "Info Matin"
                introText = "DW Info Matin du {date}. Je m'appelle {narrator}. Bonjour."
                outroText = "Excellente journée à toutes et à tous et rendez-vous demain matin pour une nouvelle émission de Info Matin. A demain!"
            }
            
        case .spanish:
            switch edition {
            case .standard, .none:
                templateName = "Standard"
                introText = "La noticia del {date}. Mi nombre es {narrator}. Buen día."
                outroText = ""
                
            default:
                templateName = "Las noticias en español"
                introText = "La noticia del {date}. Mi nombre es {narrator}. Buen día."
                outroText = "Que tengan un gran día a todos y nos vemos mañana por la mañana para un nuevo espectáculo. ¡Hasta mañana!"
            }
        }
        
        // Create template. USe audio only if this is not the standard template
        template = createTemplate(name: templateName, forLanguage: language, restrictHeadlinesToHighLights: restrictHeadlinesToHighLights, introText: introText, outroText: outroText, useAudio: edition != .standard)
        
        return template
        
    }
    
    private func createTemplate(name templateName: String, forLanguage templateLanguage: LanguageManager.Language, restrictHeadlinesToHighLights: Bool, introText: String, outroText: String, useAudio: Bool) -> EpisodeTemplate {
        
        var prefixAudioFile: AudioManager.AudioFile = AudioManager.audioFileForDisplayName("None")
        var mainAudioFile: AudioManager.AudioFile = AudioManager.audioFileForDisplayName("None")
        var suffixAudioFile: AudioManager.AudioFile = AudioManager.audioFileForDisplayName("None")
        var separatorAudioFile: AudioManager.AudioFile = AudioManager.audioFileForDisplayName("None")
                
        // section 0 -> Introduction & Headlines
        if useAudio {
            prefixAudioFile = AudioManager.audioFileForDisplayName("Intro Start")
            mainAudioFile = AudioManager.audioFileForDisplayName("Intro Main")
            suffixAudioFile = AudioManager.audioFileForDisplayName("Intro End")
        }
        let section0 = EpisodeSection(type: .headlines,
                                      name: "Introduction & Headlines",
                                      rawText: introText,
                                      prefixAudioFile: prefixAudioFile,
                                      mainAudioFile: mainAudioFile,
                                      suffixAudioFile: suffixAudioFile)
        
        // section 1 -> Stories
        if useAudio {
            separatorAudioFile = AudioManager.audioFileForDisplayName("Sting")
        }
        let section1 = EpisodeSection(type: .stories, name: "Stories", separatorAudioFile: separatorAudioFile)


        // section 2 -> Epilog
        if useAudio {
            prefixAudioFile = AudioManager.audioFileForDisplayName("Outro Start")
            mainAudioFile = AudioManager.audioFileForDisplayName("Outro Main")
            suffixAudioFile = AudioManager.audioFileForDisplayName("Outro End")
        }
        let section2 = EpisodeSection(type: .standard,
                                      name: "Epilog",
                                      rawText: outroText,
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
