//
//  GithubCreationDetailView.swift
//  Podcast Creator
//
//  Created by Andy Giefer on 31.10.22.
//

import SwiftUI

struct GithubCreationDetailView: View {
    
    var scriptName: String = "2022-09-20-e2.md"
    
    var body: some View {
//
//        VStack {
//
//            Button(action: {
//
//            }, label: {
//                Text("Create")
//                    .frame(maxWidth: .infinity)
//            })
//            .buttonStyle(.borderedProminent)
//            .padding()
//
//
//            ScriptView(scriptName: scriptName)
//        }
  
        Form {
            Section {
                Button(action: {
                    
                }, label: {
                    Text("Create Episode")
                        .frame(maxWidth: .infinity)
                })
            }
            
            Section("Script") {
                ScriptView(scriptName: scriptName)
            }
        }
        .navigationTitle("Preview")
        
    }
}

struct GithubCreationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GithubCreationDetailView()
        }
    }
}
