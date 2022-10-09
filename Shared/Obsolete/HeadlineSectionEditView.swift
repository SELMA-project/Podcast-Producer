////
////  HeadlineSectionEditView.swift
////  Podcast Producer
////
////  Created by Andy on 08.10.22.
////
//
//import SwiftUI
//
//struct HeadlineSectionEditView: View {
//    
//    var section: EpisodeSection
//    @State var name: String
//    
//    @EnvironmentObject var viewModel: EpisodeViewModel
//    
//    init(section: EpisodeSection) {
//        self.section = section
//        _name = State(initialValue: section.name)
//    }
//    
//    var body: some View {
//        
//        let nameBinding = Binding {
//             self.name
//         } set: { newValue in
//             self.name = newValue
//             
//             // update section
//             var updatedSection = section // copy
//             updatedSection.name = newValue
//             viewModel.updateEpisodeSection(updatedSection)
//         }
//        
//        Form {
//            Section("Name") {
//                TextField("Name", text: nameBinding)
//            }
//            Section("Configuration") {
//                Text("Use highights only")
//            }
//        }.navigationTitle("Section Editor")
//    }
//}
//
//struct HeadlineSectionEditView_Previews: PreviewProvider {
//    static var previews: some View {
//        let section = EpisodeSection(type: .standard, name: "Headlines")
//        HeadlineSectionEditView(section: section)
//    }
//}
