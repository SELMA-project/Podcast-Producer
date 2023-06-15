//
//  TemplateManager.swift
//  Podcast Creator
//
//  Created by Andy Giefer on 27.01.23.
//

import Foundation

class TemplateManager {
    
    static let shared = TemplateManager()
    
    var allTemplates = [EpisodeTemplate]()
    
    init() {
        allTemplates.append(contentsOf: brazilianTemplates())
        allTemplates.append(contentsOf: germanTemplates())
        allTemplates.append(contentsOf: englishTemplates())
        allTemplates.append(contentsOf: frenchTemplates())
        allTemplates.append(contentsOf: spanishTemplates())
        allTemplates.append(contentsOf: hindiTemplates())
    }
    
    func availableTemplates(forLanguage language: LanguageManager.Language) -> [EpisodeTemplate] {
        return allTemplates.filter({$0.language == language})
    }
    
}

// MARK: Template Creation
extension TemplateManager {
    
//    func availableTemplatesOld(forLanguage language: LanguageManager.Language) -> [EpisodeTemplate] {
//
//        // early return with cached result
//        if let templates = cachedTemplates[language] {
//            return templates
//        }
//
//        var templates = [EpisodeTemplate]()
//
//        if language == .brazilian {
//
//            let morningTemplate = template(forLanguage: .brazilian, edition: .morning)
//            templates.append(morningTemplate)
//
//            let eveningTemplate = template(forLanguage: .brazilian, edition: .evening)
//            templates.append(eveningTemplate)
//
//            let speechOnlyTemplate = template(forLanguage: .brazilian, edition: .speechOnly)
//            templates.append(speechOnlyTemplate)
//
//        } else { // all other languages
//
//            let newsTemplate = template(forLanguage: language, edition: .news)
//            templates.append(newsTemplate)
//
//            let speechOnlyTemplate = template(forLanguage: language, edition: .speechOnly)
//            templates.append(speechOnlyTemplate)
//        }
//
//        // store result in cache
//        cachedTemplates[language] = templates
//
//        // return result
//        return templates
//    }
    
//    func template(forLanguage language: LanguageManager.Language, edition: EpisodeTemplate.Edition) -> EpisodeTemplate {
//
//        let template: EpisodeTemplate
//
//        // default values for standard template
//        var templateName: String = "Speech only"
//        let restrictHeadlinesToHighLights: Bool = true
//        var introText: String = ""
//        var outroText: String = ""
//
//
//        switch language {
//        case .brazilian:
//
//            switch edition {
//            case .speechOnly:
//                templateName = "Speech only"
//                introText = "Olá, hoje é {date}. Eu sou {narrator}."
//                outroText = ""
//
//            case .morning:
//                templateName = "DW Brasil (am)"
//                introText = "Olá, hoje é {date}. Eu sou {narrator} e este é o Boletim de Notícias da DW Brasil. Confira nesta edição:"
//                outroText = "Novas informações você pode conferir mais tarde na segunda edição do Boletim de Notícias da DW Brasil."
//
//            case .evening:
//                templateName = "DW Brasil (pm)"
//                introText = "Olá, hoje é {date}. Eu sou {narrator} e esta é a segunda edição do Boletim de Notícias da DW Brasil. Confira nesta edição:"
//                outroText = "Mais informações, confira no nosso site: dw.com/brasil"
//
//            default:
//                break
//            }
//
//
//        case .german:
//
//            switch edition {
//            case .speechOnly:
//                templateName = "Speech only"
//                introText = "Guten Tag, heute ist {date}. Mein Name ist {narrator}."
//                outroText = ""
//
//            case .news:
//                templateName = "DW Nachrichten"
//                introText = "Guten Tag, heute ist {date}. Mein Name ist {narrator} hier sind die neusten Nachrichten."
//                outroText = "Das waren die Nachrichten."
//
//            default:
//                break
//            }
//
//        case .english:
//            switch edition {
//            case .speechOnly:
//                templateName = "Speech only"
//                introText = "Greetings. It's {date}. My name is {narrator}."
//                outroText = ""
//
//            case .news:
//                templateName = "DW News"
//                introText = "Greetings. It's {date} and this is DW with the latest news. My name is {narrator}."
//                outroText = "These were the news. Come back for more."
//
//            default:
//                break
//            }
//
//        case .french:
//            switch edition {
//            case .speechOnly:
//                templateName = "Speech only"
//                introText = "Bonjour, il est {date}. Je m'appelle {narrator}."
//                outroText = ""
//
//            case .news:
//                templateName = "Info Matin"
//                introText = "DW Info Matin du {date}. Je m'appelle {narrator}. Bonjour."
//                outroText = "Excellente journée à toutes et à tous et rendez-vous demain matin pour une nouvelle émission de Info Matin. A demain!"
//
//            default:
//                break
//            }
//
//        case .spanish:
//            switch edition {
//            case .speechOnly:
//                templateName = "Speech only"
//                introText = "La noticia del {date}. Mi nombre es {narrator}. Buen día."
//                outroText = ""
//
//            case .news:
//                templateName = "Las noticias en español"
//                introText = "La noticia del {date}. Mi nombre es {narrator}. Buen día."
//                outroText = "Que tengan un gran día a todos y nos vemos mañana por la mañana para un nuevo espectáculo. ¡Hasta mañana!"
//
//            default:
//                break
//            }
//
//        case .hindi:
//            switch edition {
//            case .speechOnly:
//                templateName = "Speech only"
//                introText = "Bonjour, il est {date}. Je m'appelle {narrator}."
//                outroText = ""
//
//            case .news:
//                templateName = "Standard"
//                introText = "अभिवादन।"
//                outroText = ""
//
//            default:
//                break
//            }
//
//        }
//
//        // Create template. Use audio only if this is not the standard template
//        template = createTemplate(name: templateName, forLanguage: language, restrictHeadlinesToHighLights: restrictHeadlinesToHighLights, introText: introText, outroText: outroText, useAudio: edition != .speechOnly)
//
//        return template
//
//    }
    
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

// MARK: Brazilian
extension TemplateManager {
    
    private func brazilianTemplates() -> [EpisodeTemplate] {
        
        var templates = [EpisodeTemplate]()

        let language: LanguageManager.Language = .brazilian
        
        var templateName: String
        var restrictHeadlinesToHighLights: Bool
        var introText: String
        var outroText: String
        var useAudio: Bool

        var template: EpisodeTemplate
        
        // morning
        templateName = "DW Brasil (am)"
        restrictHeadlinesToHighLights = true
        introText = "Olá, hoje é {date}. Eu sou {narrator} e este é o Boletim de Notícias da DW Brasil. Confira nesta edição:"
        outroText = "Novas informações você pode conferir mais tarde na segunda edição do Boletim de Notícias da DW Brasil."
        useAudio = true
        template = createTemplate(name: templateName, forLanguage: language, restrictHeadlinesToHighLights: restrictHeadlinesToHighLights, introText: introText, outroText: outroText, useAudio: useAudio)
        templates.append(template)
        
        // evening
        templateName = "DW Brasil (pm)"
        restrictHeadlinesToHighLights = true
        introText = "Olá, hoje é {date}. Eu sou {narrator} e este é o Boletim de Notícias da DW Brasil. Confira nesta edição:"
        outroText = "Novas informações você pode conferir mais tarde na segunda edição do Boletim de Notícias da DW Brasil."
        useAudio = true
        template = createTemplate(name: templateName, forLanguage: language, restrictHeadlinesToHighLights: restrictHeadlinesToHighLights, introText: introText, outroText: outroText, useAudio: useAudio)
        templates.append(template)
        
        return templates
    }
}


// MARK: German
extension TemplateManager {
    
    private func germanTemplates() -> [EpisodeTemplate] {
        
        var templates = [EpisodeTemplate]()

        let language: LanguageManager.Language = .german
        
        var templateName: String
        var restrictHeadlinesToHighLights: Bool
        var introText: String
        var outroText: String
        var useAudio: Bool

        var template: EpisodeTemplate
        
        // News
        templateName = "DW Nachrichten"
        restrictHeadlinesToHighLights = true
        introText = "Guten Tag, heute ist {date}. Mein Name ist {narrator}."
        outroText = "Das waren die Nachrichten."
        useAudio = true
        template = createTemplate(name: templateName, forLanguage: language, restrictHeadlinesToHighLights: restrictHeadlinesToHighLights, introText: introText, outroText: outroText, useAudio: useAudio)
        templates.append(template)
                
        return templates
    }
}

// MARK: English
extension TemplateManager {
    
    private func englishTemplates() -> [EpisodeTemplate] {
        
        var templates = [EpisodeTemplate]()

        let language: LanguageManager.Language = .english
        
        var templateName: String
        var restrictHeadlinesToHighLights: Bool
        var introText: String
        var outroText: String
        var useAudio: Bool

        var template: EpisodeTemplate
        
        // News
        templateName = "DW News"
        restrictHeadlinesToHighLights = true
        introText = "Greetings. It's {date} and this is DW with the latest news. My name is {narrator}."
        outroText = "These were the news. Come back for more."
        useAudio = true
        template = createTemplate(name: templateName, forLanguage: language, restrictHeadlinesToHighLights: restrictHeadlinesToHighLights, introText: introText, outroText: outroText, useAudio: useAudio)
        templates.append(template)
                
        return templates
    }
}


// MARK: French
extension TemplateManager {
    
    private func frenchTemplates() -> [EpisodeTemplate] {
        
        var templates = [EpisodeTemplate]()

        let language: LanguageManager.Language = .french
        
        var templateName: String
        var restrictHeadlinesToHighLights: Bool
        var introText: String
        var outroText: String
        var useAudio: Bool

        var template: EpisodeTemplate
        
        // News
        templateName = "Info Matin"
        restrictHeadlinesToHighLights = true
        introText = "DW Info Matin du {date}. Je m'appelle {narrator}. Bonjour."
        outroText = "Excellente journée à toutes et à tous et rendez-vous demain matin pour une nouvelle émission de Info Matin. A demain!"
        useAudio = true
        template = createTemplate(name: templateName, forLanguage: language, restrictHeadlinesToHighLights: restrictHeadlinesToHighLights, introText: introText, outroText: outroText, useAudio: useAudio)
        templates.append(template)
                
        return templates
    }
}


// MARK: Spanish
extension TemplateManager {
    
    private func spanishTemplates() -> [EpisodeTemplate] {
        
        var templates = [EpisodeTemplate]()

        let language: LanguageManager.Language = .spanish
        
        var templateName: String
        var restrictHeadlinesToHighLights: Bool
        var introText: String
        var outroText: String
        var useAudio: Bool

        var template: EpisodeTemplate
        
        // News
        templateName = "Las noticias en español"
        restrictHeadlinesToHighLights = true
        introText = "La noticia del {date}. Mi nombre es {narrator}. Buen día."
        outroText = "Que tengan un gran día a todos y nos vemos mañana por la mañana para un nuevo espectáculo. ¡Hasta mañana!"
        useAudio = true
        template = createTemplate(name: templateName, forLanguage: language, restrictHeadlinesToHighLights: restrictHeadlinesToHighLights, introText: introText, outroText: outroText, useAudio: useAudio)
        templates.append(template)
                
        return templates
    }
}



// MARK: Hindi
extension TemplateManager {
    
    private func hindiTemplates() -> [EpisodeTemplate] {
        
        var templates = [EpisodeTemplate]()

        let language: LanguageManager.Language = .hindi
        
        var templateName: String
        var restrictHeadlinesToHighLights: Bool
        var introText: String
        var outroText: String
        var useAudio: Bool

        var template: EpisodeTemplate
        
        // News
        templateName = "Hindi News"
        restrictHeadlinesToHighLights = true
        introText = "अभिवादन।"
        outroText = "अलविदा"
        useAudio = true
        template = createTemplate(name: templateName, forLanguage: language, restrictHeadlinesToHighLights: restrictHeadlinesToHighLights, introText: introText, outroText: outroText, useAudio: useAudio)
        templates.append(template)
                
        return templates
    }
}
