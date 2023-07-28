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
    
    /// Returns all available templates for the given language.
    /// - Parameter language: The language of interest.
    /// - Returns: An array of templates.
    func availableTemplates(forLanguage language: LanguageManager.Language) -> [EpisodeTemplate] {
        return allTemplates.filter({$0.language == language})
    }
    
}

// MARK: Template Creation
extension TemplateManager {
    
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
        introText = "हलो, आज है {date}. DW Hindi के आज के न्यूज पॉडकास्ट में आपका स्वागत है. आपके लिए खबरों के चुनाव किया है {narrator} ने."
        outroText = "इस न्यूज पॉडकास्ट को सिंथेटिक वॉयस की मदद से तैयार किया गया है. अपनी प्रतिक्रियाएं हमें hindi@dw.com पर भेजें. अगली बार फिर मिलेंगे."
        useAudio = true
        template = createTemplate(name: templateName, forLanguage: language, restrictHeadlinesToHighLights: restrictHeadlinesToHighLights, introText: introText, outroText: outroText, useAudio: useAudio)
        templates.append(template)
                
        return templates
    }
}
