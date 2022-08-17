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
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(episodeViewModel.episodeStructure) {audioSegment in
                        Group {
                            audioSegment.segmentIdentifer != .headlines ? Text(audioSegment.text) : Text(" * " + audioSegment.text)
                        }
                        .opacity(audioSegment.isActive ? 1.0 : 0.2)
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
