//
//  EpisodeData.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 09.08.22.
//

import Foundation

extension Episode {
    static var episode0: Episode {
        
        let story1 = Story(usedInIntroduction: true,
                           headline: "Rússia anuncia mobilização parcial de 300 mil reservistas",
                           storyText:
"""
O presidente da Rússia, Vladimir Putin, anunciou uma mobilização militar parcial, com a convocação imediata de reservistas. O ministro russo da Defesa, Sergei Shoigu, disse que 300 mil reservistas serão parcialmente mobilizados. Putin garantiu que eles terão o mesmo status e o mesmo soldo dos atuais soldados regulares e receberão treinamento militar antes de irem para a frente de luta. De acordo com Putin, o motivo da mobilização é a defesa de territórios russos e libertação da região ucraniana do Donbass. Putin também voltou a ameaçar o Ocidente, dizendo que seu país tem vários meios de destruição, inclusive mais modernos que os da Otan. O anúncio de Putin ocorreu horas depois que grupos separatistas pró-Moscou divulgaram a intenção de realizar referendos ainda esta semana que poderiam abrir caminho para uma futura anexação de vastos territórios da Ucrânia pela Rússia. O Ocidente e Kiev já deixaram claro que não aceitarão o resultado dessas consultas.
"""
)
        
        let story2 = Story(usedInIntroduction: true,
                           headline: "Chanceler federal alemão acusa Rússia de imperialismo",
                           storyText:
"""
Em seu discurso na Assembleia Geral da ONU nesta terça-feira, o chanceler federal da Alemanha, Olaf Scholz, acusou a Rússia de "imperialismo flagrante" e prometeu mais apoio à Ucrânia, incluindo entregas de mais armas. Scholz disse que o president russo, Vladimir Putin, só desistirá da guerra e de suas ambições imperialistas se perceber que não pode vencer a guerra na Ucrânia. Scholz disse ainda que Putin não está destruindo apenas a Ucrânia, mas também a Rússia. O chefe de governo da Alemanha acrescentou que nenhum referendo simulado será aceito.
"""
        )
        
        let story3 = Story(usedInIntroduction: false,
                           headline: "Presidente francês critica países neutros em relação à guerra na Ucrânia",
                           storyText:
"""
O presidente da França, Emmanuel Macron, disse em seu discurso na Assembleia Geral da ONU que vê um ressurgimento do imperialismo e das colônias na guerra de agressão russa contra a Ucrânia. Macron afirmou que o imperialismo atual não é europeu nem ocidental, mas assume a forma de uma invasão territorial, baseada em uma guerra híbrida e globalizada, que usa o preço da energia, segurança alimentar, segurança nuclear, acesso à informação e movimentos populares como armas de divisão e destruição. O presidente francês também criticou países que se dizem neutros diante do conflito, afirmando que eles estão sendo cúmplices desse imperialismo.
"""
        )
        
        let story4 = Story(usedInIntroduction: false,
                           headline: "Membros da ultradireita alemã são acusados de apoiar Putin",
                           storyText:
"""
Políticos do partido de ultradireita Alternativa para a Alemanha, a AfD, que estão em visita à Rússia foram acusados de apoiar Vladimir Putin. Eles também planejam viajar para áreas no leste da Ucrânia ocupadas pelos russos. Os cinco políticos do partido disseram que o objetivo da viagem é ver com os próprios olhos a situação humanitária no local. A liderança do partido disse que o grupo não viaja em nome da legenda e que não apoia a visita. Em um comunicado no Facebook e no Telegram, um dos membros da AfD que participa da viagem postou um broche mostrando uma bandeira alemã e uma russa entrelaçadas. O grupo acusa a cobertura pela mídia alemã de abre aspas "cobertura altamente unilateral e incompleta sobre a situação humanitária das pessoas na região de Donbass".
""")
        
        let story5 = Story(usedInIntroduction: true,
                           headline: "STF decide limitar decretos de armas de Bolsonaro",
                           storyText:
"""
O Supremo Tribunal Federal decidiu nesta terça-feira manter a decisão do ministro Edson Fachin que restringiu os efeitos de uma série de decretos do president Jair Bolsonaro para flexibilizar o porte e a posse de armas, além da compra de munição. Dos ONZE ministros, apenas DOIS votaram contra a restrição: Nunes Marques e André Mendonça, ambos indicados por Bolsoanro ao STF. Pela decisão, a limitação da quantidade de munição deve ser garantida apenas na quantidade necessária para a segurança dos cidadãos. Além disso, o Poder Executivo não pode criar novas situações de necessidade que não estejam previstas em lei e a compra de armas de uso restrito só pode ser autorizada para segurança pública ou defesa nacional - e não com base no interesse pessoal do cidadão, argumenta a decisão.
"""
        )
        
        // assemble all stories
        let stories = [story1, story2, story3, story4, story5]
        
        // prepare storage of processed stories
        var processedStories = [Story]()
        
        // go through each story
        for story in stories {
            
            // convert '.' to '\n
            let storyText = story.storyText
            let splitStoryText = storyText.components(separatedBy: ".")
            let trimmedSplitStoryText = splitStoryText.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            let storyTextWithNewLines = trimmedSplitStoryText.joined(separator: ".\n\n")
            
            // create a new story by copying the original story
            var processedStory = story
            
            // replace original text with new text
            processedStory.storyText = storyTextWithNewLines
            
            // append to new list
            processedStories.append(processedStory)
        }
        
        
        let episode = Episode(welcomeText: "Olá, hoje é quarta-feira, vinte e um de setembro de dois mil e vinte e dois. Eu sou {speakerName} e esse é o boletim de notícias da DW. Confira nesta edição:",
                              stories: processedStories,
                              epilogue: "Mais notícias você ouve no fim da tarde, na segunda edição do boletim da DW.",
                              timeSlot: "September 21th am"
        )
        
        return episode
    }
}
