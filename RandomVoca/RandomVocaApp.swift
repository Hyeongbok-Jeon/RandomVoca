//
//  RandomVocaApp.swift
//  RandomVoca
//
//  Created by Hyeongbok Jeon on 9/9/24
//

import SwiftUI
import GoogleMobileAds

@main
struct RandomVocaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate  // ✅ AppDelegate 연결
    
    @StateObject private var modelData = ModelData()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(modelData)
                .preferredColorScheme(.dark)
        }
    }
}
