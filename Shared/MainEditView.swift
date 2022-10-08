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

struct StructureRow: View {
    var section: EpisodeSection
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(section.name)
                .font(.title3)
            
            switch section.type {
            case .standard:
                Text(section.text)
                    .font(.caption)
                    .lineLimit(1)
            case .stories:
                Text(section.headline)
                    .font(.caption)
                    .lineLimit(1)
            default:
                EmptyView()
            }
            
        }
    }
}

struct StandardSectionView: View {
    
    var section: EpisodeSection
    
    var body: some View {
        Section(section.name) {
            NavigationLink(value: section) {
                Text(section.text)
            }
        }

    }
}

struct StoriesSectionView: View {
    
    var section: EpisodeSection
    var episodeStories: [Story]
    
    var body: some View {
        Section(section.name) {
            NavigationLink(value: section) {
                Text("Configure stories")
            }
            ForEach(0..<episodeStories.count, id:\.self) {storyNumber in
                //NavigationLink(value: storyNumber) {
                    Text(episodeStories[storyNumber].headline)
                //}
            }
        }
    }
}




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
                
                ForEach(episodeSections) {section in
                    
                    if section.type == .standard {
                        StandardSectionView(section: section)
                    }
                    
                    if section.type == .stories {
                        StoriesSectionView(section: section, episodeStories: episodeStories)
                    }
                }
            
            
            //                ForEach(0..<episodeSections.count, id: \.self) {sectionNumber in
            //
            //                    // section name
            //                    Section(episodeSections[sectionNumber].name) {
            //
            //                        if episodeSections[sectionNumber].type == .standard {
            //                            Text("Hallo")
            //                            //                            NavigationLink(value: episodeSections[sectionNumber]) {
            //                            //                                Section(episodeSections[sectionNumber].text)
            //                            //                            }
            //                        }
            //
            //
            //                        if episodeSections[sectionNumber].type == .stories {
            //                            storiesSection
            //                        }
            //                    }
            //                }
            
        }
        .navigationDestination(for: Int.self) { sectionNumber in
            SectionEditView(episodeViewModel: episodeViewModel, sectionNumber: sectionNumber)
        }
        .navigationDestination(for: EpisodeSection.self) { section in
            //SectionEditView(episodeViewModel: episodeViewModel, sectionNumber: sectionNumber)
            if section.type == .standard {
                StandardSectionEditView(section: section)
            }
            
            if section.type == .stories {
                StoriesSectionEditView(section: section)
            }
        }

    }
        .navigationTitle("Episode Editor")
        .padding()
    // somehow this avoid that in the simulator the path is incorrectly set
        .onChange(of: path) { path in
            print(path)
        }
    
}

}



//struct MainEditViewOld: View {
//    
//    @ObservedObject var episodeViewModel: EpisodeViewModel
//    @State private var path = NavigationPath() //: [Int] = []
//    @State private var chosenSpeaker = SelmaVoice(.leila)
//    
//    var body: some View {
//        
//        NavigationStack(path: $path) {
//            
//            Form {
//                
//                Section("Speaker") {
//                    Picker("Name", selection: $episodeViewModel.speaker) {
//                        ForEach(SelmaVoice.allVoices, id: \.self) {speaker in
//                            Text(speaker.shortName)
//                        }
//                    }
//                }
//                
//                Section("Introduction") {
//                    TextField("Introduction", text:  $episodeViewModel.availableEpisodes[episodeViewModel.chosenEpisodeIndex].introductionText, axis: .vertical)
//                }
//                
//                Section("Stories") {
//                    ForEach(0..<episodeViewModel.availableEpisodes[episodeViewModel.chosenEpisodeIndex].stories.count, id:\.self) {storyNumber in
//                        NavigationLink(value: storyNumber) {
//                            Text(episodeViewModel.availableEpisodes[episodeViewModel.chosenEpisodeIndex].stories[storyNumber].headline)
//                        }
//                    }
//                }
//                
//                Section("Epilog") {
//                    TextField("Epilogue", text:  $episodeViewModel.availableEpisodes[episodeViewModel.chosenEpisodeIndex].epilog, axis: .vertical)
//                }
//                
//            }
//            .navigationDestination(for: Int.self) { storyNumber in
//                StoryEditView(episodeViewModel: episodeViewModel, storyNumber: storyNumber)
//            }
//        }
//        .navigationTitle("Episode Editor")
//        .padding()
//        
//    }
//    
//}

struct MainEditView_Previews: PreviewProvider {
    
    static var previews: some View {
        MainEditView(episodeViewModel: EpisodeViewModel())
    }
}
