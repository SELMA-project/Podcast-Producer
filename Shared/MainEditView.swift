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
    
    @ObservedObject var episodeViewModel: EpisodeViewModel
    @State private var path = NavigationPath() //: [Int] = []
    //@State private var chosenSpeaker = SelmaVoice(.leila)
    
    //@State var languageName: String = "Brazilian"
    //@State var narratorName: String = "Leila Endruweit"
    @State var providerName: String = "SELMA"
    
    var episodeSections: [EpisodeSection] {
        return episodeViewModel.availableEpisodes[episodeViewModel.chosenEpisodeIndex].sections
    }
    
    var episodeStories: [Story] {
        return episodeViewModel.availableEpisodes[episodeViewModel.chosenEpisodeIndex].stories
    }
    
    var episodeLanguage: String {
        return episodeViewModel.availableEpisodes[episodeViewModel.chosenEpisodeIndex].language.displayName
    }
    
    /// All voices that share the same provider and language
    var relatedVoices: [PodcastVoice] {
        let currentVoice = episodeViewModel.chosenEpisode.podcastVoice
        let relatedVoices = currentVoice.relatedVoices()
        return relatedVoices
    }

    var body: some View {
                
        NavigationStack(path: $path) {
            
            Form {
                
                Section("General") {
                    
                    Picker("Language", selection: $episodeViewModel.chosenEpisode.language) {
                        ForEach(LanguageManager.Language.allCases, id: \.self) {language in
                            Text(language.displayName)
                        }
                    }.pickerStyle(.menu)
                    
                    HStack {
                        Text("Narrator")
                        Spacer()
                        TextField("Name", text: $episodeViewModel.chosenEpisode.narrator)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Voice") {
                    HStack {
                        Text("Provider")
                        Spacer()
                        TextField("Name", text: $providerName)
                            .multilineTextAlignment(.trailing)
                    }
                    Picker("Identifier", selection: $episodeViewModel.chosenEpisode.podcastVoice) {
                        ForEach(relatedVoices, id: \.self) {voice in
                            Text(voice.name)
                        }
                    }.pickerStyle(.menu)
                }
                
                
                Section("Structure") {
                    ForEach(episodeSections) {section in
                        NavigationLink(value: section) {
                            Text(section.name)
                        }
                    }
                }
                
            }
            
            .navigationDestination(for: EpisodeSection.self) { section in
                SectionEditView(section: section)
            }
            .navigationTitle("Episode Editor")
            
        }
        
        .padding()
        // somehow this avoid that in the simulator the path is incorrectly set
        .onChange(of: path) { path in
            //print(path)
        }

    }
}

struct MainEditView_Previews: PreviewProvider {
    
    static var previews: some View {
        MainEditView(episodeViewModel: EpisodeViewModel())
    }
}
