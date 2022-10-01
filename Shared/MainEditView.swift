//
//  MainEditView.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 08.08.22.
//

import SwiftUI

struct MainEditView: View {
        
    @ObservedObject var episodeViewModel: EpisodeViewModel
    @State private var path: [Int] = [] //NavigationPath() //: [Int] = []
    @State private var chosenSpeaker = SelmaVoice(.leila)
        
    var body: some View {
        
        NavigationStack(path: $path) {
 
            Form {
    
                Section("Speaker") {
                    Picker("Name", selection: $episodeViewModel.speaker) {
                        ForEach(SelmaVoice.allVoices, id: \.self) {speaker in
                            Text(speaker.shortName)
                        }
                    }
                }
                
                Section("Structure") {
                    ForEach(0..<episodeViewModel.availableEpisodes[episodeViewModel.chosenEpisodeIndex].sections.count, id: \.self) {sectionNumber in
                        NavigationLink(value: sectionNumber) {
                            Text(episodeViewModel.availableEpisodes[episodeViewModel.chosenEpisodeIndex].sections[sectionNumber].name)
                        }
                    }
                }
        
                
                

//
//                Section("Introduction") {
//                    TextField("Introduction", text:  $episodeViewModel.availableEpisodes[episodeViewModel.chosenEpisodeIndex].introductionText, axis: .vertical)
//                }
//
//                Section("Stories") {
//                    ForEach(0..<episodeViewModel.availableEpisodes[episodeViewModel.chosenEpisodeIndex].stories.count, id:\.self) {storyNumber in
//                        NavigationLink(value: storyNumber) {
//                            Text(episodeViewModel.availableEpisodes[episodeViewModel.chosenEpisodeIndex].stories[storyNumber].headline)
//                        }
//                    }
//                }
//
//                Section("Epilog") {
//                    TextField("Epilogue", text:  $episodeViewModel.availableEpisodes[episodeViewModel.chosenEpisodeIndex].epilog, axis: .vertical)
//                }

            }
//            .navigationDestination(for: Int.self) { storyNumber in
//                StoryEditView(episodeViewModel: episodeViewModel, storyNumber: storyNumber)
//            }
            .navigationDestination(for: Int.self) { sectionNumber in
                SectionEditView(episodeViewModel: episodeViewModel, sectionNumber: sectionNumber)
            }
        }
        .navigationTitle("Episode Editor")
        .padding()
        
    }
    
}


struct MainEditViewOld: View {
        
    @ObservedObject var episodeViewModel: EpisodeViewModel
    @State private var path = NavigationPath() //: [Int] = []
    @State private var chosenSpeaker = SelmaVoice(.leila)
        
    var body: some View {
        
        NavigationStack(path: $path) {
            
            Form {
                
                Section("Speaker") {
                    Picker("Name", selection: $episodeViewModel.speaker) {
                        ForEach(SelmaVoice.allVoices, id: \.self) {speaker in
                            Text(speaker.shortName)
                        }
                    }
                }
                                
                Section("Introduction") {
                    TextField("Introduction", text:  $episodeViewModel.availableEpisodes[episodeViewModel.chosenEpisodeIndex].introductionText, axis: .vertical)
                }
                
                Section("Stories") {
                    ForEach(0..<episodeViewModel.availableEpisodes[episodeViewModel.chosenEpisodeIndex].stories.count, id:\.self) {storyNumber in
                        NavigationLink(value: storyNumber) {
                            Text(episodeViewModel.availableEpisodes[episodeViewModel.chosenEpisodeIndex].stories[storyNumber].headline)
                        }
                    }
                }
                
                Section("Epilog") {
                    TextField("Epilogue", text:  $episodeViewModel.availableEpisodes[episodeViewModel.chosenEpisodeIndex].epilog, axis: .vertical)
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
