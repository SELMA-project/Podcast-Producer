//
//  AudioRenderView.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 15.08.22.
//

import SwiftUI

struct AudioRenderView: View {
    
    @ObservedObject var episodeViewModel: EpisodeViewModel

    
    var body: some View {
        
        VStack(alignment: .leading) {
            Text("Status")
                .font(.headline)
 
            Text("Status message here.")
 
            Text("Text")
                .padding(.top)
                .font(.headline)
                
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(episodeViewModel.episodeStructure) {audioSegment in
                        audioSegment.segmentIdentifer != .headlines ? Text(audioSegment.text) : Text(" * " + audioSegment.text)
                    }
                }
            }
            Spacer()
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Render") {
                    Task {
                        episodeViewModel.buildEpisodeStructure()
                        await episodeViewModel.playEpisodeStructure()
                    }
                }
            }
        }
        .onAppear {
            episodeViewModel.buildEpisodeStructure()
        }
    }
}

struct AudioRenderView_Previews: PreviewProvider {
    static var previews: some View {
        AudioRenderView(episodeViewModel: EpisodeViewModel())
    }
}
