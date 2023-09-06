//
//  EpisodeEditorSettingsView.swift
//  Podcast Creator (macOS)
//
//  Created by Andy Giefer on 28.02.23.
//

import SwiftUI
import DWSpeakerKit

struct EpisodeEditorSettingsView: View {
    
    var chosenEpisodeId: UUID
    
    @EnvironmentObject var episodeViewModel: EpisodeViewModel
    @EnvironmentObject var voiceViewModel: VoiceViewModel
    
    /// Showing PodcastRenderViewSheet?
    @State private var showingSheet = false
    
    /// The episode are we working on
    var chosenEpisode: Episode {
        return episodeViewModel[chosenEpisodeId]
    }
    
    /// Binding to currently chosen episode
    var chosenEpisodeBinding: Binding<Episode> {
        return $episodeViewModel[chosenEpisodeId]
    }
                
//    /// All voices that share the same provider and language
//    var availableVoices: [PodcastVoice] {
//        let episodeLanguage = chosenEpisode.language
////        let voiceProvider = chosenEpisode.podcastVoice.speechProvider
////        let availableVoices = VoiceManager.shared.availableVoices(forLanguage: episodeLanguage, forProvider: voiceProvider)
////        return availableVoices
//        
//        // current locale
//        let localeId = chosenEpisode.language.isoCode
//        
//        // set on voiceViewModel
//        voiceViewModel.selectedLocaleId = localeId
//        
//        //let episodeLocale = Locale(identifier: localeId)
//        
//    }
//    
//    /// All Voice providers
//    var availableProviders: [VoiceProvider] {
//
//        // set language on voiceViewModel
//        let episodeLanguage = chosenEpisode.language
//        let localeId = chosenEpisode.language.isoCode
//        voiceViewModel.selectedLocaleId = localeId
//        
//        let availableProviders = voiceViewModel.selectableProviders
//        
//        //let availableProviders = VoiceManager.shared.availableProviders(forLanguage: episodeLanguage)
//        return availableProviders
//    }
    
    var body: some View {
        GroupBox {
            
            VStack(alignment: .leading) {
                
                Text("Podcast Settings").font(.title2)

                Form {
                    
                    LabeledContent("Language:") {
                        Text(chosenEpisode.language.displayName)
                            .foregroundColor(.secondary)
                    }
                    
                    TextField("Narrator:", text: chosenEpisodeBinding.narrator, prompt: Text("Narrator"))
                                        
                    Picker("Voice Provider:", selection: $voiceViewModel.selectedProviderId) {
                        ForEach(voiceViewModel.selectableProviders, id: \.id) { provider in
                            Text(provider.displayName).tag(provider.id)
                        }
                    }
                    
                    
                    Picker("Synthetic Voice Identifier:", selection: $voiceViewModel.selectedVoiceId) {
                        ForEach(voiceViewModel.selectableVoices, id: \.id) { voice in
                            Text(voice.displayName).tag(voice.id)
                        }
                    }
                    
                    Text("Add high-quality voices through the Mac's Preferences.\nFind more information [here](https://support.apple.com/de-de/guide/mac-help/mchlp2290/mac).")
                        .font(.caption)
                        .lineLimit(2,reservesSpace: true)
                    
                    
                    
                }.padding()
            }.padding([.leading, .top, .trailing])
            
        }
    }
}

struct EpisodeEditorSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let episodeViewModel = EpisodeViewModel(createPlaceholderEpisode: true)
        if let firstEpisodeId = episodeViewModel.firstEpisodeId {
            
            EpisodeEditorSettingsView(chosenEpisodeId: firstEpisodeId)
                .padding()
                .environmentObject(episodeViewModel)
                .frame(width:550, height: 600)
            
        } else {
            Text("No episode to display")
        }
    }
}
