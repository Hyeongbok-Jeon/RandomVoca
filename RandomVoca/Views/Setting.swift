//
//  Setting.swift
//  RandomVoca
//
//  Created by Hyeongbok Jeon on 5/11/25.
//

import SwiftUI

struct Setting: View {
  var body: some View {
    NavigationStack {
      Form {
        Section(header: Text("계정")) {
          Button("계정 연결") {
            // 계정 연결 로직
          }
        }
        Section {
          Text("앱 버전 1.0.0")
            .foregroundColor(.gray)
        }
      }
      .navigationTitle("설정")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

#Preview {
    Setting()
}
