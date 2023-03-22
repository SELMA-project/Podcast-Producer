//
//  DWArticleView.swift
//  Drag DW Article
//
//  Created by Andy Giefer on 22.03.23.
//

import SwiftUI

struct DWArticleView: View {
    
    var dwArticle: DWArticle
    
    var body: some View {
        
        
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                
                // title
                Text(dwArticle.name)
                    .font(.title)
                    .padding()
                
                // teaser
                Text(dwArticle.teaser)
                    .font(.title3)
                    .padding([.leading, .bottom, .trailing])
                
                // text and headlines
                ForEach(0..<dwArticle.paragraphs.count, id: \.self) {index in
                    Text(dwArticle.paragraphs[index].text)
                        .font(dwArticle.paragraphs[index].type == .headline ? .title2 : .body)
                        .padding([.leading, .bottom, .trailing])
                }
            }
        }.padding(32)
        
        
        
    }
}

struct DWArticleView_Previews: PreviewProvider {
    static var previews: some View {
        DWArticleView(dwArticle: DWArticle.mockup)
    }
}
