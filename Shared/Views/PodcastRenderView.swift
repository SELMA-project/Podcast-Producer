//
//  PodcastRenderView.swift
//  Podcast Creator
//
//  Created by Andy Giefer on 10.01.23.
//

import SwiftUI

struct PodcastRenderView: View {
    
    @Environment(\.dismiss) var dismissAction
    
    var body: some View {
        
        NavigationStack {
            VStack(alignment: .leading) {
             
                Text("Press the *Render* button to start rendering the podcast.")
                    .padding(.bottom, 4)
                
                Text("This will convert the text in each section into synthesized speech while adding additional audio elements.")
                    .font(.caption)

                Button {
                    print("Rendering Podcast...")
                } label: {
                    Text("Render")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding([.top, .bottom])
                


                
                
                ProgressView("Rendering...", value: 10, total: 100)
                
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismissAction()
                    }
                }
            }

            .navigationTitle("Create Podcast")
        }
    }
}

struct PodcastRenderView_Previews: PreviewProvider {
    static var previews: some View {
        PodcastRenderView()
    }
}
