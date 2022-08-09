//
//  EpisodeData.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 09.08.22.
//

import Foundation

extension Episode {
    static func episode0() -> Episode {
        
        let story1 = Story(usedInIntroduction: true,
                           headline: "Pobreza atingiu em 2021 quase um quarto dos moradores de regiões metropolitanas",
                           storyText:
"""
A pobreza alcançou quase 20 milhões de moradores das regiões metropolitanas do Brasil em 2021 – o equivalente a quase 24% dos habitantes dessas cidades. O percentual de 2021 é o maior desde o início da série histórica, iniciada em 2012.
                           
O aumento da pobreza foi influenciado pela redução do valor do auxílio emergencial instituído durante a pandemia, e a alta da inflação e do desemprego no ano passado. O dado está no 9º Boletim Desigualdade nas Metrópoles.

Em um outro estudo, o Instituto de Pesquisa Econômica Aplicada – o IPEA – projeta que a pobreza deve diminuir neste ano devido ao programa Auxílio Brasil.

Em 2012, o número de moradores de metrópoles em situação de pobreza era de pouco menos de 13 milhões de pessoas – cerca de 16% da população – quase oito pontos percentuais a menos do que em 2021.

As maiores taxas de pobreza foram registradas nas regiões metropolitanas do Norte e Nordeste. Quase 40% da população brasileira vivem em alguma das regiões metropolitanas do país.
"""
)
        
        let story2 = Story(usedInIntroduction: true,
                           headline: "TSE exclui coronel do Exército de grupo de fiscalização eleitoral por divulgar fake news",
                           storyText:
"""
O Tribunal Superior Eleitoral decidiu excluir o coronel do Exército Ricardo Sant'Anna do grupo de fiscalização do processo eleitoral. Ele era um dos nove militares que fazem parte da fiscalização das eleições.

Segundo comunicado, o coronel foi excluído por ter divulgado fake news sobre as urnas eletrônicas nas redes sociais. Sant'Anna publicou um vídeo no qual ele comparava o voto à compra de um bilhete de loteria. O perfil do militar foi apagado das redes sociais.

O ofício foi assinado pelo presidente do TSE, Luiz Edson Fachin, e pelo vice-presidente do tribunal, Alexandre de Moraes, que assume o comando do TSE no próximo dia 16 de agosto.

Sant'Anna estava no grupo de nove militares que começou a analisar o código-fonte das urnas eletrônicas no início do mês. Esta inspeção deve ser concluída no próximo dia 12.

A consulta ao código-fonte estava disponível desde outubro de 2021 – e foi o próprio TSE que convidou, na época, as Forças Armadas para participarem da fiscalização das eleições. Desde então, sob ordem do presidente Jair Bolsonaro, os militares vêm semeando dúvidas sobre as urnas eletrônicas e apresentaram mais de 80 questionamentos ao TSE, além de uma série de propostas de mudanças para o pleito presidencial deste ano.
"""
        )
        
        let story3 = Story(usedInIntroduction: true,
                           headline: "EUA travam venda de mísseis ao Brasil devido a preocupações com Bolsonaro",
                           storyText:
"""
O Estados Unidos travaram a venda de mísseis ao Brasil, segundo relato publicado nesta segunda-feira pela agência de notícias Reuters. Segundo fontes ouvidas pela Reuters, os americanos congelaram a venda de mísseis antitanque devido a preocupações de parlamentares americanos com a postura de Jair Bolsonaro, especificamente em relação aos seus ataques contra a urna eletrônica.

O pedido de compra de cerca de 220 mísseis Javelin no valor de cerca de 100 milhões de dólares foi feito ainda no governo de Donald Trump. O Departamento de Estado americano aprovou a proposta brasileira no final do ano passado. Porém, desde então, o acordo está emperrado num limbo processual travado por parlamentares democratas.

A demanda por Javelins disparou desde o início da guerra da Ucrânia. Portanto, mesmo que o acordo seja aprovado, pode levar anos para o Brasil receber os mísseis. E caso o pedido seja negado, o Brasil tem outras opções, entre elas a versão chinesa e mais barata do Javelin – o HJ-12.
"""
        )
        
        let story4 = Story(usedInIntroduction: false,
                           headline: "Social-democratas decidem não expulsar Schröder do partido, apesar dos laços com Putin",
                           storyText:
"""
O Partido Social-Democrata da Alemanha decidiu não expulsar de seus quadros o ex-chanceler federal alemão Gerhard Schröder. A decisão foi tomada por um comitê de arbitragem e pode ser apelada em até duas semanas.

Desde o início da guerra na Ucrânia em fevereiro cresceram as críticas entre os sociais-democratas contra Schröder por seus laços estreitos com o Kremlin e o setor de energia da Rússia – muitos partidários pediram o término de sua filiação – o SPD recebeu ao menos 17 moções para a sua expulsão.

Schröder foi chefe de governo da Alemanha entre 1998 e 2005. Após seus mandatos, decidiu se aproximar ainda mais de seu amigo próximo, o presidente russo Vladimir Putin.

Schröder faz parte do comitê de acionistas da companhia do gasoduto Nord Stream e é o presidente administrativo da sociedade anônima Nord Stream 2. Além disso, foi até pouco tempo presidente do conselho de supervisão da estatal russa de energia Rosneft.

Embora tenha dito que a Rússia cometeu um erro com sua guerra na Ucrânia, Schröder se recusa a condenar Putin – inclusive disse recentemente que Putin está aberto a negociações.
""")
        
        let story5 = Story(usedInIntroduction: false,
                           headline: "Israelenses e palestinos acertam cessar-fogo após quase três dias de conflitos",
                           storyText:
"""
Após quase três dias de conflitos na Faixa de Gaza, entrou em vigor um cessar-fogo entre Israel e militantes palestinos. O conflito mais recente foi desencadeado por bombardeios israelenses na Faixa de Gaza – aos quais o grupo palestino Jihad Islâmica respondeu com foguetes. A troca de agressões deixou mais de 40 mortos e mais de 310 pessoas feridas.

O acordo de cessar-fogo foi fechado ainda no domingo e foi mediado pelo Egito. Nesta segunda-feira, o Exército de Israel afirmou que não foram disparados novos foguetes a partir de Gaza e que militares israelenses não atacaram mais nenhum alvo no enclave palestino.

A Jihad Islâmica Palestina é a maior força militar na Faixa de Gaza depois do Hamas. A Jihad Islâmica é apoiada pelo Irã e classificada como uma organização terrorista pelos Estados Unidos e pela União Europeia. No sábado, Israel afirmou ter matado o principal comandante da Jihad Islâmica em um ataque aéreo.

O conflito dos últimos três dias foi o pior entre israelenses e militantes palestinos desde que Israel e o Hamas travaram 11 dias de confrontos em maio do ano passado.
"""
        )
        
        let stories = [story1, story2, story3, story4, story5]
        
        let episode = Episode(cmsTitle: "Boletim de Notícias (08/08/22) – Segunda edição",
                              cmsTeaser: "A pobreza aumentou em 2021 e atingiu quase 24% da população das regiões metropolitanas do Brasil. O percentual é o maior desde o início da série histórica, em 2012. Ouça esse e outros destaques desta segunda-feira, na segunda edição do Boletim de Notícias da DW Brasil.",
                              welcomeText: "Olá, hoje é segunda-feira, 08 de agosto de 2022. Eu sou Philip Verminnen e esta é a segunda edição do dia do Boletim de Notícias da DW Brasil.",
                              headlineIntroduction: "Confira nesta edição:",
                              stories: stories,
                              epilogue: "Mais notícias você encontra no nosso site. Acesse dw.com/brasil")
        
        return episode
    }
}
