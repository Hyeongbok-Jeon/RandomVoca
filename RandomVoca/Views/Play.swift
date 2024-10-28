//
//  Play.swift
//  RandomVoca
//
//  Created by Hyeongbok Jeon on 9/11/24.
//

import SwiftUI

struct Play: View {
    @EnvironmentObject var modelData: ModelData
    
    @State private var currentIndex: Int = 0
    @State private var displayWordName: String = ""
    @State private var displayWordMeaning: String = ""
    @State private var showMeaning: Bool = false  // 뜻을 표시할지 여부를 관리하는 상태
    @State private var shownWords: [Word] = [] // 이미 보여준 단어를 추적하는 배열
    @State private var isReallyKnowWord: Bool = false
    @State private var timerMilliseconds: Int = 0 // 초 단위 타이머를 위한 상태 변수
    @State private var timer: Timer? // 타이머 객체 저장
    
    var body: some View {
        Spacer()
        
        Text(String(format: "%.2f", Double(timerMilliseconds) / 100))
            .font(.headline)
            .onAppear {
                startTimer()
            }
        
        Spacer()
        
        VStack {
            Text(displayWordName)
                .font(.largeTitle)
        }
        .onAppear {
            showRandomWord()
        }
        
        Spacer()
        
        RoundedRectangle(cornerRadius: 10)   // 둥근 모서리
            .stroke(Color.blue, lineWidth: 2) // 테두리 색과 두께 설정
            .frame(width: 200, height: 50)    // 사각형 크기 설정
            .overlay(
                // 뜻을 표시할지 여부에 따라 텍스트 또는 빈 공간을 표시
                showMeaning ? AnyView(Text(displayWordMeaning).foregroundColor(.black)) : AnyView(EmptyView())
            )
        
        Spacer()
        
        HStack {
            Spacer()
            
            if isReallyKnowWord {
                Button("사실 모르는 단어") {
                    showRandomWord()
                }
                
                Spacer()
                
                Button("아는 단어가 맞음") {
                    if currentIndex < modelData.words.count {
                        // 현재 단어의 isKnowWord 값을 true로 설정
                        modelData.words[currentIndex].isKnowWord = true
                    }
                    
                    showRandomWord()
                }
            } else {
                Button("모르는 단어") {
                    showRandomWord()
                }
                
                Spacer()
                
                Button("아는 단어") {
                    showMeaning = true
                    isReallyKnowWord = true
                    stopTimer()
                }
            }

            Spacer()
        }

        Spacer()
    }
    
    private func startTimer() {
        timer?.invalidate() // 기존 타이머가 있으면 무효화
        timerMilliseconds = 0 // 타이머 시간 리셋
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            timerMilliseconds += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate() // 타이머를 중지
        timer = nil // 타이머 변수를 nil로 설정
    }

    private func showRandomWord() {
        let availableWords = modelData.words.filter { !shownWords.contains($0) } // 아직 보여주지 않은 단어들만 선택

        guard !availableWords.isEmpty else {
            shownWords.removeAll() // 모든 단어를 보여줬다면, 기록 초기화
            showRandomWord() // 다시 처음부터 시작
            return
        }

        let randomWord = availableWords.randomElement()! // 아직 보여주지 않은 단어 중에서 랜덤 선택
        displayWordName = randomWord.name
        displayWordMeaning = randomWord.meaning
        currentIndex = modelData.words.firstIndex(of: randomWord) ?? 0
        shownWords.append(randomWord) // 선택된 단어를 기록
        startTimer()
        isReallyKnowWord = false
        showMeaning = false
     }
}

#Preview {
    Play()
        .environmentObject(ModelData())
}
