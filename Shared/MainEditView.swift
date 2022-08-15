//
//  MainEditView.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 08.08.22.
//

import SwiftUI

struct MainEditView: View {
    
    @EnvironmentObject var episodeViewModel: EpisodeViewModel
    @State var selectedStoryNumber: Int = 0
    
    func incrementStoryNumber() {
        selectedStoryNumber = min(selectedStoryNumber+1, 5)
    }
    
    func decrementStoryNumber() {
        selectedStoryNumber = max(selectedStoryNumber-1, 1)
    }
    
    @State private var path: [String] = []
    
    var body: some View {
        
        NavigationStack(path: $path) {
            
            Form {
                Section("Episode title") {
                    TextField("Teaser", text: $episodeViewModel.chosenEpisode.cmsTitle, axis:. vertical)
                        .lineLimit(3, reservesSpace: false)
                }
                
                Section("Episode teaser") {
                    TextField("Teaser", text: $episodeViewModel.chosenEpisode.cmsTeaser, axis:. vertical)
                        .lineLimit(3, reservesSpace: false)
                }
                
                Section("Welcome text") {
                    TextField("Welcome text", text: $episodeViewModel.chosenEpisode.welcomeText, axis: .vertical)
                }
                
                Section("Headline introduction") {
                    TextField("Headline introduction", text: $episodeViewModel.chosenEpisode.headlineIntroduction, axis: .vertical)
                }
                
                Section("Stories") {
                    ForEach(episodeViewModel.chosenEpisode.stories, id: \.headline) {story in
                        NavigationLink(value: story.headline) {
                            Text(story.headline)
                        }
                    }
                }

            }
            .navigationDestination(for: String.self) { i in
                Text("Detail \(i)")
            }
        }
        .padding()
    }
    
}

struct MainEditView_Previews: PreviewProvider {
    static var previews: some View {
        MainEditView()
    }
}
