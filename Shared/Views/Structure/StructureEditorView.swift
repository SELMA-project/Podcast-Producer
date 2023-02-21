//
//  StructureEditorView.swift
//  Podcast Creator
//
//  Created by Andy Giefer on 10.02.23.
//

import SwiftUI

struct StructureEditorView: View {
    
    var chosenEpisodeId: UUID
    @EnvironmentObject var episodeViewModel: EpisodeViewModel
    
    var chosenEpisodeIndex: Int {
        return episodeViewModel.episodeIndexForId(episodeId: chosenEpisodeId)!
    }
    
    var episodeSections: [EpisodeSection] {
        let sections = episodeViewModel[chosenEpisodeId].sections
        return sections
    }
    
    var body: some View {
        Form {
            Section("Structure") {
                if episodeSections.count == 0 {
                    Text("No defined structure")
                } else {
                    ForEach(episodeSections) {section in
                        NavigationLink(value: section.id) {
                            Text(section.name)
                        }
                    }
                }
            }
        }
        .navigationTitle("Structure Editor")
        .navigationDestination(for: EpisodeSection.SectionId.self) { sectionId in
            
            // get the section's index
            if let sectionIndex = episodeViewModel[chosenEpisodeId].sections.firstIndex(where: {$0.id == sectionId}) {
                // use it to get a binding to the section
                let sectionBinding = $episodeViewModel[chosenEpisodeId].sections[sectionIndex]
                
                // call SectionEditView
                SectionEditView(chosenEpisodeId: chosenEpisodeId, section: sectionBinding)
            }
        }
    }
}

struct StructureEditor_Previews: PreviewProvider {
    static var previews: some View {
        let episodeViewModel = EpisodeViewModel()
        if episodeViewModel.availableEpisodes.count > 0 {
            let firstEpisodeId = episodeViewModel.availableEpisodes[0].id
            StructureEditorView(chosenEpisodeId: firstEpisodeId)
        } else {
            Text("No episode to display")
        }
    }
}
