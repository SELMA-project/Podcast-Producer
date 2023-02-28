//
//  MacSplitView.swift
//  Podcast Creator (macOS)
//
//  Created by Andy Giefer on 27.02.23.
//

import SwiftUI

struct MacSplitView: View {
    var body: some View {
        GeometryReader{geometry in
            HSplitView {
                Rectangle().foregroundColor(.red)
                    .frame(minWidth:200, idealWidth: 200, maxWidth: .infinity, minHeight: geometry.size.height)
    
                
                Text("Right").frame(minWidth:200, idealWidth: 200, maxWidth: .infinity)
            }.frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct MacSplitView_Previews: PreviewProvider {
    static var previews: some View {
        MacSplitView()
    }
}
