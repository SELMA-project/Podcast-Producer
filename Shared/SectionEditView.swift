//
//  SectionEditView.swift
//  Podcast Producer
//
//  Created by Andy on 01.10.22.
//

import SwiftUI

struct SectionEditView: View {
    
    @ObservedObject var episodeViewModel: EpisodeViewModel
    var sectionNumber: Int
    
    var episodeSection: EpisodeSection {
        return episodeViewModel.availableEpisodes[episodeViewModel.chosenEpisodeIndex].sections[sectionNumber]
    }
    
    var body: some View {
        Form {
            
            Section("Name") {
                TextField("Name", text: $episodeViewModel.availableEpisodes[episodeViewModel.chosenEpisodeIndex].sections[sectionNumber].name, axis: .vertical)
            }
            
            Section("Type") {
                Text(episodeSection.type.rawValue)
            }
            
            if episodeSection.type == .stories {
                Section("Headline") {
                    TextField("Name", text: $episodeViewModel.availableEpisodes[episodeViewModel.chosenEpisodeIndex].sections[sectionNumber].headline, axis: .vertical)
                }
            }
            
            if episodeSection.type != .headlines {
                Section("Text") {
                    TextField("Name", text: $episodeViewModel.availableEpisodes[episodeViewModel.chosenEpisodeIndex].sections[sectionNumber].text, axis: .vertical)
                }
            }
            
        }
        .padding()
        .navigationTitle("Section Editor")
        
    }
}

struct SectionEditView_Previews: PreviewProvider {
    static var previews: some View {
        let episodeViewModel = EpisodeViewModel()
        SectionEditView(episodeViewModel: episodeViewModel, sectionNumber: 0)
    }
}
