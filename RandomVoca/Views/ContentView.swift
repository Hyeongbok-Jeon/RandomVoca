//
//  ContentView.swift
//  RandomVoca
//
//  Created by Hyeongbok Jeon on 9/9/24.
//

import SwiftUI

struct ContentView: View {
  @StateObject private var keyboard = KeyboardResponder()
  
  var body: some View {
    TabView {
      VocaGroupList()
        .tabItem {
          Label("단어 그룹", systemImage: "books.vertical.fill")
        }
      
      Setting()
        .tabItem {
          Label("설정", systemImage: "gearshape.fill")
        }
    }

//    if !keyboard.isKeyboardVisible {
//      BannerAdView()
//        .frame(height: 50)
//        .transition(.move(edge: .bottom))
//    }
  }
}

#Preview {
  ContentView()
    .environmentObject(ModelData())
}
