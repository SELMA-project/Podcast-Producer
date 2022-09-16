//
//  AudioRenderView.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 15.08.22.
//

import SwiftUI

struct AudioRenderView: View {
    
    @ObservedObject var episodeViewModel: EpisodeViewModel
    
    // if at least one episodeSegment has audioData, a download is possible
    var downloadIsPossible: Bool {
        episodeViewModel.episodeStructure.reduce(false) {
            return $0 || $1.audioURL != nil
        }
    }
    
    var body: some View {
        
        VStack {
            HStack {
                Button {
                    Task {
                        episodeViewModel.buildEpisodeStructure()
                        await episodeViewModel.renderEpisodeStructure()
                    }
                } label: {
                    Text("Synthesize")
                }
                
                Button {
                    Task {
                        episodeViewModel.downloadAudio()
                    }
                } label: {
                    Text("Build")
                }
                
                ShareLink(item: episodeViewModel.episodeUrl) {
                    Text("Share")
                }.disabled(episodeViewModel.episodeAvailable == false)
 

            }

            List {
                ForEach(episodeViewModel.episodeStructure) {episodeSegment in
                    HStack {
                        // title and subtitle on left
                        VStack(alignment: .leading) {
                            Text(episodeSegment.segmentIdentifer.rawValue.capitalized)
                                .font(.title3)
                            
                            Text(episodeSegment.text)
                                .lineLimit(1)
                                .font(.caption)
                        }
                        
                        Spacer()
                        
                        // progress view or play button the right
                        PlayButton(episodeViewModel: episodeViewModel, episodeSegment: episodeSegment)
                    }
                }
            }
            .listStyle(PlainListStyle())
        }

//        .task {
//            episodeViewModel.buildEpisodeStructure()
//            await episodeViewModel.renderEpisodeStructure()
//        }
//        .toolbar {
//            ToolbarItem {
//                Button {
//                    episodeViewModel.downloadAudio()
//                } label: {
//                    Image(systemName: "square.and.arrow.down")
//                }.disabled(!downloadIsPossible)
//            }
//        }
    }
}

struct PlayButton: View {

    @ObservedObject var episodeViewModel: EpisodeViewModel
    var episodeSegment: EpisodeSegment

    
    var body: some View {

        if episodeSegment.audioURL == nil {
            ProgressView()
        }
        else {
            Button {
                Task {
                    await episodeViewModel.playButtonPressed(forSegment: episodeSegment)
                }
            } label: {
                Image(systemName: episodeSegment.isPlaying == true ? "pause.circle" : "play.circle")
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
