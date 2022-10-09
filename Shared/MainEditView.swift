//
//  MainEditView.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 08.08.22.
//

import SwiftUI

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ conditional: Bool,  @ViewBuilder content: (Self) -> Content) -> some View {
        if conditional {
            content(self)
        }
        else {
            self
        }
    }
}

//struct StructureRow: View {
//    var section: EpisodeSection
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(section.name)
//                .font(.title3)
//
//            switch section.type {
//            case .standard:
//                Text(section.text)
//                    .font(.caption)
//                    .lineLimit(1)
//            case .stories:
//                Text(section.headline)
//                    .font(.caption)
//                    .lineLimit(1)
//            default:
//                EmptyView()
//            }
//
//        }
//    }
//}

//struct StandardSectionView: View {
//
//    var section: EpisodeSection
//
//    var body: some View {
//        Section(section.name) {
//            NavigationLink(value: section) {
//                Text(section.text)
//            }
//        }
//
//    }
//}

//struct StoriesSectionView: View {
//
//    var section: EpisodeSection
//    var episodeStories: [Story]
//
//    var body: some View {
//        Section(section.name) {
//            NavigationLink(value: section) {
//                Text("Configure stories")
//            }
//            ForEach(0..<episodeStories.count, id:\.self) {storyNumber in
//                //NavigationLink(value: storyNumber) {
//                Text(episodeStories[storyNumber].headline)
//                //}
//            }
//        }
//    }
//}




struct MainEditView: View {
    
    @ObservedObject var episodeViewModel: EpisodeViewModel
    @State private var path = NavigationPath() //: [Int] = []
    @State private var chosenSpeaker = SelmaVoice(.leila)
    
    var episodeSections: [EpisodeSection] {
        return episodeViewModel.availableEpisodes[episodeViewModel.chosenEpisodeIndex].sections
    }
    
    var episodeStories: [Story] {
        return episodeViewModel.availableEpisodes[episodeViewModel.chosenEpisodeIndex].stories
    }
    
    var body: some View {
        
        NavigationStack(path: $path) {
            
            
            Form {
                
                Section("Speaker") {
                    Picker("Name", selection: $episodeViewModel.speaker) {
                        ForEach(SelmaVoice.allVoices, id: \.self) {speaker in
                            Text(speaker.shortName)
                        }
                    }
                }
                
                
                Section("Structure") {
                    ForEach(episodeSections) {section in
                        NavigationLink(value: section) {
                            Text(section.name)
                        }
                    }
                }
                
            }
            
            .navigationDestination(for: EpisodeSection.self) { section in
                SectionEditView(section: section)
            }
            .navigationTitle("Episode Editor")
            
        }
        
        .padding()
        // somehow this avoid that in the simulator the path is incorrectly set
        .onChange(of: path) { path in
            //print(path)
        }

    }
}

struct MainEditView_Previews: PreviewProvider {
    
    static var previews: some View {
        MainEditView(episodeViewModel: EpisodeViewModel())
    }
}
