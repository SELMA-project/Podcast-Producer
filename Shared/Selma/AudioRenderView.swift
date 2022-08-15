//
//  AudioRenderView.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 15.08.22.
//

import SwiftUI

struct AudioRenderView: View {
    
    @ObservedObject var episodeViewModel: EpisodeViewModel
    @StateObject var selmaViewModel = SelmaViewModel()
    
    var body: some View {
        VStack {
            Button("Render!") {
                Task {
                    await selmaViewModel.testRender()
                }
            }
            Text(selmaViewModel.statusMessage)
        }
    }
}

struct AudioRenderView_Previews: PreviewProvider {
    static var previews: some View {
        AudioRenderView(episodeViewModel: EpisodeViewModel())
    }
}
