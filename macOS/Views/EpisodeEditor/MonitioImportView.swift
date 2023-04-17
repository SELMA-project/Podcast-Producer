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
    
    @AppStorage("numberOfImportedStorylines") var numberOfImportedStorylines: Int = 5
    @AppStorage("numberOfImportedTeasers") var numberOfImportedTeasers: Int = 4
    @AppStorage("numberOfImportedDocuments") var numberOfImportedDocuments: Int = 3
    
    enum ImportMethod {
        case summary, teasers, documents
        
        var description: String {
            switch self {
            case .summary:
                return "Import storyline summary"
            case .teasers:
                return "Import document teasers"
            case .documents:
                return "Import entire documents"
            }
        }
    }
    
    @State var importMethod: ImportMethod = .summary
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                
                Text("MONITIO Importer").font(.title)
                
                ZStack {
                    Text(monitioViewModel.statusMessage)
                    Text(" ") // empty string to reserve space for status message
                }
                
                HStack {
                    Stepper("Number of storylines to fetch:", value: $numberOfImportedStorylines)
                    Text("\(numberOfImportedStorylines)")
                    
                    Spacer()
                    
                    Button("Fetch") {
                        print("Fetching Monitio clusters.")
                        monitioViewModel.fetchClusters()
                    }
                }
                
                ScrollView(.vertical) {
                    ForEach(monitioViewModel.monitioClusters) {cluster in
                        ClusterLineView(cluster: cluster)
                    }
                }
                
                Text("How should a selected storyline be imported?")
                    .padding(.top, 8)
                
                Picker("", selection: $importMethod) {
                    
                    // first option: storyline summary
                    Text(ImportMethod.summary.description).tag(ImportMethod.summary)
                    
                    // second option: document teasers
                    HStack {
                        Stepper("Import", value: $numberOfImportedTeasers)
                        Text("\(numberOfImportedTeasers) document teasers")
                    }.tag(ImportMethod.teasers)
                    
                    // third option: entire documents
                    HStack {
                        Stepper("Import", value: $numberOfImportedDocuments)
                        Text("\(numberOfImportedDocuments) documents")
                    }.tag(ImportMethod.documents)
                    
                }.pickerStyle(.radioGroup)
                
                Spacer()
                
                HStack {
                    
                    Button("Cancel") {
                        dismissAction()
                    }
                    
                    Spacer()
                    

                    
                    Button("Import") {
                        print("Importing Monitio clusters.")
                    }
                    
                }
            }
            
            Spacer()
            
 
        }.frame(width: 400, height: 400)
    }
}

struct MonitioImportView_Previews: PreviewProvider {
    static var previews: some View {
        MonitioImportView()
            .padding()
    }
}


struct ClusterLineView:  View {
    
    var cluster: MonitioCluster
    @State var isOn: Bool = true
    
    var body: some View {
        HStack {
            Toggle(isOn: $isOn) {
                VStack(alignment: .leading) {
                    Text(cluster.title)
                    Text("\(cluster.selectionFrequency) documents. Languages: \(cluster.availableLanguages.joined(separator: ", "))")
                        .font(.caption)
                }
            }
            Spacer()
            
        }
    }
}
