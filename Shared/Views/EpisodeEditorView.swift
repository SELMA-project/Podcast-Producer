//
//  EpisodeEditorView.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 08.08.22.
//

import SwiftUI

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ conditional: Bool,  @ViewBuilder content: (Self) -> Content) -> some View {
        if conditional {
            content(self)
        }
        else {
            self
        }
    }
}


struct EpisodeEditorView: View {
    
    @Binding var chosenEpisodeIndex: Int?
    
    @EnvironmentObject var episodeViewModel: EpisodeViewModel
    
    var body: some View {
        if chosenEpisodeIndex == nil {
            
            if episodeViewModel.availableEpisodes.count == 0 {
                Text("Please create an Episode.")
            } else {
                Text("Please choose an Episode.")
            }
        } else {
            MainEditView(chosenEpisodeIndex: $chosenEpisodeIndex)
        }
    }
}

struct MainEditView: View {
    
    @Binding var chosenEpisodeIndex: Int?
    
    @EnvironmentObject var episodeViewModel: EpisodeViewModel
    @State var providerName: String = "SELMA"
    
    var chosenEpisode: Episode {
        return episodeViewModel[chosenEpisodeIndex]
    }
    
    var chosenEpisodeBinding: Binding<Episode> {
        return $episodeViewModel[chosenEpisodeIndex]
    }
    
//    var episodeSections: [EpisodeSection] {
//        let sections = chosenEpisode.sections
//        return sections
//    }

    
    var episodeStories: [Story] {
        return chosenEpisode.stories
    }
    
    var episodeLanguage: String {
        return chosenEpisode.language.displayName
    }
    
    /// All voices that share the same provider and language
    var availableVoices: [PodcastVoice] {
        let chosenEpisode = chosenEpisode
        let episodeLanguage = chosenEpisode.language
        let voiceProvider = chosenEpisode.podcastVoice.speechProvider
        let availableVoices = VoiceManager.shared.availableVoices(forLanguage: episodeLanguage, forProvider: voiceProvider)
        return availableVoices
    }
    
    var availableProviders: [SpeechProvider] {
        let chosenEpisode = chosenEpisode
        let episodeLanguage = chosenEpisode.language
        let availableProviders = VoiceManager.shared.availableProviders(forLanguage: episodeLanguage)
        return availableProviders
    }
    
    var body: some View {
        
        Form {
            
            Section {
                HStack {
                    Text("Language")
                    Spacer()
                    Text(chosenEpisode.language.displayName)
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("Language")
            } footer: {
                Text("The episode language cannot be changed.")
            }
            
            
            Section {

                HStack {
                    Text("Narrator")
                    Spacer()
                    TextField("Name", text: chosenEpisodeBinding.narrator)
                        .multilineTextAlignment(.trailing)
                }
            } header: {
                Text("General")
            }
            footer: {
                Text("This replaces the {narrator} token.")
            }

            Section("Voice") {
                Picker("Voice Provider", selection: chosenEpisodeBinding.podcastVoice.speechProvider) {
                    ForEach(availableProviders, id: \.self) {provider in
                        Text(provider.displayName)
                    }
                }

                Picker("Synthetic Voice Identifier", selection: chosenEpisodeBinding.podcastVoice) {
                    ForEach(availableVoices, id: \.self) {voice in
                        Text(voice.name)
                    }
                }
            }

            Section("Stories") {
                Text("Story list goes here")
//                NavigationLink(value: "Stories") {
//                    Text("Tap to edit stories")
//                        .foregroundColor(.blue)
//                        .badge(chosenEpisode.stories.count)
//
//                }

            }

//            Section("Structure") {
//                if episodeSections.count == 0 {
//                    Text("No defined structure")
//                } else {
//                    ForEach(episodeSections) {section in
//                        NavigationLink(value: section) {
//                            Text(section.name)
//                        }
//                    }
//                }
//            }
   
            
        }
        .navigationDestination(for: EpisodeSection.self) { section in
            SectionEditView(chosenEpisodeIndex: $chosenEpisodeIndex, section: section)
        }
//        .navigationDestination(for: String.self) { destinationName in
//            if destinationName == "Stories" {
//                StoryListView(chosenEpisodeIndex: $chosenEpisodeIndex)
//            }
//        }
        .pickerStyle(.menu)
    
        .navigationTitle("Episode Editor")
        
    }
}

struct MainEditView_Previews: PreviewProvider {
    
    static var previews: some View {
        MainEditView(chosenEpisodeIndex: .constant(0))
    }
}
