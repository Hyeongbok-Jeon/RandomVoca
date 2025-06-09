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
    .onChange(of: selectedTab) { oldTab, newTab in
      if newTab == 0 {
        modelData.fetchGroups()
      }
    }
    
//    BannerAdView()
//      .frame(height: 50)
  }
}

#Preview {
  ContentView()
    .environmentObject(ModelData())
}
