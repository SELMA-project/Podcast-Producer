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
    
    var episodeSections: [EpisodeSection] {
        let sections = episodeViewModel[chosenEpisodeId].sections
        return sections
    }
    
    var body: some View {
        

            
        VStack(alignment: .leading) {
            
            Text("Structure").font(.title)
            
            ForEach(episodeSections) {section in
                DisclosureGroup {
                    // get the section's index
                    if let sectionIndex = episodeViewModel[chosenEpisodeId].sections.firstIndex(where: {$0.id == section.id}) {
                        // use it to get a binding to the section
                        let sectionBinding = $episodeViewModel[chosenEpisodeId].sections[sectionIndex]
                        
                        // call SectionEditView
                        SectionEditView(chosenEpisodeId: chosenEpisodeId, section: sectionBinding)
                            .padding(.top)
                    }
                } label: {
                    Text(section.name)
                        .bold()
                }
            }
            
            Spacer()
        }
        // fix ideal size horizontally and vertically
        //.fixedSize(horizontal: true, vertical: false)

       
    }
}

struct StructureEditor_Previews: PreviewProvider {
    static var previews: some View {
        
        let episodeViewModel = EpisodeViewModel()
        
        if let firstEpisodeId = episodeViewModel.firstEpisodeId {
        
            StructureEditorView(chosenEpisodeId: firstEpisodeId)
                .frame(width: 400)
                .environmentObject(episodeViewModel)
        } else {
            Text("No episode to display")
        }
    }
}
