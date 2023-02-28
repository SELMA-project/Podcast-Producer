//
//  EpisodeEditorStoryView.swift
//  Podcast Creator (macOS)
//
//  Created by Andy Giefer on 28.02.23.
//

import SwiftUI

struct EpisodeEditorStoryView: View {
    
    var storyId: Story.StoryId?
    
    var contentView: some View {
        ZStack {
            if let storyId {
                Text("Title")
                    .font(.title3)
                Text("\(storyId.internalId)")
            } else {
                Text("No story was selected.")
            }
        }
    }
    
    var body: some View {
        GroupBox {
                        
            VStack {
                VStack {
                    HStack {
                        contentView
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
    }
}

struct EpisodeEditorStoryView_Previews: PreviewProvider {
    static var previews: some View {
        EpisodeEditorStoryView(storyId: nil)
    }
}
