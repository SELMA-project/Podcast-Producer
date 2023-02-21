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
    
    var chosenEpisodeId: UUID?
    
    @EnvironmentObject var episodeViewModel: EpisodeViewModel
    
    var body: some View {
        if let chosenEpisodeId  {
            
            MainEditView(chosenEpisodeId: chosenEpisodeId)

        } else {
            if episodeViewModel.availableEpisodes.count == 0 {
                Text("Please create an Episode.")
            } else {
                Text("Please choose an Episode.")
            }
        }
    }
}

struct MainEditView: View {
    
    var chosenEpisodeId: UUID
    
    @EnvironmentObject var episodeViewModel: EpisodeViewModel
    @State var providerName: String = "SELMA"
    
    // Showing PodcastRenderViewSheet?
    @State private var showingSheet = false
    
    var chosenEpisode: Episode {
        return episodeViewModel[chosenEpisodeId]
    }
    
    var chosenEpisodeBinding: Binding<Episode> {
        return $episodeViewModel[chosenEpisodeId]
    }
    
    var chosenEpisodeIndex: Int {
        return episodeViewModel.availableEpisodes.firstIndex(where: {$0.id == chosenEpisodeId})!
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
        let episodeLanguage = chosenEpisode.language
        let availableProviders = VoiceManager.shared.availableProviders(forLanguage: episodeLanguage)
        return availableProviders
    }
    
    private func onDelete(offsets: IndexSet) {
        episodeViewModel[chosenEpisodeId].stories.remove(atOffsets: offsets)
    }
    
    private func onMove(from source: IndexSet, to destination: Int) {
        episodeViewModel[chosenEpisodeId].stories.move(fromOffsets: source, toOffset: destination)
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

            Section {
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
            header: {
                Text("Voice")
            }
            footer: {
                //Text(voiceExplanationText)
                HStack {
                    Text("Add high-quality voices through").padding(.trailing, 0)
                    #if os(iOS)
                    Link("System Settings.", destination: URL(string: UIApplication.openSettingsURLString)! ).font(.footnote).padding(.leading, 0)
                    #else
                    Text("System Settings.").font(.footnote).padding(.leading, 0)
                    #endif
                    Text("More information can be found in this [Apple support article](https://support.apple.com/en-us/HT202362). Restart the app after adding a new voice.")
                    Spacer()
                }
            }

            Section("Stories") {
                ForEach(chosenEpisode.stories) {story in
                    NavigationLink(value: story.id) {
                        Label {
                            Text(story.headline)
                        } icon: {
                            Image(systemName: story.usedInIntroduction ? "star.fill" : "star")
                        }
                        
                    }
                }
                .onDelete(perform: onDelete)
                .onMove(perform: onMove)
            }

            // Extra buttons to create and import stories
            Section {
                Button {
                    
                    // create empty story
                    let storyId = episodeViewModel.appendEmptyStoryToChosenEpisode(chosenEpisodeId: chosenEpisodeId)
                    
                    // put storyId on the navigation stack - this way, StoryEditView is called
                    episodeViewModel.navigationPath.append(storyId)
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
        .navigationDestination(for: Story.StoryId.self) { storyId in
            if let storyBinding = $episodeViewModel[chosenEpisodeId].stories.first(where: {$0.id == storyId}) {
                StoryEditView(chosenEpisodeIndex: chosenEpisodeIndex, story: storyBinding)
            }
        }

        .pickerStyle(.menu)
    
        .navigationTitle("Episode Editor")
        
        .sheet(isPresented: $showingSheet) {
            PodcastRenderView(chosenEpisodeId: chosenEpisodeId)
                .environmentObject(episodeViewModel)
        }
        
    }
}

struct MainEditView_Previews: PreviewProvider {
    
    static var previews: some View {
        let episodeViewModel = EpisodeViewModel()
        if episodeViewModel.availableEpisodes.count > 0 {
            let firstEpisodeId = episodeViewModel.availableEpisodes[0].id
            MainEditView(chosenEpisodeId: firstEpisodeId)
        } else {
            Text("No episode to display")
        }
        
    }
}
