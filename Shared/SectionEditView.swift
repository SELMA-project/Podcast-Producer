//
//  SectionEditView.swift
//  Podcast Producer
//
//  Created by Andy on 01.10.22.
//

import SwiftUI

struct SectionEditView: View {
    
    var section: EpisodeSection
    @State var name: String
    @State var text: String
    
    @EnvironmentObject var viewModel: EpisodeViewModel
    
    init(section: EpisodeSection) {
        self.section = section
        _name = State(initialValue: section.name)
        _text = State(initialValue: section.text)
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
        
        let textBinding = Binding {
             self.text
         } set: { newValue in
             self.text = newValue
             
             // update section
             var updatedSection = section // copy
             updatedSection.text = newValue
             viewModel.updateEpisodeSection(updatedSection)
         }
        
        Form {
            Section("Name") {
                TextField("Name", text: nameBinding)
            }
            
            if section.type == .standard {
                Section("Text") {
                    TextField("Text", text: textBinding, axis: .vertical)
                }
            }
            
            if section.type == .headlines {
                Section("Configuration") {
                    Text("Use highights only")
                }
            }
            
            if section.type == .stories {
                Section("Stories") {
                    ForEach(stories) {story in
                        NavigationLink(value: story) {
                            Text(story.headline)
                        }
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

struct SectionEditView_Previews: PreviewProvider {
    static var previews: some View {
        let section = EpisodeSection(type: .standard, name: "Introduction")
        SectionEditView(section: section)
    }
}
