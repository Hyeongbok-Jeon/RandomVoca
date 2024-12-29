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
//        if isActive {
//            VocaList()
//        } else {
//            // 스플래시 화면
//            VStack {
//                Image("AppIcon") // 앱 아이콘 이미지
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 150, height: 150) // 아이콘 크기 조정
//                    .padding(.bottom, 20)
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(Color.black) // 배경색
//            .ignoresSafeArea()
//            .onAppear {
//                // 몇 초 후에 메인 화면으로 전환
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                    withAnimation {
//                        isActive = true
//                    }
//                }
//            }
//        }
        VocaList()
    }
}

#Preview {
    ContentView()
        .environmentObject(ModelData())
}
