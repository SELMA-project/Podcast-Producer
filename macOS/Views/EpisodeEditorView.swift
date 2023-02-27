//
//  EpisodeEditorView.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 08.08.22.
//

import SwiftUI


struct EpisodeEditorView: View {
    
    var chosenEpisodeId: UUID?
    
    @EnvironmentObject var episodeViewModel: EpisodeViewModel
    
    var body: some View {
        
        
        if let chosenEpisodeId  {
                        
            GeometryReader{geometry in
                HSplitView {
                    MainEditView(chosenEpisodeId: chosenEpisodeId)
                        .frame(minWidth:550, idealWidth: 550, maxWidth: .infinity, minHeight: geometry.size.height)
        
                    
                    Text("Right").frame(minWidth:200, idealWidth: 200, maxWidth: .infinity)
                }.frame(width: geometry.size.width, height: geometry.size.height)
            }
                        
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
    
    /// Showing PodcastRenderViewSheet?
    @State private var showingSheet = false
    
    /// The episode are we working on
    var chosenEpisode: Episode {
        return episodeViewModel[chosenEpisodeId]
    }
    
    /// Binding to currently chosen episode
    var chosenEpisodeBinding: Binding<Episode> {
        return $episodeViewModel[chosenEpisodeId]
    }
                
    /// All voices that share the same provider and language
    var availableVoices: [PodcastVoice] {
        let episodeLanguage = chosenEpisode.language
        let voiceProvider = chosenEpisode.podcastVoice.speechProvider
        let availableVoices = VoiceManager.shared.availableVoices(forLanguage: episodeLanguage, forProvider: voiceProvider)
        return availableVoices
    }
    
    /// All Voice providers
    var availableProviders: [SpeechProvider] {
        let episodeLanguage = chosenEpisode.language
        let availableProviders = VoiceManager.shared.availableProviders(forLanguage: episodeLanguage)
        return availableProviders
    }
    
    /// Removes story
    private func onDelete(offsets: IndexSet) {
        episodeViewModel[chosenEpisodeId].stories.remove(atOffsets: offsets)
    }
    
    /// Moves a story to change story order
    private func onMove(from source: IndexSet, to destination: Int) {
        episodeViewModel[chosenEpisodeId].stories.move(fromOffsets: source, toOffset: destination)
    }
    
    var body: some View {
        
        VStack {
            
            GroupBox {
                
                VStack(alignment: .leading) {
                    
                    Text("Podcast Settings").font(.title3)
  
                    Form {
                        
                        LabeledContent("Language:") {
                            Text(chosenEpisode.language.displayName)
                                .foregroundColor(.secondary)
                        }
                        
                        TextField("Narrator:", text: chosenEpisodeBinding.narrator, prompt: Text("Narrator"))
                        
                        Picker("Voice Provider:", selection: chosenEpisodeBinding.podcastVoice.speechProvider) {
                            ForEach(availableProviders, id: \.self) {provider in
                                Text(provider.displayName)
                            }
                        }
                        
                        Picker("Synthetic Voice Identifier:", selection: chosenEpisodeBinding.podcastVoice) {
                            ForEach(availableVoices, id: \.self) {voice in
                                Text(voice.name)
                            }
                        }
                        
                        Text("Add high-quality voices through the Mac's Preferences.\nFind more information [here](https://support.apple.com/de-de/guide/mac-help/mchlp2290/mac).")
                            .font(.caption)
                            .lineLimit(3,reservesSpace: true)
                        
                        
                        
                    }.padding()
                }.padding()
                
            }.padding()
            
            GroupBox {
                
                VStack(alignment: .leading) {
  
                    Text("Stories").font(.title3)
                    
                    List {
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
                    .listStyle(.inset(alternatesRowBackgrounds: true))
                    .navigationDestination(for: Story.StoryId.self) { storyId in
                        if let storyBinding = $episodeViewModel[chosenEpisodeId].stories.first(where: {$0.id == storyId}) {
                            //StoryEditView(story: storyBinding)
                            
                        }
                    }
                    
                }.padding()
                
            }.padding()
    
            
        }
        .sheet(isPresented: $showingSheet) {
            PodcastRenderView(chosenEpisodeId: chosenEpisodeId)
                .environmentObject(episodeViewModel)
        }
        .toolbar {
            
            ToolbarItem() {
                Button {
                    showingSheet = true
                } label: {
                    //Text("Produce Podcast")
                    Image(systemName: "record.circle")
                }
            }
            
        }


            
            

        
        
//
//            Section("Stories") {
//                ForEach(chosenEpisode.stories) {story in
//                    NavigationLink(value: story.id) {
//                        Label {
//                            Text(story.headline)
//                        } icon: {
//                            Image(systemName: story.usedInIntroduction ? "star.fill" : "star")
//                        }
//
//                    }
//                }
//                .onDelete(perform: onDelete)
//                .onMove(perform: onMove)
//            }
//
//            // Extra buttons to create and import stories
//            Section {
//                Button {
//
//                    // create empty story
//                    let storyId = episodeViewModel.appendEmptyStoryToChosenEpisode(chosenEpisodeId: chosenEpisodeId)
//
//                    // put storyId on the navigation stack - this way, StoryEditView is called
//                    episodeViewModel.navigationPath.append(storyId)
//                } label: {
//                    Text("Add Story")
//                }
//
//                Button {
//                    print("Add code to import episode here.")
//                } label: {
//                    Text("Import Story")
//                }
//            }
//
//            Section {
//                Button {
//                    showingSheet = true
//                } label: {
//                    Text("Produce Podcast")
//                }
//
//            }
//        }
//        .navigationDestination(for: Story.StoryId.self) { storyId in
//            if let storyBinding = $episodeViewModel[chosenEpisodeId].stories.first(where: {$0.id == storyId}) {
//                StoryEditView(story: storyBinding)
//            }
//        }
//
//        .pickerStyle(.menu)
//
//        .navigationTitle("Episode Editor")
//
//        .sheet(isPresented: $showingSheet) {
//            PodcastRenderView(chosenEpisodeId: chosenEpisodeId)
//                .environmentObject(episodeViewModel)
//        }
        
    }
}

struct MainEditView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let episodeViewModel = EpisodeViewModel(createPlaceholderEpisode: true)
        
        if let firstEpisodeId = episodeViewModel.firstEpisodeId {
            
            MainEditView(chosenEpisodeId: firstEpisodeId)
                .environmentObject(episodeViewModel)
                .frame(width:400, height: 600)
            
        } else {
            Text("No episode to display")
        }
        
    }
}
