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
    
    var body: some View {

        Form {
            
            Section("Episode title") {
                TextField("Teaser", text: $episodeViewModel.chosenEpisode.cmsTitle, axis:. vertical)
                    .lineLimit(3, reservesSpace: true)
            }
            
            Section("Episode teaser") {
                TextField("Teaser", text: $episodeViewModel.chosenEpisode.cmsTeaser, axis:. vertical)
                    .lineLimit(3, reservesSpace: true)
            }
            
            Section("Welcome text") {
                TextField("Welcome text", text: $episodeViewModel.chosenEpisode.welcomeText, axis: .vertical)
            }
            
            Section("Headline introduction") {
                TextField("Headline introduction", text: $episodeViewModel.chosenEpisode.headlineIntroduction, axis: .vertical)
            }
            
            
            Section("Select story") {
//                Picker("Select story", selection: $selectedStoryNumber) {
//                    ForEach([1, 2, 3, 4, 5], id: \.self) {
//                        Text("\($0)")
//                    }
//                }
                Stepper(value: $selectedStoryNumber, in: 0...4) {
                     Text("Story number: \(selectedStoryNumber)")
                 }
            }
            
            StoryEditView(storyNumber: selectedStoryNumber)
 
                    
        }.padding()
    }
}

struct MainEditView_Previews: PreviewProvider {
    static var previews: some View {
        MainEditView()
    }
}
