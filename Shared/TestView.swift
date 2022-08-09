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
    @State private var teams = [Team(name: "AFC Richmond", players: ["Dani", "Jamie", "Row"])]

    @State private var selectedTeam: Team?
    @State private var selectedPlayer: String?

    var body: some View {
        NavigationSplitView {
            List(teams, selection: $selectedTeam) { team in
                Text(team.name).tag(team)
            }
            .navigationSplitViewColumnWidth(250)
        } content: {
            List(selectedTeam?.players ?? [], id: \.self, selection: $selectedPlayer) { player in
                Text(player)
            }
        } detail: {
            Text(selectedPlayer ?? "Please choose a player.")
        }
        .navigationSplitViewStyle(.prominentDetail)
    }
}
struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
