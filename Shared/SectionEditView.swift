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
             
             // update section in viewModel
             viewModel.updateEpisodeSection(sectionId: section.id, newName: newValue)
         }
        
        let textBinding = Binding {
             self.text
         } set: { newValue in
             self.text = newValue
             
             // update section in viewModel
             viewModel.updateEpisodeSection(sectionId: section.id, newText: newValue)
         }
        
        let prefixAudioFileBinding = Binding {
             self.prefixAudioFile
         } set: { newValue in
             self.prefixAudioFile = newValue
             
             // update section in viewModel
             viewModel.updateEpisodeSection(sectionId: section.id, newPrefixAudioFile: newValue)
         }
        
        let mainAudioFileBinding = Binding {
             self.mainAudioFile
         } set: { newValue in
             self.mainAudioFile = newValue
             
             // update section in viewModel
             viewModel.updateEpisodeSection(sectionId: section.id, newMainAudioFile: newValue)
         }
        
        let suffixAudioFileBinding = Binding {
             self.suffixAudioFile
         } set: { newValue in
             self.suffixAudioFile = newValue
             
             // update section in viewModel
             viewModel.updateEpisodeSection(sectionId: section.id, newSuffixAudioFile: newValue)
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
                Picker("Before", selection: prefixAudioFileBinding) {
                    ForEach(AudioManager.availableAudioFiles(), id: \.self) {audioFile in
                        Text(audioFile.displayName).tag(audioFile)
                    }
                }.pickerStyle(.menu)
                
                Picker("While", selection: mainAudioFileBinding) {
                    ForEach(AudioManager.availableAudioFiles(), id: \.self) {audioFile in
                        Text(audioFile.displayName).tag(audioFile)
                    }
                }.pickerStyle(.menu)

                Picker("After", selection: suffixAudioFileBinding) {
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
