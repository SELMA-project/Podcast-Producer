//
//  StoryEditView.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 08.08.22.
//

import SwiftUI

struct StoryEditView: View {
    
    var storyNumber: Int = 1
    
    @State var storyHeadline: String = "Rússia e Ucrânia acusam-se mutuamente de bombardeio em usina nuclear"
    @State var storyText: String =
"""
Os governos da Rússia e da Ucrânia trocaram acusações sobre um bombardeio à usina nuclear de Zaporíjia, a maior da Europa, no sudeste da Ucrânia.

Agências de notícias russas informaram nesta sexta-feira que o exército ucraniano teria disparado contra as instalações.

As fontes das agências russas seriam militares que administram o local desde que a usina foi tomada pelo exército da Rússia, em março.

Segundo as agências, duas linhas de energia foram cortadas e houve um incêndio.

A Ucrânia, por sua vez, afirma que os próprios russos bombardearam a área e que uma linha de alta tensão para uma usina termelétrica vizinha foi danificada.

Um dos reatores da usina nuclear teria sido fechado.

Especialistas afirmam que uma inspeção técnica é urgente e extremamente necessária a fim de evitar possíveis acidentes.

Mas o acesso ao local da usina é bastante complicado por se tratar de uma zona de guerra.
"""
    
    var body: some View {
        TextField("Headline", text: $storyHeadline)
        TextEditor(text: $storyText)
            .layoutPriority(1)

        
    }
}

struct StoryEditView_Previews: PreviewProvider {
    static var previews: some View {
        StoryEditView()
    }
}
