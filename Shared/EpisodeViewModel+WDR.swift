//
//  EpisodeViewModel+WDR.swift
//  Podcast Creator (macOS)
//
//  Created by Andy Giefer on 08.09.23.
//

import Foundation
import WDRKit
import SwiftUI

// MARK: - WDR Pressespiegel

extension EpisodeViewModel {
    
    /// Selected a file to import. The id of the created episode is passed back.
    func openPresseSpiegel() -> UUID? {
        
        let dialog = NSOpenPanel();

        dialog.title                   = "Wählen Sie einen Pressespiegel im JSON Format aus.";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.allowsMultipleSelection = false;
        dialog.canChooseDirectories = false;
        dialog.allowedContentTypes = [.json]

        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            if let fileURL = dialog.url {// Pathname of the file

                let newEpisodeId = createWDRPresseSpiegelEpisode(basedOnfileURL: fileURL)
                return newEpisodeId
            }
            
        } else {
            // User clicked on "Cancel"
            return nil
        }
        
        return nil
    }
    
    /// Creates a new episode containing the Pressespiegel stories contained in fileURL. The id of the newly created episode is passed back.
    private func createWDRPresseSpiegelEpisode(basedOnfileURL fileURL: URL) -> UUID? {
        
        // new template
        let template = TemplateManager.shared.wdrTemplates()[0]
        
        // add an empty episode
        addEpisode(basedOnTemplate: template)
        
        // the last episodeId is the ID of the new episode
        let chosenEpisodeId = lastEpisodeId
        
        let wdrImporter = WDRImporter()
        
        Task {
            // parse data contained in dropped file
            let presseSpiegel = await wdrImporter.getPresseSpiegel(fileURL: fileURL)
            
            var counter = 0
            
            for artikel in presseSpiegel.artikelArray {
                
                // copy metadata
                let headline = artikel.hauptTitel
                var storyText = artikel.sonstigerTitel
                storyText += "\n\n" + artikel.artikelInhaltText
                
                // build story
                let story = Story(usedInIntroduction: true, headline: headline, storyText: storyText)
                
                // add  to chosen episode
                self[chosenEpisodeId].stories.append(story)
                
                counter += 1
                
                if counter == 3 {
                    break
                }
            }
        }
        
        return chosenEpisodeId
    }
}

// MARK: WDR
extension TemplateManager {
    
    func wdrTemplates() -> [EpisodeTemplate] {
        
        var templates = [EpisodeTemplate]()

        let language: LanguageManager.Language = .german
        
        var templateName: String
        var restrictHeadlinesToHighLights: Bool
        var introText: String
        var outroText: String
        var useAudio: Bool

        var template: EpisodeTemplate
        
        // News
        templateName = "WDR Pressespiegel"
        restrictHeadlinesToHighLights = true
        introText = "Guten Tag, heute ist {date}. Mein Name ist {narrator}."
        outroText = "Das war der Pressespiegel."
        useAudio = false
        template = createTemplate(name: templateName, forLanguage: language, restrictHeadlinesToHighLights: restrictHeadlinesToHighLights, introText: introText, outroText: outroText, useAudio: useAudio)
        templates.append(template)
                
        return templates
    }
}
