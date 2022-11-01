//
//  GithubCreationDetailView.swift
//  Podcast Creator
//
//  Created by Andy Giefer on 31.10.22.
//

// currently not used

//import SwiftUI
//
//struct GithubCreationDetailView: View {
//
//    @EnvironmentObject var episodeViewModel: EpisodeViewModel
//    @Environment(\.dismiss) var dismiss
//
//    var scriptName: String = "2022-09-20-e2.md"
//
//    var body: some View {
//
//        Form {
//            Section {
//                Button(action: {
//                    episodeViewModel.addEpisode(parsedFromGithubScriptName: scriptName)
//                    dismiss()
//                }, label: {
//                    Text("Create Episode")
//                        .frame(maxWidth: .infinity)
//                })
//            }
//
//            Section("Script") {
//                ScriptView(scriptName: scriptName)
//            }
//        }
//        .navigationTitle("Preview")
//
//    }
//}
//
//struct GithubCreationDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//
//
//
//        NavigationStack {
//            GithubCreationDetailView()
//                .environmentObject(EpisodeViewModel())
//        }
//    }
//}
