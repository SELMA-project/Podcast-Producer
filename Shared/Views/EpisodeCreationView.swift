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
        case template, github, translation
    }
    
    @State private var choice: Choice = .template
    
    var body: some View {
        
        NavigationView {
            VStack(alignment: .leading) {
                        
                Picker("How do you want to create a new episode?", selection: $choice) {
                    Text("Template").tag(Choice.template)
                    Text("Github").tag(Choice.github)
                    Text("Translation").tag(Choice.translation)
                }
                .pickerStyle(.segmented)
                
                switch(choice) {
                case .template:
                    TemplateCreationView()

                case .github:
                    GithubCreationView()
                    
                case .translation:
                    Text("Translation")
                }

                Spacer()


            }
            .padding()
            
            .toolbar {
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Create") {
                        dismiss()
                    }
                }

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
    }
}
