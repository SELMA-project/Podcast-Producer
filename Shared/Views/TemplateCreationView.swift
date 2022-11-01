//
//  TemplateCreationView.swift
//  Podcast Creator
//
//  Created by Andy Giefer on 28.10.22.
//

import SwiftUI

struct TemplateCreationView: View {
    
    @State var language: LanguageManager.Language = .brazilian
    @State var templateIndex: Int = 0
    
    @Environment(\.dismiss) var dismissAction
    @EnvironmentObject var episodeViewModel: EpisodeViewModel
    
    var templates: [EpisodeTemplate] {
        let templates = EpisodeTemplate.templates(forLanguage: language)
            
        return templates
    }

    var body: some View {
        
        VStack(alignment: .leading) {
            
            Text("Create a new episode based on a template.")
                .font(.callout)
                .padding()
            
            
            Form {
                
                Section("Specify Template") {
                    Picker("Language", selection: $language) {
                        ForEach(LanguageManager.Language.allCases, id: \.self) {language in
                            Text(language.displayName)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: language) {_ in 
                        templateIndex = 0
                    }
                    
                    Picker("Template", selection: $templateIndex) {
                        ForEach(0..<templates.count, id: \.self) { index in
                            Text(templates[index].name)
                        }
                    }.pickerStyle(.menu)
                }
                
                
                HStack {
                    Spacer()
                    Button("Create") {
                        // create episode based on currently selected template
                        let template = templates[templateIndex]
                        episodeViewModel.addEpisode(basedOnTemplate: template)
                        dismissAction()
                    }
                    Spacer()
                }
                
            }
            
            
            
        }
        //.padding()
        //.scrollContentBackground(.hidden)
        
        
        
        
    }
}

struct TemplateCreationView_Previews: PreviewProvider {
    static var previews: some View {
        TemplateCreationView()
    }
}
