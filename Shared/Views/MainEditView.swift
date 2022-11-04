//
//  MainEditView.swift
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

struct MainEditView: View {
    
    @EnvironmentObject var episodeViewModel: EpisodeViewModel
    @State private var path = NavigationPath() //: [Int] = []
    @State var providerName: String = "SELMA"
    
    var episodeSections: [EpisodeSection] {
        return episodeViewModel.chosenEpisode.sections
    }
    
    var episodeStories: [Story] {
        return episodeViewModel.chosenEpisode.stories
    }
    
    var episodeLanguage: String {
        return episodeViewModel.chosenEpisode.language.displayName
    }
    
    /// All voices that share the same provider and language
    var availableVoices: [PodcastVoice] {
        let chosenEpisode = episodeViewModel.chosenEpisode
        let episodeLanguage = chosenEpisode.language
        let voiceProvider = chosenEpisode.podcastVoice.speechProvider
        let availableVoices = VoiceManager.shared.availableVoices(forLanguage: episodeLanguage, forProvider: voiceProvider)
        return availableVoices
    }
    
    var availableProviders: [SpeechProvider] {
        let chosenEpisode = episodeViewModel.chosenEpisode
        let episodeLanguage = chosenEpisode.language
        let availableProviders = VoiceManager.shared.availableProviders(forLanguage: episodeLanguage)
        return availableProviders
    }

    var body: some View {
                
        NavigationStack(path: $path) {
            
            Form {
                
                Section {
                    HStack {
                        Text("Language")
                        Spacer()
                        Text(episodeViewModel.chosenEpisode.language.displayName)
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
                        TextField("Name", text: $episodeViewModel.chosenEpisode.narrator)
                            .multilineTextAlignment(.trailing)
                    }
                } header: {
                    Text("General")
                }
                footer: {
                    Text("This replaces the {narrator} token.")
                }
                
                Section("Voice") {
                    Picker("Provider", selection: $episodeViewModel.chosenEpisode.podcastVoice.speechProvider) {
                        ForEach(availableProviders, id: \.self) {provider in
                            Text(provider.displayName)
                        }
                    }
                    
                    Picker("Identifier", selection: $episodeViewModel.chosenEpisode.podcastVoice) {
                        ForEach(availableVoices, id: \.self) {voice in
                            Text(voice.name)
                        }
                    }
                }
                
                
                Section("Structure") {
                    ForEach(episodeSections) {section in
                        NavigationLink(value: section) {
                            Text(section.name)
                        }
                    }
                }
                
            }
            .pickerStyle(.menu)
            
            .navigationDestination(for: EpisodeSection.self) { section in
                SectionEditView(section: section)
            }
            .navigationTitle("Episode Editor")
            
        }
        

    }
}

struct MainEditView_Previews: PreviewProvider {
    
    static var previews: some View {
        MainEditView()
    }
}
