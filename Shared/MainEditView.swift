//
//  MainEditView.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 08.08.22.
//

import SwiftUI

struct MainEditView: View {
    
    @State var titleText: String = "Boletim de Notícias (05/08/22) – Segunda edição"
    @State var teaserText: String = "Rússia e Ucrânia acusam-se mutuamente de um bombardeio à usina nuclear de Zaporíjia, a maior da Europa. Especialistas afirmam que uma inspeção técnica é urgente e necessária a fim de evitar possíveis acidentes. Ouça esse e outros destaques desta sexta-feira, na segunda edição do Boletim de Notícias da DW Brasil."
    @State var welcomeText: String = "Olá, hoje é sexta-feira, 5 de agosto de 2022. Eu sou Guilherme Becker e esta é a segunda edição do dia do Boletim de Notícias da DW Brasil."
    @State var headLineIntroductionText: String = "Confira nesta edição:"
    
    @State var selectedStoryNumber: Int = 1
    
    func incrementStoryNumber() {
        selectedStoryNumber = min(selectedStoryNumber+1, 5)
    }
    
    func decrementStoryNumber() {
        selectedStoryNumber = max(selectedStoryNumber-1, 1)
    }
    
    var body: some View {

        Form {
            
            Section("Episode title") {
                TextField("Teaser", text: $teaserText, axis:. vertical)
                    .lineLimit(3, reservesSpace: true)
            }
            
            Section("Episode teaser") {
                TextField("Teaser", text: $teaserText, axis:. vertical)
                    .lineLimit(3, reservesSpace: true)
            }
            
            Section("Welcome text") {
                TextField("Welcome text", text: $welcomeText, axis: .vertical)
            }
            
            Section("Headline introductiont") {
                TextField("Headline introduction", text: $headLineIntroductionText, axis: .vertical)
            }
            
            
            Section("Select story") {
//                Picker("Select story", selection: $selectedStoryNumber) {
//                    ForEach([1, 2, 3, 4, 5], id: \.self) {
//                        Text("\($0)")
//                    }
//                }
                Stepper(value: $selectedStoryNumber, in: 1...5) {
                     Text("Story number: \(selectedStoryNumber)")
                 }
            }
            
            StoryEditView(storyNumber: selectedStoryNumber)
 
                    
        }.padding()
    }
}

struct MainEditView_Previews: PreviewProvider {
    static var previews: some View {
        MainEditView()
    }
}
