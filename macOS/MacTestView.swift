//
//  MacTestView.swift
//  Podcast Creator (macOS)
//
//  Created by Andy Giefer on 20.02.23.
//

import SwiftUI

struct MacTestView: View {
    var body: some View {
        NavigationSplitView {
            Text("Sidebar")
        } content: {
            Text("Content")
        } detail: {
            Text("Detail")
        }
        .navigationSplitViewStyle(.prominentDetail)
    }
}



struct MacTestView_Previews: PreviewProvider {
    static var previews: some View {
        MacTestView()
    }
}
