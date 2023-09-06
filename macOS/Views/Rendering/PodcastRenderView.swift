//
//  PodcastRenderView.swift
//  Podcast Creator
//
//  Created by Andy Giefer on 10.01.23.
//

import SwiftUI

struct PodcastRenderView: View {
    
    var chosenEpisodeId: UUID?
    
    @Environment(\.dismiss) var dismissAction
    @EnvironmentObject var episodeViewModel: EpisodeViewModel
    @EnvironmentObject var voiceViewModel: VoiceViewModel
    
    @State private var progressText = "Press button to render."
    @State private var progressValue = 0.0
    @State private var muteBackgroundAudio = false

    @State private var audioURL: URL? = nil
    
    var renderProgressIsVisible: Bool {
        return progressValue > 0 && progressValue  < 100
    }
    
    func getDownloadsDirectory() -> URL {
        // find all possible download directories for this user
        let paths = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }
    
    func save(toURL destinationUrl: URL) {
        if let audioURL {
            
            do {
                try FileManager.default.copyItem(at: audioURL, to: destinationUrl)
            } catch {
                print("Error while saving file: \(destinationUrl.absoluteString)")
            }
        }
    }
    
    func showSavePanel() -> URL? {
        
        var returnedURL: URL? = nil
        
        if let audioURL {
            
            let savePanel = NSSavePanel()
            //savePanel.allowedContentTypes = []
            savePanel.canCreateDirectories = true
            savePanel.isExtensionHidden = false
            savePanel.nameFieldStringValue = audioURL.lastPathComponent
            //savePanel.allowsOtherFileTypes = false
            savePanel.title = "Save audio"
            savePanel.message = "Choose a folder and a name to store your audio."
            savePanel.nameFieldLabel = "File name:"
            let response = savePanel.runModal()
            
            if response == .OK {
                returnedURL = savePanel.url
            }
            
        }
        
        return returnedURL
    }
    var body: some View {
       
        VStack(alignment: .leading) {
            
            HStack {
                Text("Render Podcast").font(.title2)
                
            }
            
            Text("Render the podcast to convert the text in each section into synthesized speech while adding additional audio elements.")
                .font(.caption)
            

            
            HStack {
                                
//                Button {
//                    Task {
//
//                        progressValue = 50
//                        progressText = "Synthesizing speech..."
//                        audioURL = await episodeViewModel.renderEpisode(chosenEpisodeId: chosenEpisodeId)
//
//                        progressValue = 100
//                        progressText = "Ready for sharing."
//                    }
//                } label: {
//                    Text("Build")
//                        .frame(maxWidth: .infinity)
//                }
//                .disabled(audioURL != nil)
//                .buttonStyle(.borderedProminent)
//                .frame(maxWidth: 100)
//
//                ProgressView(progressText, value: progressValue, total: 100)
//                    .opacity(renderProgressIsVisible ? 1 : 0)
//

            }
            


            // display audio player if we have an audio URL
            AudioPlayerView(audioURL: audioURL)
                .padding([.top, .bottom])

            Divider()//.padding([.top, .bottom])

            
            VStack(alignment: .leading) {
                
                Toggle("Mute background audio", isOn: $muteBackgroundAudio)
                    .onChange(of: muteBackgroundAudio) { newValue in
                        // a change of this toggle invalidates the audioURL, so the Build button is active again
                        audioURL = nil
                    }
                
                HStack {
                    
                    Button {
                        Task {
                            
                            progressValue = 50
                            progressText = "Synthesizing speech..."
                            
                            let chosenEpisode = episodeViewModel[chosenEpisodeId]
                            
                            audioURL = await voiceViewModel.renderEpisode(chosenEpisode, muteBackgroundAudio: muteBackgroundAudio)
                            
                            progressValue = 100
                            progressText = "Ready for sharing."
                        }
                    } label: {
                        Text("Build")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(audioURL != nil)
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: 100)
                    
                    ProgressView(progressText, value: progressValue, total: 100)
                        .opacity(renderProgressIsVisible ? 1 : 0)
                    
                    Spacer()
                    
                    Button {
                        dismissAction()
                    } label: {
                        Text("Cancel")
                    }
                    
                    Button {
                        if let destionationURL = showSavePanel() {
                            save(toURL: destionationURL)
                        }
                        
                        dismissAction()
                        
                    } label: {
                        Text("Save Audio")
                    }.disabled(audioURL == nil)
                }
            }
        }
    }
}

struct PodcastRenderView_Previews: PreviewProvider {
    static var previews: some View {
        let episodeViewModel = EpisodeViewModel()
        if episodeViewModel.availableEpisodes.count > 0 {
            let firstEpisodeId = episodeViewModel.availableEpisodes[0].id
            PodcastRenderView(chosenEpisodeId: firstEpisodeId)
                .padding()
                .frame(width:450)
        } else {
            Text("No episode to display")
        }
    }
}
