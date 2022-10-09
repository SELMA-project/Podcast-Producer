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
    @State var prefixAudioFile: AudioManager.AudioFile
    @State var mainAudioFile: AudioManager.AudioFile
    @State var suffixAudioFile: AudioManager.AudioFile
    
    @EnvironmentObject var viewModel: EpisodeViewModel
    
    init(section: EpisodeSection) {
        self.section = section
        _name = State(initialValue: section.name)
        _text = State(initialValue: section.text)
        
        _prefixAudioFile = State(initialValue: section.prefixAudioFile)
        _mainAudioFile = State(initialValue: section.mainAudioFile)
        _suffixAudioFile = State(initialValue: section.suffixAudioFile)
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
            
            Section {
                Picker("Before", selection: $prefixAudioFile) {
                    ForEach(AudioManager.availableAudioFiles(), id: \.self) {audioFile in
                        Text(audioFile.displayName).tag(audioFile)
                    }
                }.pickerStyle(.menu)
                
                Picker("While", selection: $mainAudioFile) {
                    ForEach(AudioManager.availableAudioFiles(), id: \.self) {audioFile in
                        Text(audioFile.displayName).tag(audioFile)
                    }
                }.pickerStyle(.menu)

                Picker("After", selection: $suffixAudioFile) {
                    ForEach(AudioManager.availableAudioFiles(), id: \.self) {audioFile in
                        Text(audioFile.displayName).tag(audioFile)
                    }
                }.pickerStyle(.menu)
            } header: {
                Text("Audio")
            } footer: {
                Text("Audio that plays before, while and after the text is spoken")
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
