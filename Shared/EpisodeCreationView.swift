//
//  EpisodeCreationView.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 18.10.22.
//

import SwiftUI



struct EpisodeCreationView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button("Press to dismiss") {
            dismiss()
        }
        .font(.title)
        .padding()
    }
}

struct EpisodeCreationView_Previews: PreviewProvider {
    static var previews: some View {
        EpisodeCreationView()
    }
}
