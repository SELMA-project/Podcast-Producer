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
    
    @State private var progressText = ""
    @State private var progressValue = 0.0

    @State private var audioURL: URL? = nil
    
    var body: some View {
        

        NavigationStack {
            VStack(alignment: .leading) {
             
                Text("Press the *Render* button to start rendering the podcast.")
                    .padding(.bottom, 4)
                
                Text("This will convert the text in each section into synthesized speech while adding additional audio elements.")
                    .font(.caption)

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
            
                if progressValue > 0 {
                    ProgressView(progressText, value: progressValue, total: 100)
                }
                
                
                
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
