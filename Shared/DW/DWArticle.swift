//
//  DWArticle.swift
//  Drag DW Article
//
//  Created by Andy Giefer on 22.03.23.
//

import Foundation
import SwiftUI

struct DWArticle: Codable {
    var name: String
    var teaser: String
    var categoryName: String
    var text: String
    var body: [DWArticleBodyElement]
    
    var paragraphs: [DWParagraph] {
        
        var result = [DWParagraph]()
        
        for element in body {
            if element.content.type == "Paragraph" {
                if let text = element.content.text {
                    
                    // does this paragraph represent a headline?
                    var paragraphType: DWParagraph.ParagraphType = .bodyText // default
                    if let _ = text.firstMatch(of: /<strong>.+?<\/strong>/) {
                        paragraphType = .headline
                    }

                    
                    // eleminate HTML tags
                    let strippedText = text.replacing(/<.+?>/, with: "")
                    if strippedText.count > 0 {
                        
                        // create DW Paragraph
                        let paragraph = DWParagraph(type: paragraphType, text: strippedText)
                        
                        result.append(paragraph)
                    }
                }
            }
        }
        
        return result
    }
    
    var formattedText: String {
        
        // start with teaser
        var formattedText: String = self.teaser + "\n\n"
        
        // add paragraphs
        for paragraph in paragraphs {
            formattedText += "\(paragraph.text)\n\n"
        }
        
        return formattedText
    }
}

struct DWArticleBodyElementContent: Codable {
    var type: String
    var text: String?
}

struct DWArticleBodyElement: Codable {
    var content: DWArticleBodyElementContent
}

struct DWParagraph {
    
    enum ParagraphType {
        case headline, bodyText
    }
    
    var type: ParagraphType
    var text: String
}

extension DWArticle {
    
    static let mockup = DWArticle(name: "How Ukraine has maintained its energy supply despite the war", teaser: "Ukraine\'s electricity supply has not collapsed despite Russian attacks on energy infrastructure. Energy supplier Ukrenergo says a mild winter, imports from the EU and more nuclear power have helped.", categoryName: "Europe", text: "This winter has put the Ukrainian energy system to the test. Since the start of the season, the Russian army has carried out 15 massive rocket attacks and 18 drone attacks on energy facilities in Ukraine. The attacks have aimed to destabilize the country\'s energy system and put the population at the mercy of the dark and cold. The Energy Ministry in Kyiv told DW that more than 50% of Ukraine\'s energy infrastructure was damaged, affecting both electricity generation and conveyance. It said the most significant damage was done to heating facilities, with every single cogeneration plant hit. \"All the big heat and hydropower plants were damaged by Russian fire,\" Volodymyr Kudrytsky, the director of the state-run Ukrainian energy supplier Ukrenergo, said. Almost all major substations had been attacked at least three to four times, he said. \"We have objects that were hit six times, or some even 20 times,\" he added. But the electricity supply has been maintained, he said. According to Kudrytsky, there have been no more outages since mid-February and the system has been working without any restrictions. Fast repairs Several factors help explain the resilience of the Ukrainian grid. According to Ukrenergo, damaged power lines were quickly repaired, often at the risk of expert workers\' lives. But it says the protection of Ukrainian airspace by air defense systems was also of great importance. In addition, the state energy supplier worked together with grid operators to develop new methods for reacting to attacks by Russian rockets and drones. \"One method is to take the load off the energy system in the period before the attacks, thus maintaining its integrity,\" Volodymyr Omelchenko, the director for energy programs at the Rasumkov research center in Kyiv, told DW. This unloading — stopping the operation of individual block units at a power station ahead of possible rocket attacks — makes it possible to minimize the damage to the energy system if they are destroyed, thus allowing the faster restoration of lost energy. The Energy Ministry also mentioned the existence of several technical methods that facilitate the stabilization of the situation but declined to give details. \"These methods are, let us say, not traditional technical solutions according to established standards, but they work, and thanks to them everything keeps going,\" Ukrainian Energy Minister Herman Haluchenko told DW. Nuclear production and imports In addition, repairs on a block at Ukraine\'s Rivne nuclear power plant have been finished. The second block of this plant, which operated at half-capacity in 2022, is also now at full power. This means that all nine available nuclear blocks are operating, which has compensated for shortfalls from the Zaporizhzhia Nuclear Power Station, currently occupied by Russian troops. There has also been assistance from ENTSO-E, the European Network of Transmission System Operators for Electricity. Thanks to a continuous technical current flow, the Ukrainian energy system has remained in equilibrium, Ukrenergo\'s Volodymyr Kudrytsky explained. This synchronization allowed Ukrenergo to prevent frequent larger-scale blackouts during the attacks. Electricity imports from EU countries in January and early February of this year also guaranteed the supply to Ukrainian industry. The weather did its bit to help, too. \"Nature is on our side. This winter, we have unusually large amounts of meltwater in the Dnipro, Sozh, Dnesna and Pripyat rivers. Something like that happens only every 20 to 30 years. That helps us a lot, and the hydroelectricity plants are supplying a lot of power now,\" Ihor Syrota, CEO of the Ukrainian hydropower generating company Ukrhydroenergo, told DW. Exchange with South Korea Ukrainian energy suppliers are meanwhile looking for more ways to secure those facilities and networks most at risk. For example, Ukrainian engineers are gathering information on how to move energy facilities as far as possible beneath the ground to protect them from Russian rockets. \"I traveled to South Korea, because they also have such a \'nice\' neighbor,\" CEO Syrota from Ukrhydroenergo said. \"There, we saw how equipment and transformers are hidden under the ground or in rocks. We will also adopt solutions like these,\" he said. This article was translated from German.", body: [DWArticleBodyElement(content: DWArticleBodyElementContent(type: "Paragraph", text: Optional("This winter has put the Ukrainian <span class=\"editable placeholder\" data-id=\"62914338\" data-type=\"AUTO_TOPIC\" title=\"Automatische Themenseite\">energy</span> system to the test. Since the start of the season, the Russian army has carried out 15 massive rocket attacks and 18 drone attacks on energy facilities in <span class=\"editable placeholder\" data-id=\"17295382\" data-type=\"AUTO_TOPIC\" title=\"Automatische Themenseite\">Ukraine.</span> The attacks have aimed to destabilize the country\'s energy system and put the population at the mercy of the dark and cold."))), DWArticleBodyElement(content: DWArticleBodyElementContent(type: "Paragraph", text: Optional("The Energy Ministry in Kyiv told DW that more than 50% of Ukraine\'s energy infrastructure was damaged, affecting both electricity generation and conveyance. It said the most significant damage was done to heating facilities, with every single cogeneration plant hit."))), DWArticleBodyElement(content: DWArticleBodyElementContent(type: "Paragraph", text: Optional("\"All the big heat and <span class=\"editable placeholder\" data-id=\"19044836\" data-type=\"AUTO_TOPIC\" title=\"Automatische Themenseite\">hydropower</span> plants were damaged by Russian fire,\" Volodymyr Kudrytsky, the director of the state-run Ukrainian energy supplier Ukrenergo, said."))), DWArticleBodyElement(content: DWArticleBodyElementContent(type: "Paragraph", text: Optional("Almost all major substations had been attacked at least three to four times, he said. \"We have objects that were hit six times, or some even 20 times,\" he added."))), DWArticleBodyElement(content: DWArticleBodyElementContent(type: "Paragraph", text: Optional("But the electricity supply has been maintained, he said. According to Kudrytsky, there have been no more outages since mid-February and the system has been working without any restrictions."))), DWArticleBodyElement(content: DWArticleBodyElementContent(type: "Image", text: nil)), DWArticleBodyElement(content: DWArticleBodyElementContent(type: "Paragraph", text: Optional("<strong>Fast repairs</strong>"))), DWArticleBodyElement(content: DWArticleBodyElementContent(type: "Paragraph", text: Optional("Several factors help explain the resilience of the Ukrainian grid."))), DWArticleBodyElement(content: DWArticleBodyElementContent(type: "Paragraph", text: Optional("According to Ukrenergo, damaged power lines were quickly repaired, often at the risk of expert workers\' lives."))), DWArticleBodyElement(content: DWArticleBodyElementContent(type: "Paragraph", text: Optional("But it says the protection of Ukrainian airspace by air defense systems was also of great importance. In addition, the state energy supplier worked together with grid operators to develop new methods for reacting to attacks by Russian rockets and drones."))), DWArticleBodyElement(content: DWArticleBodyElementContent(type: "Paragraph", text: Optional("\"One method is to take the load off the energy system in the period before the attacks, thus maintaining its integrity,\" Volodymyr Omelchenko, the director for energy programs at the Rasumkov research center in Kyiv, told DW."))), DWArticleBodyElement(content: DWArticleBodyElementContent(type: "Paragraph", text: Optional("This unloading — stopping the operation of individual block units at a power station ahead of possible rocket attacks — makes it possible to minimize the damage to the energy system if they are destroyed, thus allowing the faster restoration of lost energy."))), DWArticleBodyElement(content: DWArticleBodyElementContent(type: "Paragraph", text: Optional("The Energy Ministry also mentioned the existence of several technical methods that facilitate the stabilization of the situation but declined to give details."))), DWArticleBodyElement(content: DWArticleBodyElementContent(type: "Paragraph", text: Optional("\"These methods are, let us say, not traditional technical solutions according to established standards, but they work, and thanks to them everything keeps going,\" Ukrainian Energy Minister Herman Haluchenko told DW."))), DWArticleBodyElement(content: DWArticleBodyElementContent(type: "Paragraph", text: Optional("<strong>Nuclear production and imports</strong>"))), DWArticleBodyElement(content: DWArticleBodyElementContent(type: "Paragraph", text: Optional("In addition, repairs on a block at Ukraine\'s Rivne nuclear power plant have been finished. The second block of this plant, which operated at half-capacity in 2022, is also now at full power. This means that all nine available nuclear blocks are operating, which has compensated for shortfalls from the <a href=\"https://api.dw.com/api/detail/article/63686362\" rel=\"ArticleRef\">Zaporizhzhia Nuclear Power Station,</a> currently occupied by Russian troops."))), DWArticleBodyElement(content: DWArticleBodyElementContent(type: "Image", text: nil)), DWArticleBodyElement(content: DWArticleBodyElementContent(type: "Paragraph", text: Optional("There has also been assistance from ENTSO-E, the European Network of Transmission System Operators for Electricity. Thanks to a continuous technical current flow, the Ukrainian energy system has remained in equilibrium, Ukrenergo\'s Volodymyr Kudrytsky explained. This synchronization allowed Ukrenergo to prevent frequent larger-scale blackouts during the attacks."))), DWArticleBodyElement(content: DWArticleBodyElementContent(type: "Paragraph", text: Optional("Electricity imports from EU countries in January and early February of this year also guaranteed the supply to Ukrainian industry."))), DWArticleBodyElement(content: DWArticleBodyElementContent(type: "Paragraph", text: Optional("The weather did its bit to help, too. \"Nature is on our side. This winter, we have unusually large amounts of meltwater in the Dnipro, Sozh, Dnesna and Pripyat rivers. Something like that happens only every 20 to 30 years. That helps us a lot, and the hydroelectricity plants are supplying a lot of power now,\" Ihor Syrota, CEO of the Ukrainian hydropower generating company Ukrhydroenergo, told DW."))), DWArticleBodyElement(content: DWArticleBodyElementContent(type: "Video", text: nil)), DWArticleBodyElement(content: DWArticleBodyElementContent(type: "Paragraph", text: Optional("<strong>Exchange with South Korea</strong>"))), DWArticleBodyElement(content: DWArticleBodyElementContent(type: "Paragraph", text: Optional("Ukrainian energy suppliers are meanwhile looking for more ways to secure those facilities and networks most at risk. For example, Ukrainian engineers are gathering information on how to move energy facilities as far as possible beneath the ground to protect them from Russian rockets."))), DWArticleBodyElement(content: DWArticleBodyElementContent(type: "Paragraph", text: Optional("\"I traveled to South Korea, because they also have such a \'nice\' neighbor,\" CEO Syrota from Ukrhydroenergo said. "))), DWArticleBodyElement(content: DWArticleBodyElementContent(type: "Paragraph", text: Optional("\"There, we saw how equipment and transformers are hidden under the ground or in rocks. We will also adopt solutions like these,\" he said."))), DWArticleBodyElement(content: DWArticleBodyElementContent(type: "Paragraph", text: Optional("<em>This article was translated from German.</em>")))])
}
