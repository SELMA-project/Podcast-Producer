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
    
    var chosenEpisodeIndex: Int?
    
    @EnvironmentObject var episodeViewModel: EpisodeViewModel
    
    var body: some View {
        if chosenEpisodeIndex == nil {
            
            if episodeViewModel.availableEpisodes.count == 0 {
                Text("Please create an Episode.")
            } else {
                Text("Please choose an Episode.")
            }
        } else {
            MainEditView(chosenEpisodeIndex: chosenEpisodeIndex)
        }
    }
}

struct MainEditView: View {
    
    var chosenEpisodeIndex: Int?
    
    @EnvironmentObject var episodeViewModel: EpisodeViewModel
    @State var providerName: String = "SELMA"
    
    // Showing PodcastRenderViewSheet?
    @State private var showingSheet = false
    
    var chosenEpisode: Episode {
        return episodeViewModel[chosenEpisodeIndex]
    }
    
    var chosenEpisodeBinding: Binding<Episode> {
        return $episodeViewModel[chosenEpisodeIndex]
    }
    
    
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
    
    private func onDelete(offsets: IndexSet) {
        episodeViewModel[chosenEpisodeIndex].stories.remove(atOffsets: offsets)
    }
    
    private func onMove(from source: IndexSet, to destination: Int) {
        episodeViewModel[chosenEpisodeIndex].stories.move(fromOffsets: source, toOffset: destination)
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
                ForEach(chosenEpisodeBinding.stories) {$story in
                    NavigationLink(value: story) {
                        Text(story.headline)
                    }
                }
                .onDelete(perform: onDelete)
                .onMove(perform: onMove)
            }

            // Extra buttons to create and import stories
            Section {
                Button {
                    
                    // create empty story
                    let story = episodeViewModel.appendEmptyStoryToChosenEpisode(chosenEpisodeIndex: chosenEpisodeIndex)
                    
                    // put story on the navigation stack - this way, StoryEditView is called
                    episodeViewModel.navigationPath.append(story)
                } label: {
                    Text("Add Story")
                }
                
                Button {
                    print("Add code to import episode here.")
                } label: {
                    Text("Import Story")
                }
            }
            
            Section {
                Button {
                    showingSheet = true
                } label: {
                    Text("Produce Podcast")
                }

            }

   
            
        }
        .navigationDestination(for: EpisodeSection.self) { section in
            SectionEditView(chosenEpisodeIndex: chosenEpisodeIndex, section: section)
        }
        .navigationDestination(for: Story.self) { story in
            StoryEditView(chosenEpisodeIndex: chosenEpisodeIndex, story: story)
        }

        .pickerStyle(.menu)
    
        .navigationTitle("Episode Editor")
        
        .sheet(isPresented: $showingSheet) {
            PodcastRenderView(chosenEpisodeIndex: chosenEpisodeIndex)
                .environmentObject(episodeViewModel)
        }
        
    }
}

struct MainEditView_Previews: PreviewProvider {
    
    static var previews: some View {
        MainEditView(chosenEpisodeIndex: 0)
    }
}