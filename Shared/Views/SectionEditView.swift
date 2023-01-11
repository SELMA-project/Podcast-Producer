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
    @State var separatorAudioFile: AudioManager.AudioFile

    
    @EnvironmentObject var viewModel: EpisodeViewModel
    
    init(section: EpisodeSection) {
        self.section = section
        _name = State(initialValue: section.name)
        _text = State(initialValue: section.rawText)
        
        _prefixAudioFile = State(initialValue: section.prefixAudioFile)
        _mainAudioFile = State(initialValue: section.mainAudioFile)
        _suffixAudioFile = State(initialValue: section.suffixAudioFile)
        _separatorAudioFile = State(initialValue: section.separatorAudioFile)
    }
    
    var stories: [Story] {
        return viewModel.chosenEpisode.stories
    }
    
    /// The text displayed under the audio section
    var pickerExplainerText: LocalizedStringKey {
        
        var explainerText = "Audio that plays before, while and after the text is spoken."
        if section.type == .headlines || section.type == .stories {
            explainerText += "The *separator* is inserted between headlines and stories."
        }
        
        return LocalizedStringKey(explainerText)
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
        
        let separatorAudioFileBinding = Binding {
             self.separatorAudioFile
         } set: { newValue in
             self.separatorAudioFile = newValue
             
             // update section in viewModel
             viewModel.updateEpisodeSection(sectionId: section.id, newSeparatorAudioFile: newValue)
         }
        
            
        Form {
            Section("Name") {
                TextField("Name", text: nameBinding)
            }
            
            // Text can be edited for all sections except the story section
            if section.type != .stories {
                Section("Text") {
                    TextField("Text", text: textBinding, axis: .vertical)
                }
            }
            
            Section("Listen") {
                PlayButtonRow(sectionId: section.id)
            }
            
            if section.type == .headlines {
                Section("Configuration") {
                    //Toggle("Use highlights only", isOn: $restrictHeadlinesToHighlights)
                    Toggle("Use highlights only", isOn: $viewModel.chosenEpisode.restrictHeadlinesToHighLights)
                }
            }
            
//            if section.type == .stories {
//                Section("Stories") {
//                    ForEach(stories) {story in
//                        NavigationLink(value: story) {
//                            Text(story.headline)
//                        }
//                    }
//                }
//            }
            
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
                
                if section.type == .headlines || section.type == .stories {
                    Picker("Separator", selection: separatorAudioFileBinding) {
                        ForEach(AudioManager.availableAudioFiles(), id: \.self) {audioFile in
                            Text(audioFile.displayName).tag(audioFile)
                        }
                    }.pickerStyle(.menu)
                }
                
            } header: {
                Text("Audio")
            } footer: {
                Text(pickerExplainerText)
            }
            
        }
        .navigationDestination(for: Story.self) { story in
            StoryEditView(story: story)
        }
        .navigationTitle("Section Editor")
    }
}

struct PlayButtonRow: View {
    
    enum PlayButtonState {
        case waitingForStart, rendering, waitingForStop
    }
    
    @State var playButtonState: PlayButtonState = .waitingForStart
    @EnvironmentObject var viewModel: EpisodeViewModel
    
    var sectionId: UUID
    
    func buttonPressed() {
        
        Task {
            
            if playButtonState == .waitingForStart {
                
                // render audio
                playButtonState = .rendering
                let audioURL = await viewModel.renderEpisodeSection(withId: sectionId)
                playButtonState = .waitingForStart
                
                // if successful, start playback
                if let audioURL {
                    playButtonState = .waitingForStop
                    await viewModel.playAudioAtURL(audioURL)
                    playButtonState = .waitingForStart
                }
            }
            
            if playButtonState == .waitingForStop {
                viewModel.stopAudioPlayback()
                playButtonState = .waitingForStart
            }
        }
    }
    
    
    var body: some View {
        
        HStack {

            // replace audio button with spinner while rendering audio
            if playButtonState == .rendering {
                ProgressView()
            } else {
        
                Button {
                    buttonPressed()
                } label: {
                    Image(systemName: playButtonState == .waitingForStart ? "play.circle" : "pause.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                }
            }
            
            Spacer()
            
            ProgressView(value: 10, total: 100)

        }.onDisappear {
            // if we are leaving the view, stop the audio
            viewModel.stopAudioPlayback()
        }
    }
}

struct SectionEditView_Previews: PreviewProvider {
    static var previews: some View {
        let section = EpisodeSection(type: .standard, name: "Introduction")
        SectionEditView(section: section)
    }
}
