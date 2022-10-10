//
//  EpisodeTemplate.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 09.10.22.
//

import Foundation

struct EpisodeTemplate {
    var name: String
    var language: LanguageManager.Language
    var episodeSections: [EpisodeSection]
}

extension EpisodeTemplate {
    
    static func dwBrazil() -> EpisodeTemplate {
        
        let templateName = "DW Brasil (Morning)"
        let templateLanguage = LanguageManager.Language.brazilian
        
        var sectionText: String
        var prefixAudioFile: AudioManager.AudioFile
        var mainAudioFile: AudioManager.AudioFile
        var suffixAudioFile: AudioManager.AudioFile
        var separatorAudioFile: AudioManager.AudioFile
        
        // section 0 -> Intro
        sectionText = "Olá, hoje é {date}. Eu sou {speakerName} e você ouve a primeira edição do dia do boletim de notícias da DW Brasil. Confira nesta edição:"
        prefixAudioFile = AudioManager.audioFileForDisplayName("Intro Start")
        mainAudioFile = AudioManager.audioFileForDisplayName("Intro Main")
        suffixAudioFile = AudioManager.audioFileForDisplayName("Intro End")
        let section0 = EpisodeSection(type: .standard,
                                      name: "Introduction",
                                      text: sectionText,
                                      prefixAudioFile: prefixAudioFile,
                                      mainAudioFile: mainAudioFile,
                                      suffixAudioFile: suffixAudioFile)
        
        // section 1 -> Headlines
        let section1 = EpisodeSection(type: .headlines, name: "Headlines")
        
        // section 2 -> Stories
        separatorAudioFile = AudioManager.audioFileForDisplayName("Sting")
        let section2 = EpisodeSection(type: .stories, name: "Stories", separatorAudioFile: separatorAudioFile)

        // section 3 -> Epilog
        sectionText = "Novas informações você pode conferir mais tarde na segunda edição do Boletim de Notícias da DW Brasil."
        prefixAudioFile = AudioManager.audioFileForDisplayName("Outro Start")
        mainAudioFile = AudioManager.audioFileForDisplayName("Outro Main")
        suffixAudioFile = AudioManager.audioFileForDisplayName("Outro End")
        let section3 = EpisodeSection(type: .standard,
                                      name: "Epilog",
                                      text: sectionText,
                                      prefixAudioFile: prefixAudioFile,
                                      mainAudioFile: mainAudioFile,
                                      suffixAudioFile: suffixAudioFile)
        
        // build template
        let episodeTemplate = EpisodeTemplate(name: templateName, language: templateLanguage, episodeSections: [section0, section1, section2, section3])
        
        // return it
        return episodeTemplate
    }
}
