//
//  StructureEditorView.swift
//  Podcast Creator
//
//  Created by Andy Giefer on 10.02.23.
//

import SwiftUI

struct StructureEditorView: View {
    
    var chosenEpisodeIndex: Int?
    @EnvironmentObject var episodeViewModel: EpisodeViewModel
    
    var episodeSections: [EpisodeSection] {
        let sections = episodeViewModel[chosenEpisodeIndex].sections
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
            if let sectionIndex = episodeViewModel[chosenEpisodeIndex].sections.firstIndex(where: {$0.id == sectionId}) {
                // use it to get a binding to the section
                let sectionBinding = $episodeViewModel[chosenEpisodeIndex].sections[sectionIndex]
                
                // call SectionEditView
                SectionEditView(chosenEpisodeIndex: chosenEpisodeIndex, section: sectionBinding)
            }
        }
    }
}

struct StructureEditor_Previews: PreviewProvider {
    static var previews: some View {
        StructureEditorView(chosenEpisodeIndex: 0)
    }
}
