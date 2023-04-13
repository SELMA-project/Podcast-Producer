//
//  MonitioImportView.swift
//  Podcast Creator (macOS)
//
//  Created by Andy Giefer on 13.04.23.
//

import SwiftUI

struct MonitioImportView: View {
    
    @StateObject var monitioViewModel = MonitioViewModel()
    @Environment(\.dismiss) var dismissAction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                
                Text("MONITIO Importer").font(.title)
                Text(monitioViewModel.statusMessage)
                
                Spacer()
                
                HStack {
                    
                    Button("Cancel") {
                        dismissAction()
                    }
                    
                    Spacer()
                    
                    Button("Fetch") {
                        print("Fetching Monitio clusters.")
                        monitioViewModel.fetchClusters()
                    }
                    
                    Button("Import") {
                        print("Importing Monitio clusters.")
                    }
                    
                }
            }
            
            Spacer()
            
 
        }.frame(width: 400, height: 200)
    }
}

struct MonitioImportView_Previews: PreviewProvider {
    static var previews: some View {
        MonitioImportView()
            .padding()
    }
}
