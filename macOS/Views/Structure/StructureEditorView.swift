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
    @Environment(\.dismiss) var dismissAction
    
    var episodeSections: [EpisodeSection] {
        let sections = episodeViewModel[chosenEpisodeId].sections
        return sections
    }
    
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading) {
                
                // Title next to a dismiss button
                HStack {
                    Text("Structure").font(.title)
                    Spacer()
                    Button {
                        dismissAction()
                    } label: {
                        Image(systemName: "x.circle")
                            .font(.title3)
                    }.buttonStyle(.borderless)
                }
                
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
        }
 

       
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
