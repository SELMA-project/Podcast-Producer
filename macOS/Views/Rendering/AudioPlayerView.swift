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
    
            HStack(alignment: .center) {
                Button {
                    print("Going back")
                } label: {
                    Image(systemName: "gobackward.15")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .buttonStyle(.plain)
                
                Button {
                    buttonPressed()
                } label: {
                    Image(systemName: playButtonState == .waitingForStart ? "play.circle" : "pause.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .buttonStyle(.plain)
                
                Button {
                    print("Going forward")
                } label: {
                    Image(systemName: "goforward.15")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .buttonStyle(.plain)
                
                ProgressView(value: 0, total: 100)
                    //.hidden()
            }.frame(height:30)
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
