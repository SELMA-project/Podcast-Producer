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
        
        Text("Create a new episode based on a template.")
            .font(.callout)
            .padding(.top)
        
        VStack(alignment: .leading) {
            Text("Episode language").font(.title2)
        
            Picker("Language", selection: $language) {
                Text("Brazilian Portuguese").tag("Brazilian Portuguese")
                Text("German").tag("German")
                Text("English").tag("English")
            }
        }.padding(.top)

        VStack(alignment: .leading) {
            Text("Template").font(.title2)
            Picker("Template", selection: $template) {
                Text("Boletim de Notícias").tag("Boletim de Notícias")
                Text("Deutschlandfunk Nachrichten").tag("Deutschlandfunk Nachrichten")
                Text("Spanish Noticias").tag("Spanish Noticias")
            }
        }.padding(.top)
        
        Spacer()
        
    }
}

struct TemplateCreationView_Previews: PreviewProvider {
    static var previews: some View {
        TemplateCreationView()
    }
}
