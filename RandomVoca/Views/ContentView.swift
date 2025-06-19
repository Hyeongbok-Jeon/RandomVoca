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
    ZStack {
      if isActive {
        MainTabView()
          .transition(.opacity)
      } else {
        LaunchView()
          .transition(.opacity)
      }
    }
    .onAppear {
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        withAnimation {
          isActive = true
        }
      }
    }
  }
}

// ✅ 런치 뷰는 완전 분리
struct LaunchView: View {
  var body: some View {
    ZStack {
      Image("LaunchImage")
        .resizable()
        .scaledToFit()
        .frame(width: 200, height: 200)
    }
  }
}

// ✅ 메인 탭 뷰도 완전 분리
struct MainTabView: View {
  @EnvironmentObject var modelData: ModelData
  @State private var selectedTab = 0

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
  }
}

#Preview {
  ContentView()
    .environmentObject(ModelData())
}

#Preview {
  ContentView()
    .environmentObject(ModelData())
}
