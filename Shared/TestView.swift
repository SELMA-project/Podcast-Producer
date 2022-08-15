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
        Text("Hi!")
    }
}
struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
