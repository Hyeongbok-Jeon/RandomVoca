//
//  Play.swift
//  RandomVoca
//
//  Created by Hyeongbok Jeon on 9/11/24.
//

import SwiftUI

struct Play: View {
    @EnvironmentObject var modelData: ModelData
    
    @Environment(\.presentationMode) var presentationMode // presentationMode 추가
    
    @State private var currentIndex: Int = 0
    @State private var displayWordName: String = ""
    @State private var displayWordMeaning: String = ""
    @State private var showMeaning: Bool = false  // 뜻을 표시할지 여부를 관리하는 상태
    @State private var shownWords: [Word] = [] // 이미 보여준 단어를 추적하는 배열
    @State private var isReallyKnowWord: Bool = false
    @State private var timerMilliseconds: Int = 0 // 초 단위 타이머를 위한 상태 변수
    @State private var timer: Timer? // 타이머 객체 저장
    @State private var showPopup: Bool = false
    @State private var countdown: Int = 3
    @State private var showCountdown: Bool = false
    
    var body: some View {
        ZStack {
            if showCountdown {
                Text("\(countdown)")
                    .font(.system(size: 100)) // 원하는 크기로 설정
                    .onAppear {
                        startCountdown()
                    }
            } else {
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
                            .font(.system(size: 80)) // 원하는 크기로 설정
                    }
                    .onAppear {
                        showRandomWord()
                    }
                    
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 10)   // 둥근 모서리
                        .stroke(lineWidth: 2) // 테두리 색과 두께 설정
                        .frame(width: 250, height: 100)    // 사각형 크기 설정
                        .overlay(
                            // 뜻을 표시할지 여부에 따라 텍스트 또는 빈 공간을 표시
                            showMeaning ? AnyView(Text(displayWordMeaning)
                                .foregroundColor(.primary)
                                .font(.system(size: 30))) : AnyView(EmptyView())
                        )
                    
                    Spacer()
                    
//                    Spacer()
                    
                    if !isReallyKnowWord {
                        CommonButton(action: {
                            showMeaning = true
                            isReallyKnowWord = true
                            stopTimer()
                        }, buttonText: "아는 단어")
                        
                        Spacer()
                        
                        CommonButton(action: {
                            setIsKnowWord(isKnowWord: false)
                            showRandomWord()
                        }, buttonText: "모르는 단어")
                    } else {
                        CommonButton(action: {
                            setIsKnowWord(isKnowWord: true)
                            showRandomWord()
                        }, buttonText: "아는 단어가 맞음")
                        
                        Spacer()
                        
                        CommonButton(action: {
                            showRandomWord()
                        }, buttonText: "사실 모르는 단어")
                    }
                    
//                    Spacer()
                    
                    Spacer()
                }
            }
            
            if showPopup {
                Color.primary.opacity(0.4) // 어두운 반투명 배경
                    .ignoresSafeArea()
                
                let knownWordCount = modelData.words.filter { $0.isKnowWord }.count // 아는 단어 개수 계산
                let totalWordCount = modelData.words.count // 총 단어 개수 계산
                
                VStack(spacing: 20) {
                    Text("단어를 모두 보셨습니다!")
                        .font(.title)
                        .padding(.top, 20)
                        .padding(.top, 20)
                    
                    Text("아는 단어: \(knownWordCount) / \(totalWordCount)")
                        .font(.headline)
                    
                    Button {
                        showPopup = false // 팝업 닫기
                        showRandomWord()   // 새로운 단어 보여주기
                    } label: {
                        Text("확인")
                    }
                }
                .frame(width: 300, height: 400)
                .background(Color.primary)
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
            presentationMode.wrappedValue.dismiss()
            return
        }
        
//        if availableWords.isEmpty {
//            presentationMode.wrappedValue.dismiss()
//        }

        let randomWord = availableWords.randomElement()! // 아직 보여주지 않은 단어 중에서 랜덤 선택
        displayWordName = randomWord.name
        displayWordMeaning = randomWord.meaning
        currentIndex = modelData.words.firstIndex(of: randomWord) ?? 0
        shownWords.append(randomWord) // 선택된 단어를 기록
        startTimer()
        isReallyKnowWord = false
        showMeaning = false
     }
    
    private func setIsKnowWord(isKnowWord: Bool) {
        modelData.words[currentIndex].isKnowWord = isKnowWord
        modelData.words[currentIndex].knowTime = isKnowWord ? Double(timerMilliseconds) / 100 : 0
        modelData.saveWords() // 속성 변경 할때는 didset이 호출되지 않으므로 따로 호출
    }
    
    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 1 {
                countdown -= 1
            } else {
                timer.invalidate()
                showCountdown = false
                countdown = 3
            }
        }
    }

}

#Preview {
    var modelData = ModelData()
    if modelData.words.isEmpty {
        modelData.words = modelData.getSampleWords()
    }
    return Play()
        .environmentObject(modelData)
        .preferredColorScheme(.dark)
}

struct CommonButton: View {
    let action: () -> Void
    let buttonText: String
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(buttonText)
                .font(.title)
                .foregroundColor(Color.primary)
        }
    }
}
