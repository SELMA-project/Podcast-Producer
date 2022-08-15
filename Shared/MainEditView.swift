//
//  MainEditView.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 08.08.22.
//

import SwiftUI

struct MainEditView: View {
    
    @Binding var chosenEpisode: Episode?
    
    @EnvironmentObject var episodeViewModel: EpisodeViewModel
    @State var selectedStoryNumber: Int = 0
    @State private var path: [String] = []
    
    var body: some View {
        
        NavigationStack(path: $path) {
            
            if let myChosenEpisode = Binding($chosenEpisode) {
                
                Form {
                    Section("Episode title") {
                        TextField("Teaser", text: myChosenEpisode.cmsTitle, axis:. vertical)
                            .lineLimit(3, reservesSpace: false)
                    }
                    
                    Section("Episode teaser") {
                        TextField("Teaser", text: myChosenEpisode.cmsTeaser, axis:. vertical)
                            .lineLimit(3, reservesSpace: false)
                    }
                    
                    Section("Welcome text") {
                        TextField("Welcome text", text: myChosenEpisode.welcomeText, axis: .vertical)
                    }
                    
                    Section("Headline introduction") {
                        TextField("Headline introduction", text: myChosenEpisode.headlineIntroduction, axis: .vertical)
                    }
                    
                    Section("Stories") {
                        ForEach(myChosenEpisode.wrappedValue.stories, id: \.headline) {story in
                            NavigationLink(value: story.headline) {
                                Text(story.headline)
                            }
                        }
                    }
                    
                }
                .navigationDestination(for: String.self) { i in
                    Text("Detail \(i)")
                }
                
            } else {
                Text("Please choose episode")
            }
            
            
        }
        .padding()
    }
    
}

struct MainEditView_Previews: PreviewProvider {
    static var previews: some View {
        MainEditView(chosenEpisode: .constant(Episode.episode0))
    }
}
