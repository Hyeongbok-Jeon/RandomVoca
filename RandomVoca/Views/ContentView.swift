//
//  ContentView.swift
//  RandomVoca
//
//  Created by Hyeongbok Jeon on 9/9/24.
//

import SwiftUI

struct ContentView: View {
    @State private var isActive = false
    
    var body: some View {
        PlayV2()
    }
}

#Preview {
    ContentView()
        .environmentObject(ModelData())
}
