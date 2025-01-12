//
//  Play.swift
//  RandomVoca
//
//  Created by Hyeongbok Jeon on 9/11/24.
//

import SwiftUI

struct Play: View {
    var playMode: String
    
    @EnvironmentObject var modelData: ModelData
    
    @Environment(\.presentationMode) var presentationMode // presentationMode 추가
    
    @State private var currentIndex: Int = 0
    @State private var displayWordName: String = ""
    @State private var displayWordMeaning: String = ""
    @State private var showMeaning: Bool = false  // 뜻을 표시할지 여부를 관리하는 상태
    @State private var shownWords: [Word] = [] // 이미 보여준 단어를 추적하는 배열
    @State private var showKnowWordButton: Bool = false
    @State private var showDontKnowWordButton: Bool = false
    @State private var timerMilliseconds: Int = 0 // 초 단위 타이머를 위한 상태 변수
    @State private var timer: Timer? // 타이머 객체 저장
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
                    VStack {
                        Spacer()
                        
                        Text(displayWordName)
                            .font(.system(size: 80)) // 원하는 크기로 설정
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .padding()
                    }
                    .onAppear {
                        if playMode == "part" {
                            shownWords = modelData.words.filter { $0.isKnowWord }
                        }
                        showRandomWord()
                    }
                    .frame(height: UIScreen.main.bounds.height / 4) // 화면 높이의 절반으로 고정
                    
                    Text(showMeaning ? displayWordMeaning : " ")
                        .foregroundColor(.orange)
                        .font(.system(size: 40))
                        .frame(height: 80)
                    
                    Spacer()
                    
                    // 초시계 텍스트를 정중앙에 배치하기 위해 Spacer로 조정
                    Text(String(format: "%.2f", Double(timerMilliseconds) / 100))
                        .font(.largeTitle)
                        .onAppear {
                            startTimer()
                        }
                    
                    Spacer()
                    
                    if showKnowWordButton {
                        HStack {
                            VStack {
                                playViewButton(action: {
                                    setIsKnowWord(isKnowWord: false)
                                    showRandomWord()
                                }, buttonText: NSLocalizedString("사실 모르는 단어", comment: ""))
                            }
                            .frame(maxWidth: .infinity)
                            
                            VStack {
                                playViewButton(action: {
                                    setIsKnowWord(isKnowWord: true)
                                    showRandomWord()
                                }, buttonText: NSLocalizedString("아는 단어가 맞음", comment: ""))
                            }
                            .frame(maxWidth: .infinity)
                        }

                    } else if showDontKnowWordButton {
                        VStack {
                            playViewButton(action: {
                                showRandomWord()
                                showDontKnowWordButton = false
                            }, buttonText: NSLocalizedString("다음", comment: ""))
                        }
                    } else {
                        HStack {
                            VStack {
                                playViewButton(action: {
                                    setIsKnowWord(isKnowWord: false)
                                    showDontKnowWordButton = true
                                    showMeaning = true
                                    stopTimer()
                                }, buttonText: NSLocalizedString("모르는 단어", comment: ""))
                            }
                            .frame(maxWidth: .infinity)
                            
                            VStack {
                                playViewButton(action: {
                                    showMeaning = true
                                    showKnowWordButton = true
                                    stopTimer()
                                }, buttonText: NSLocalizedString("아는 단어", comment: ""))
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    
                    Spacer()
                }
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
        
        guard let randomWord = availableWords.randomElement() else {
            presentationMode.wrappedValue.dismiss()
            return
        }
        
        displayWordName = randomWord.name
        displayWordMeaning = randomWord.meaning
        currentIndex = modelData.words.firstIndex(of: randomWord) ?? 0
        shownWords.append(randomWord) // 선택된 단어를 기록
        startTimer()
        showKnowWordButton = false
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

#if DEBUG
#Preview {
    let modelData = ModelData()
    if modelData.words.isEmpty {
        modelData.words = modelData.getSampleWords()
    }
    return Play(playMode: "part")
        .environmentObject(modelData)
        .preferredColorScheme(.dark)
}
#endif

struct playViewButton: View {
    let action: () -> Void
    let buttonText: String
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(buttonText)
                .font(.title2)
                .foregroundColor(.primary)
                .padding()
                .frame(maxWidth: .infinity)
//                .background(
//                    RoundedRectangle(cornerRadius: 8)
//                        .stroke(Color.primary, lineWidth: 2)
//                )
        }
    }
}
