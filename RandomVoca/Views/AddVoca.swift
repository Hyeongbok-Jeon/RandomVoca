//
//  AddVoca.swift
//  RandomVoca
//
//  Created by Hyeongbok Jeon on 9/9/24.
//

import SwiftUI

struct AddVoca: View {
    @State private var word: String = ""
    @State private var pronunciation: String = ""
    @State private var meaning: String = ""
    
    var body: some View {
        VStack {
             TextField("Enter English word", text: $word)
                 .padding()
                 .textFieldStyle(RoundedBorderTextFieldStyle())
             
             Button("Fetch Word Info") {
//                 fetchWordInfo()
             }
             .padding()
             
             if !pronunciation.isEmpty {
                 Text("Pronunciation: \(pronunciation)")
                     .padding()
             }
             
             if !meaning.isEmpty {
                 Text("Meaning: \(meaning)")
                     .padding()
             }
         }
         .padding()
    }
}

#Preview {
    AddVoca()
}
