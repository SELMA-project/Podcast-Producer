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
        List {
            ForEach(episodeViewModel.episodeStructure) {audioSegment in
                HStack {
                    // title and tubtitle on left
                    VStack(alignment: .leading) {
                        Text(audioSegment.segmentIdentifer.rawValue.capitalized)
                            .font(.title3)
                        
                        Text(audioSegment.text)
                            .lineLimit(1)
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    // progress view or play button the right
                    PlayButton(episodeViewModel: episodeViewModel, audioSegment: audioSegment)
                }
            }
        }
        .listStyle(PlainListStyle())
        .task {
            episodeViewModel.buildEpisodeStructure()
            await episodeViewModel.renderEpisodeStructure()
        }
    }
}

struct PlayButton: View {

    @ObservedObject var episodeViewModel: EpisodeViewModel
    var audioSegment: AudioSegment

    
    var body: some View {

        if audioSegment.audioData == nil {
            ProgressView()
        }
        else {
            Button {
                Task {
                    await episodeViewModel.playButtonPressed(forSegment: audioSegment)
                }
            } label: {
                Image(systemName: audioSegment.isPlaying == true ? "pause.circle" : "play.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
            }
        }
    }
    
}


struct AudioRenderView_Previews: PreviewProvider {
    static var previews: some View {
        AudioRenderView(episodeViewModel: EpisodeViewModel())
    }
}
