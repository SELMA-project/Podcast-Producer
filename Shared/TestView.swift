//
//  TestView.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 09.08.22.
//

import SwiftUI


struct Team: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var players: [String]
}

struct TestView: View {

    @StateObject var episodeViewModel = EpisodeViewModel()

    var body: some View {
//        NavigationStack {
//            List(episodeViewModel.chosenEpisode.stories, id: \.headline) {story in
//                NavigationLink(value: episodeViewModel.chosenEpisode.stories.firstIndex(where: {$0.headline == story.headline})) {
//                    Text(story.headline)
//                }
//            }.navigationDestination(for: Int.self) { i in
//                Text("Detail \(i)")
//            }
//        }
        
        NavigationStack {
            List(episodeViewModel.chosenEpisode.stories, id: \.headline) {story in
                NavigationLink(value: episodeViewModel.chosenEpisode.stories.firstIndex(where: {$0.headline == story.headline})) {
                    Text(story.headline)
                }
            }.navigationDestination(for: Int.self) { i in
                Text("Detail \(i)")
            }
        }
        
        
//        NavigationStack {
//            List(1..<50) { i in
//                NavigationLink(value: i) {
//                    Label("Row \(i)", systemImage: "\(i).circle")
//                }
//            }
//            .navigationDestination(for: Int.self) { i in
//                Text("Detail \(i)")
//            }
//            .navigationTitle("Navigation")
//        }
    }
}
struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
