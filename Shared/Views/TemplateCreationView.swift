//
//  TemplateCreationView.swift
//  Podcast Creator
//
//  Created by Andy Giefer on 28.10.22.
//

import SwiftUI

struct TemplateCreationView: View {
    
    @State var language: String = "Brazilian Portuguese"
    @State var template: String = "Boletim de Notícias"
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Text("Create a new episode based on a template.")
                .font(.callout)
                .padding()
            
            
            Form {
                
                Section("Specify Template") {
                    Picker("Language", selection: $language) {
                        Text("Brazilian Portuguese").tag("Brazilian Portuguese")
                        Text("German").tag("German")
                        Text("English").tag("English")
                    }
                    
                    Picker("Template", selection: $template) {
                        Text("Boletim de Notícias").tag("Boletim de Notícias")
                        Text("Deutschlandfunk Nachrichten").tag("Deutschlandfunk Nachrichten")
                        Text("Spanish Noticias").tag("Spanish Noticias")
                    }
                }
                
                
                HStack {
                    Spacer()
                    Button("Create") {
                        
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
