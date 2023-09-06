//
//  SectionEditView.swift
//  Podcast Producer
//
//  Created by Andy on 01.10.22.
//

import SwiftUI

struct SectionEditView: View {
    
    var chosenEpisodeId: UUID?
    @Binding var section: EpisodeSection
    
    @EnvironmentObject var viewModel: EpisodeViewModel
    
    var chosenEpisode: Episode {
        return viewModel[chosenEpisodeId]
    }
    
    var chosenEpisodeBinding: Binding<Episode> {
        return $viewModel[chosenEpisodeId]
    }
    
    var stories: [Story] {
        return chosenEpisode.stories
    }
    
    /// The text displayed under the audio section
    var pickerExplainerText: LocalizedStringKey {
        
        var explainerText = ""
        
        if section.type == .headlines {
            explainerText += "Audio that plays before, during and after the text is spoken. "
            explainerText += "The *separator* is inserted between the individual headlines."
        }
        
        if section.type ==  .stories {
            explainerText += "Audio that plays during the spoken text. "
            explainerText += "The *separator* is inserted between the individual stories."
        }
        
        if section.type == .standard {
            explainerText += "Audio that plays before, during and after the text is spoken."
        }
        
        return LocalizedStringKey(explainerText)
    }
    
    var body: some View {
            
        Form {
            //Section("Name") {
                TextField("Name", text: $section.name)
            //}
            
            // Text can be edited for all sections except the story section
            if section.type != .stories {
                //Section("Text") {
                    TextField("Text", text: $section.rawText, axis: .vertical)
                //}
            }
            
            //Section("Listen") {
                //PlayButtonRow(chosenEpisodeId: chosenEpisodeId, sectionId: section.id)
            //}
            
            if section.type == .headlines {

                Section {
                    Toggle("Use highlights only", isOn: chosenEpisodeBinding.restrictHeadlinesToHighLights)
                } header: {
                    Text("Configuration")
                } footer: {
                    Text("Activate this toggle to restrict the introduction to include *only* headlines of highlighted stories.")
                }
            }
            
            Section {
                
                if section.type != .stories {
                    Picker("Before speech", selection: $section.prefixAudioFile) {
                        ForEach(AudioManager.availableAudioFiles(), id: \.self) {audioFile in
                            Text(audioFile.displayName).tag(audioFile)
                        }
                    }.pickerStyle(.menu)
                }
                
                Picker("During speech", selection: $section.mainAudioFile) {
                    ForEach(AudioManager.availableAudioFiles(), id: \.self) {audioFile in
                        Text(audioFile.displayName).tag(audioFile)
                    }
                }.pickerStyle(.menu)

                if section.type != .stories {
                    Picker("After speech", selection: $section.suffixAudioFile) {
                        ForEach(AudioManager.availableAudioFiles(), id: \.self) {audioFile in
                            Text(audioFile.displayName).tag(audioFile)
                        }
                    }.pickerStyle(.menu)
                }
                
            
                if section.type == .headlines || section.type == .stories {
                    Picker("Separator", selection: $section.separatorAudioFile) {
                        ForEach(AudioManager.availableAudioFiles(), id: \.self) {audioFile in
                            Text(audioFile.displayName).tag(audioFile)
                        }
                    }.pickerStyle(.menu)
                }
                
            }  footer: {
                Text(pickerExplainerText).font(.caption)
            }
            
            PlayButtonRow(chosenEpisodeId: chosenEpisodeId, sectionId: section.id)
            
        }
        //.navigationTitle("Section Editor")
    }
}

struct PlayButtonRow: View {
    
    var chosenEpisodeId: UUID?
    
//    enum PlayButtonState {
//        case waitingForStart, rendering, waitingForStop
//    }
//
//    @State var playButtonState: PlayButtonState = .waitingForStart
    @EnvironmentObject var viewModel: EpisodeViewModel
    @EnvironmentObject var voiceViewModel: VoiceViewModel
    
    var sectionId: EpisodeSection.SectionId

    
    func buttonPressed() {
        
        Task {
            
            if voiceViewModel.playerStatus == .idle {
                
                // render audio
                voiceViewModel.playerStatus = .rendering
                
                let chosenEpisode = viewModel[chosenEpisodeId]
                let episodeSectionIndex = viewModel.indexOfEpisodeSection(chosenEpisodeId: chosenEpisodeId, relevantId: sectionId)
                let audioURL = await voiceViewModel.renderEpisodeSection(chosenEpisode: chosenEpisode, episodeSectionIndex: episodeSectionIndex)
                
                //let audioURL = await viewModel.renderEpisodeSection(chosenEpisodeId: chosenEpisodeId, sectionId: sectionId)
                
                // if successful, start playback
                if let audioURL {
                    voiceViewModel.playerStatus = .playing
                    await voiceViewModel.playAudioAtURL(audioURL)
                    voiceViewModel.playerStatus = .idle
                } else {
                    voiceViewModel.playerStatus = .idle
                }
            }
            
            if voiceViewModel.playerStatus == .playing {
                voiceViewModel.stopAudioPlayback()
                voiceViewModel.playerStatus = .idle
            }
        }
    }
        
    
    var body: some View {
        
        HStack {

            // replace audio button with spinner while rendering audio
            if voiceViewModel.playerStatus == .rendering {
                ProgressView()
            } else {
        
                Button {
                    buttonPressed()
                } label: {
                    Image(systemName: voiceViewModel.playerStatus != .playing ? "play.circle" : "pause.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                }.buttonStyle(.plain)
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
        let episodeViewModel = EpisodeViewModel()
        
        if let firstEpisodeId = episodeViewModel.firstEpisodeId {
            SectionEditView(chosenEpisodeId: firstEpisodeId, section: .constant(section))
        } else {
            Text("No episode to display")
        }
    }
}

