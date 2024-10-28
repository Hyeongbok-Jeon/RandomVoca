//
//  ContentView.swift
//  RandomVoca
//
//  Created by Hyeongbok Jeon on 9/9/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selection: Tab = .featured
    
    enum Tab {
        case featured
        case list
    }
    
    var body: some View {
        VocaList()
    }
}

#Preview {
    ContentView()
        .environmentObject(ModelData())
}
