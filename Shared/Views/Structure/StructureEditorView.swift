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
                        NavigationLink(value: section) {
                            Text(section.name)
                        }
                    }
                }
            }
        }
        .navigationTitle("Structure Editor")
    }
}

struct StructureEditor_Previews: PreviewProvider {
    static var previews: some View {
        StructureEditorView(chosenEpisodeIndex: 0)
    }
}
