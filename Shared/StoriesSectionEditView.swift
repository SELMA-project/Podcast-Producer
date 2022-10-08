//
//  StoriesSectionEditView.swift
//  Podcast Producer
//
//  Created by Andy on 08.10.22.
//

import SwiftUI

struct StoriesSectionEditView: View {
    var section: EpisodeSection
    @State var name: String
    
    @EnvironmentObject var viewModel: EpisodeViewModel
    
    init(section: EpisodeSection) {
        self.section = section
        _name = State(initialValue: section.name)
    }
    
    var stories: [Story] {
        return viewModel.availableEpisodes[viewModel.chosenEpisodeIndex].stories
    }
    
    var body: some View {
        
        let nameBinding = Binding {
             self.name
         } set: { newValue in
             self.name = newValue
             
             // update section
             var updatedSection = section // copy
             updatedSection.name = newValue
             viewModel.updateEpisodeSection(updatedSection)
         }
        
        
        Form {
            Section("Name") {
                TextField("Name", text: nameBinding)
            }
            Section("Stories") {
                ForEach(stories) {story in
                    NavigationLink(value: story) {
                        Text(story.headline)
                    }
                }
            }
        }
        .navigationDestination(for: Story.self) { story in
            StoryEditView(story: story)
        }
        .navigationTitle("Section Editor")
    }
}

struct StoriesSectionEditView_Previews: PreviewProvider {
    static var previews: some View {
        let section = EpisodeSection(type: .standard, name: "Introduction")
        StoriesSectionEditView(section: section)
    }
}
