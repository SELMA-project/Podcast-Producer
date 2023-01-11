//
//  PodcastRenderView.swift
//  Podcast Creator
//
//  Created by Andy Giefer on 10.01.23.
//

import SwiftUI

struct PodcastRenderView: View {
    
    @Environment(\.dismiss) var dismissAction
    @EnvironmentObject var episodeViewModel: EpisodeViewModel
    
    @State private var progressText = "Press button to render."
    @State private var progressValue = 0.0

    @State private var audioURL: URL? = nil
    
    var renderProgressIsVisible: Bool {
        return progressValue > 0 && progressValue  < 100
    }
    
    var body: some View {
        
        NavigationStack {
            VStack(alignment: .leading) {
             
                
                Text("Render the podcast to convert the text in each section into synthesized speech while adding additional audio elements.")
 
                    
                    Button {
                        Task {
                            
                            progressValue = 50
                            progressText = "Synthesizing speech..."
                            audioURL = await episodeViewModel.renderEpisode()
                            
                            progressValue = 100
                            progressText = "Ready for sharing."
                        }
                    } label: {
                        Text("Render")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding([.top, .bottom])

                    ProgressView(progressText, value: progressValue, total: 100)
                    .opacity(renderProgressIsVisible ? 1 : 0)
                    
            
                
                // display audio player if we have an audio URL
                AudioPlayerView(audioURL: audioURL)
                    .padding([.top, .bottom])
                
                
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismissAction()
                    }
                }
                
                ToolbarItem {
                    if let audioURL {
                        ShareLink(item: audioURL) {
                            //Text("Share")
                            Image(systemName: "square.and.arrow.up")
                        }//.disabled(episodeViewModel.episodeAvailable == false)
                        
                    }
                }
            }

            .navigationTitle("Create Podcast")
        }
    }
}

struct PodcastRenderView_Previews: PreviewProvider {
    static var previews: some View {
        PodcastRenderView()
    }
}
