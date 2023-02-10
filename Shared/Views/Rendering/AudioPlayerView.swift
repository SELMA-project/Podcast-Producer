//
//  AudioPlayerView.swift
//  Podcast Creator
//
//  Created by Andy Giefer on 10.01.23.
//

import SwiftUI

struct AudioPlayerView: View {
 
    enum PlayButtonState {
        case waitingForStart, waitingForStop
    }
    
    @State var playButtonState: PlayButtonState = .waitingForStart
    @EnvironmentObject var viewModel: EpisodeViewModel
    
    var audioURL: URL?
    
    func buttonPressed() {
        
        Task {
            
            if playButtonState == .waitingForStart {
                
                // start playback
                playButtonState = .waitingForStop
                if let audioURL {
                    await viewModel.playAudioAtURL(audioURL)
                }
                playButtonState = .waitingForStart
            }
            
            if playButtonState == .waitingForStop {
                viewModel.stopAudioPlayback()
                playButtonState = .waitingForStart
            }
        }
    }
    
    
    var body: some View {
        
        VStack {
    
            ProgressView(value: 0, total: 100)
                .padding(.bottom)
                .hidden()
            
            HStack {
                
//                Spacer()
                
//                Button {
//                    print("Going back")
//                } label: {
//                    Image(systemName: "arrow.uturn.backward.circle")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 30, height: 30)
//                }

                Spacer()
                
                Button {
                    buttonPressed()
                } label: {
                    Image(systemName: playButtonState == .waitingForStart ? "play.circle" : "pause.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                }
                
                Spacer()
                
//                Button {
//                    print("Going fowards")
//                } label: {
//                    Image(systemName: "arrow.uturn.forward.circle")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 30, height: 30)
//                }
//                
//                Spacer()
                
            }
            

        }
        .disabled(audioURL == nil)
        .onDisappear {
            // if we are leaving the view, stop the audio
            viewModel.stopAudioPlayback()
        }
    }
}

struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        let episodeUrl: URL = Bundle.main.url(forResource: "no-audio.m4a", withExtension: nil)!
        AudioPlayerView(audioURL: episodeUrl)
            .padding()
    }
}
