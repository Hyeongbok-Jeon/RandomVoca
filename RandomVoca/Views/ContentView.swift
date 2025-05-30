//
//  ContentView.swift
//  RandomVoca
//
//  Created by Hyeongbok Jeon on 9/9/24.
//

import SwiftUI

struct ContentView: View {
  @StateObject private var keyboard = KeyboardResponder()
  @State private var selectedTab = 0
  @EnvironmentObject var modelData: ModelData
  
  var body: some View {
    TabView(selection: $selectedTab) {
      VocaGroupList()
        .tabItem {
          Label("단어 그룹", systemImage: "books.vertical.fill")
        }
        .tag(0)
      
      Setting()
        .tabItem {
          Label("설정", systemImage: "gearshape.fill")
        }
        .tag(1)
    }
    .onChange(of: selectedTab) { newTab in
      if newTab == 0 {
        print("📲 단어 그룹 탭 선택됨 → 그룹 다시 불러오기")
        modelData.fetchGroups()
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
