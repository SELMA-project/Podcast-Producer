////
////  AudioRenderView.swift
////  Podcast Producer
////
////  Created by Andy Giefer on 15.08.22.
////
//
//import SwiftUI
//
//struct AudioRenderView: View {
//    
//    @EnvironmentObject var episodeViewModel: EpisodeViewModel
//    
//    // observe whether all episodeSegments have audioData -> episode can be built
//    var allAudioIsAvailable: Bool {
//        
//        var allAudioIsAvailable = false
//        
//        if episodeViewModel.episodeStructure.count > 0 {
//            allAudioIsAvailable = episodeViewModel.episodeStructure.reduce(true) {
//                return $0 && $1.audioIsRendered
//            }
//        }
//        
//        return allAudioIsAvailable
//    }
//    
//    var body: some View {
//        
//        List {
//            ForEach(episodeViewModel.episodeStructure) {episodeSegment in
//                HStack {
//                    // title and subtitle on left
//                    VStack(alignment: .leading) {
//                        Text(episodeSegment.blockIdentifier.rawValue.capitalized)
//                            .font(.title3)
//                        
//                        Text(episodeSegment.text)
//                            .lineLimit(1)
//                            .font(.caption)
//                    }
//                    
//                    Spacer()
//                    
//                    // progress view or play button the right
//                    PlayButton(episodeViewModel: episodeViewModel, episodeSegment: episodeSegment)
//                }
//            }
//        }
//        .listStyle(PlainListStyle())
//        
//        .task {
//            episodeViewModel.buildEpisodeStructure()
//            await episodeViewModel.renderEpisodeStructure()
//            //await episodeViewModel.buildAndRenderEpisodeStructure()
//        }
//        .toolbar {
//            ToolbarItem {
//                Button {
//                    Task {
//                        await episodeViewModel.buildAudio()
//                    }
//                } label: {
//                    Text("Build")
//                }.disabled(!allAudioIsAvailable)
//            }
//            
//            ToolbarItem {
//                ShareLink(item: episodeViewModel.episodeUrl) {
//                    Text("Share")
//                }//.disabled(episodeViewModel.episodeAvailable == false)
//            }
//
//        }
//    }
//}
//
//struct PlayButton: View {
//    
//    @ObservedObject var episodeViewModel: EpisodeViewModel
//    var episodeSegment: BuildingBlock
//    
//    
//    var body: some View {
//        
//        if !episodeSegment.audioIsRendered {
//            ProgressView()
//        }
//        else {
//            Button {
//                Task {
//                    await episodeViewModel.playButtonPressed(forSegment: episodeSegment)
//                }
//            } label: {
//                Image(systemName: episodeSegment.isPlaying == true ? "pause.circle" : "play.circle")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 25, height: 25)
//            }
//        }
//    }
//    
//}
//
//
//struct AudioRenderView_Previews: PreviewProvider {
//    static var previews: some View {
//        AudioRenderView()
//    }
//}
