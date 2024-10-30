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
    @State private var showPopup: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                Text(String(format: "%.2f", Double(timerMilliseconds) / 100))
                    .font(.largeTitle)
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
                                modelData.words[currentIndex].knowTime = Double(timerMilliseconds) / 100
                                modelData.words = modelData.words
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
            
            if showPopup {
                Color.black.opacity(0.4) // 어두운 반투명 배경
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("단어를 모두 보셨습니다!")
                        .font(.title)
                        .padding(.top, 20)
                    
                    Text("다시 시작합니다.")
                        .padding(.horizontal)
                    
                    Button("확인") {
                        showPopup = false // 팝업 닫기
                        showRandomWord()   // 새로운 단어 보여주기
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .frame(width: 300, height: 400)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 10)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.3), lineWidth: 1))
            }
        }
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
            timer?.invalidate()
            shownWords.removeAll() // 모든 단어를 보여줬다면, 기록 초기화
//            showRandomWord() // 다시 처음부터 시작
            showPopup = true
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
    var modelData = ModelData()
    if modelData.words.isEmpty {
        modelData.words = modelData.getSampleWords()
    }
    return Play()
        .environmentObject(modelData)
}
