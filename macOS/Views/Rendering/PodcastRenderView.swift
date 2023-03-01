//
//  PodcastRenderView.swift
//  Podcast Creator
//
//  Created by Andy Giefer on 10.01.23.
//

import SwiftUI

struct PodcastRenderView: View {
    
    var chosenEpisodeId: UUID?
    
    @Environment(\.dismiss) var dismissAction
    @EnvironmentObject var episodeViewModel: EpisodeViewModel
    
    @State private var progressText = "Press button to render."
    @State private var progressValue = 0.0

    @State private var audioURL: URL? = nil
    
    var renderProgressIsVisible: Bool {
        return progressValue > 0 && progressValue  < 100
    }
    
    var body: some View {
       
        VStack(alignment: .leading) {
            
            HStack {
                Text("Render Podcast").font(.title2)
                
            }
            
            Text("Render the podcast to convert the text in each section into synthesized speech while adding additional audio elements.")
                .font(.caption)
            
            Divider()//.padding([.top, .bottom])
            
            HStack {
                                
                Button {
                    Task {
                        
                        progressValue = 50
                        progressText = "Synthesizing speech..."
                        audioURL = await episodeViewModel.renderEpisode(chosenEpisodeId: chosenEpisodeId)
                        
                        progressValue = 100
                        progressText = "Ready for sharing."
                    }
                } label: {
                    Text("Build")
                        .frame(maxWidth: .infinity)
                }
                .disabled(audioURL != nil)
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: 100)
                
                ProgressView(progressText, value: progressValue, total: 100)
                    .opacity(renderProgressIsVisible ? 1 : 0)
 

            }
            



            // display audio player if we have an audio URL
            AudioPlayerView(audioURL: audioURL)
                .padding([.top, .bottom])

            
            HStack {
                Spacer()
  
                Button {
                    dismissAction()
                } label: {
                    Text("Cancel")
                }
                
                Button {
                    print("Clicked save.")
                } label: {
                    Text("Save Audio")
                }
            }
        }
    }
}

struct PodcastRenderView_Previews: PreviewProvider {
    static var previews: some View {
        let episodeViewModel = EpisodeViewModel()
        if episodeViewModel.availableEpisodes.count > 0 {
            let firstEpisodeId = episodeViewModel.availableEpisodes[0].id
            PodcastRenderView(chosenEpisodeId: firstEpisodeId)
                .padding()
                .frame(width:450)
        } else {
            Text("No episode to display")
        }
    }
}
