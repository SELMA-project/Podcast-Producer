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
        let availableVoices = PodcastVoice.availableVoices(forLanguage: episodeLanguage, forProvider: voiceProvider)
        return availableVoices
    }
    
    var availableProviders: [PodcastVoice.SpeechProvider] {
        let chosenEpisode = episodeViewModel.chosenEpisode
        let episodeLanguage = chosenEpisode.language
        let availableProviders = PodcastVoice.availableProviders(forLanguage: episodeLanguage)
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
                    }
                } header: {
                    Text("Language")
                } footer: {
                    Text("The language of an episode cannot be changed.")
                }

                
                Section("General") {
  
//                    HStack {
//                        Text("Language")
//                        Spacer()
//                        Text(episodeViewModel.chosenEpisode.language.displayName)
//                    }
                    
//                    Picker("Language", selection: $episodeViewModel.chosenEpisode.language) {
//                        ForEach(LanguageManager.Language.allCases, id: \.self) {language in
//                            Text(language.displayName)
//                        }
//                    }
                    
                    HStack {
                        Text("Narrator")
                        Spacer()
                        TextField("Name", text: $episodeViewModel.chosenEpisode.narrator)
                            .multilineTextAlignment(.trailing)
                    }
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
        
        .padding()
    }
}

struct MainEditView_Previews: PreviewProvider {
    
    static var previews: some View {
        MainEditView()
    }
}
