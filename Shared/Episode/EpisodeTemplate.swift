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
        

        // section 0 -> Introduction & Headlines
        prefixAudioFile = AudioManager.audioFileForDisplayName("Intro Start")
        mainAudioFile = AudioManager.audioFileForDisplayName("Intro Main")
        suffixAudioFile = AudioManager.audioFileForDisplayName("Intro End")
        let section0 = EpisodeSection(type: .headlines,
                                      name: "Introduction & Headlines",
                                      prefixAudioFile: prefixAudioFile,
                                      mainAudioFile: mainAudioFile,
                                      suffixAudioFile: suffixAudioFile)
        
        // section 1 -> Stories
        separatorAudioFile = AudioManager.audioFileForDisplayName("Sting")
        let section1 = EpisodeSection(type: .stories, name: "Stories", separatorAudioFile: separatorAudioFile)

        // section 2 -> Epilog
        sectionText = "Novas informações você pode conferir mais tarde na segunda edição do Boletim de Notícias da DW Brasil."
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
        let episodeTemplate = EpisodeTemplate(name: templateName, language: templateLanguage, episodeSections: [section0, section1, section2])
        
        // return it
        return episodeTemplate
    }
}
