//
//  AudioPlayerView.swift
//  Podcast Creator
//
//  Created by Andy Giefer on 10.01.23.
//

import SwiftUI

struct AudioPlayerView: View {
 
//    enum PlayButtonState {
//        case waitingForStart, waitingForStop
//    }
    
    //@State var playButtonState: PlayButtonState = .waitingForStart
    //@EnvironmentObject var viewModel: EpisodeViewModel
    @EnvironmentObject var voiceViewModel: VoiceViewModel
    
    var audioURL: URL?
    
    func buttonPressed() {
        
        Task {
            
            if voiceViewModel.playerStatus == .idle {
                
                // start playback
                voiceViewModel.playerStatus = .playing
                if let audioURL {
                    await voiceViewModel.playAudioAtURL(audioURL)
                }
                voiceViewModel.playerStatus = .idle
            }
            
            if voiceViewModel.playerStatus == .playing {
                voiceViewModel.stopAudioPlayback()
                voiceViewModel.playerStatus = .idle
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
                    Image(systemName: voiceViewModel.playerStatus != .playing ? "play.circle" : "pause.circle")
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
            voiceViewModel.stopAudioPlayback()
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
