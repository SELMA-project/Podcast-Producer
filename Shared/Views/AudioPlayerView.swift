//
//  AudioPlayerView.swift
//  Podcast Creator
//
//  Created by Andy Giefer on 10.01.23.
//

import SwiftUI

struct AudioPlayerView: View {
 
    enum PlayButtonState {
        case waitingForStart, rendering, waitingForStop
    }
    
    @State var playButtonState: PlayButtonState = .waitingForStart
    @EnvironmentObject var viewModel: EpisodeViewModel
    
    var sectionId: UUID
    
    func buttonPressed() {
        
        Task {
            
            if playButtonState == .waitingForStart {
                
                // render audio
                playButtonState = .rendering
                let audioURL = await viewModel.renderEpisodeSection(withId: sectionId)
                playButtonState = .waitingForStart
                
                // if successful, start playback
                if let audioURL {
                    playButtonState = .waitingForStop
                    await viewModel.playAudioAtURL(audioURL)
                    playButtonState = .waitingForStart
                }
            }
            
            if playButtonState == .waitingForStop {
                viewModel.stopAudioPlayback()
                playButtonState = .waitingForStart
            }
        }
    }
    
    
    var body: some View {
        
        HStack {

            // replace audio button with spinner while rendering audio
            if playButtonState == .rendering {
                ProgressView()
            } else {
        
                Button {
                    buttonPressed()
                } label: {
                    Image(systemName: playButtonState == .waitingForStart ? "play.circle" : "pause.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                }
            }
            
            Spacer()
            
            ProgressView(value: 10, total: 100)

        }.onDisappear {
            // if we are leaving the view, stop the audio
            viewModel.stopAudioPlayback()
        }
    }
}

struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        let sectionId = UUID()
        AudioPlayerView(sectionId: sectionId)
            .padding()
    }
}
