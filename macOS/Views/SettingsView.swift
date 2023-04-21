//
//  SettingsView.swift
//  Podcast Creator (macOS)
//
//  Created by Andy Giefer on 21.04.23.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage(Constants.userDefaultsElevenLabsAPIKeyName) var elevenLabsAPIKey = ""
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Text("Settings").font(.title)
            
            Form {
                TextField("ElevenLabs API Key:", text: $elevenLabsAPIKey)
            }
            
        
        }
        .padding()
        .frame(width: 500)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
