//
//  GithubCreationView.swift
//  Podcast Creator
//
//  Created by Andy Giefer on 28.10.22.
//

import SwiftUI

struct GithubCreationView: View {
    
    
    @State var selectedFile: String = "File 1"
    @EnvironmentObject var episodeViewModel: EpisodeViewModel

    var scriptNames: [String] {
        let scripNames = ScriptParser.availableScriptNames()
        return scripNames
    }
    
    var body: some View {

        VStack(alignment: .leading) {
            
            Text("Import a script from Github.")
                .font(.callout)
                .padding()
        
            List {
                ForEach(scriptNames, id: \.self) {scriptName in
                    //NavigationLink(value: scriptName) {
//                    Button {
//                        print("tapped")
//                        dismissAction()
//
//                    } label: {
//                        TableRow(scriptName: scriptName)
//                    }
                    TableRow(scriptName: scriptName)

                    //}
                }
            }
            .listStyle(.automatic)
//            .navigationDestination(for: String.self) { scriptName in
//                GithubCreationDetailView(scriptName: scriptName)
//            }
        }
        
//        Form {
//
//            Picker("File name", selection: $selectedFile) {
//                Text("File 1").tag("File 1")
//                Text("File 2").tag("File 2")
//                Text("File 3").tag("File 3")
//            }
//
//        }
        
//        VStack(alignment: .leading) {
//            Text("Import a script from Github.")
//                .font(.callout)
//            .padding(.top)
//
//            VStack(alignment: .leading) {
//                Text("Available Scripts").font(.title2)
//
//                Picker("Language", selection: $selectedFile) {
//                    Text("File 1").tag("File 1")
//                    Text("File 2").tag("File 2")
//                    Text("File 3").tag("File 3")
//                }
//            }.padding(.top)
//
//        }.padding()
    }
}

struct TableRow: View {
    
    var scriptName: String
    
    @Environment(\.dismiss) var dismissAction
    @EnvironmentObject var episodeViewModel: EpisodeViewModel
    
    @State var revealsCreateButton: Bool = false
    
    var body: some View {
        
        HStack {
            Button {
                revealsCreateButton.toggle()
            } label: {
                Text(scriptName)
            }
            
            Spacer()
            
            if revealsCreateButton {
                Button {
                    episodeViewModel.addEpisode(parsedFromGithubScriptName: scriptName)
                    dismissAction()
                } label: {
                    Text("Create Episode")
                        .font(.body)
                }.buttonStyle(.borderedProminent)
            }

        }

    }
}

struct GithubCreationView_Previews: PreviewProvider {
    static var previews: some View {
        
        
        GithubCreationView()
            .environmentObject(EpisodeViewModel())
    }
}



