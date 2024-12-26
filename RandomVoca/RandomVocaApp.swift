//
//  RandomVocaApp.swift
//  RandomVoca
//
//  Created by Hyeongbok Jeon on 9/9/24
//

import SwiftUI

@main
struct RandomVocaApp: App {
    @StateObject private var modelData = ModelData()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(modelData)
                .preferredColorScheme(.dark)
        }
    }
}
