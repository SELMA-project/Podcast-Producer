//
//  MainEditView.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 08.08.22.
//

import SwiftUI

struct MainEditView: View {
        
    @ObservedObject var episodeViewModel: EpisodeViewModel
    @State private var path = NavigationPath() //: [Int] = []
    @State private var chosenSpeaker = SelmaVoice(.leila)
    
    var speakers = [SelmaVoice(.leila), SelmaVoice(.roberto)]
    @State private var chosenName = "Leila"
    
    var body: some View {
        
        NavigationStack(path: $path) {
            
            Form {
                
                Section("Speaker") {
                    Picker("Voice", selection: $episodeViewModel.speaker) {
                        ForEach(SelmaVoice.allVoices, id: \.self) {speaker in
                            Text(speaker.displayName)
                        }
                    }
                }
                
                Section("Episode title") {
                    TextField("Teaser", text: $episodeViewModel.availableEpisodes[episodeViewModel.chosenEpisodeIndex].cmsTitle, axis:. vertical)
                        .lineLimit(3, reservesSpace: false)
                }
                
                Section("Episode teaser") {
                    TextField("Teaser", text:  $episodeViewModel.availableEpisodes[episodeViewModel.chosenEpisodeIndex].cmsTeaser, axis:. vertical)
                        .lineLimit(3, reservesSpace: false)
                }
                
                Section("Welcome text") {
                    TextField("Welcome text", text:  $episodeViewModel.availableEpisodes[episodeViewModel.chosenEpisodeIndex].welcomeText, axis: .vertical)
                }
                
                Section("Headline introduction") {
                    TextField("Headline introduction", text:  $episodeViewModel.availableEpisodes[episodeViewModel.chosenEpisodeIndex].headlineIntroduction, axis: .vertical)
                }
                
                Section("Stories") {
                    ForEach(0..<episodeViewModel.availableEpisodes[episodeViewModel.chosenEpisodeIndex].stories.count, id:\.self) {storyNumber in
                        NavigationLink(value: storyNumber) {
                            Text(episodeViewModel.availableEpisodes[episodeViewModel.chosenEpisodeIndex].stories[storyNumber].headline)
                        }
                    }
                }

            }
            .navigationDestination(for: Int.self) { storyNumber in
                StoryEditView(episodeViewModel: episodeViewModel, storyNumber: storyNumber)
            }
        }
        .navigationTitle("Episode Editor")
        .padding()
        
    }
    
}

struct MainEditView_Previews: PreviewProvider {
    
    static var previews: some View {
        MainEditView(episodeViewModel: EpisodeViewModel())
    }
}
