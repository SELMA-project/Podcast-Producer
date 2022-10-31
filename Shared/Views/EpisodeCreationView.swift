//
//  EpisodeCreationView.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 18.10.22.
//

import SwiftUI



struct EpisodeCreationView: View {
    
    @Environment(\.dismiss) var dismiss
    
    enum Choice {
        case template, github
    }
    
    @State private var choice: Choice = .template
    
    var body: some View {
        
        NavigationStack {
            VStack(alignment: .leading) {
                                      
                Picker("How do you want to create a new episode?", selection: $choice) {
                    Text("Template").tag(Choice.template)
                    Text("Github").tag(Choice.github)
                }
                .pickerStyle(.segmented)
                .padding()
                
                switch(choice) {
                case .template:
                    TemplateCreationView()
                    
                case .github:
                    GithubCreationView()
                }
                
                Spacer()


            }
            //.padding()
            
            .toolbar {
                
 

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
    
            }
            .navigationTitle("New Episode")
        }
        
    }
}

struct EpisodeCreationView_Previews: PreviewProvider {
    static var previews: some View {
        EpisodeCreationView()
            .environmentObject(EpisodeViewModel())
    }
}
