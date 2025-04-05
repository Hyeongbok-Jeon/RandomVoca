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
    @State private var showNextWordButton: Bool = false
    @State private var timerMilliseconds: Int = 0 // 초 단위 타이머를 위한 상태 변수
    @State private var timer: Timer? // 타이머 객체 저장
    @State private var countdown: Int = 3
    @State private var showCountdown: Bool = false
    
    @State private var progress: CGFloat = 1.0
    @State private var gaugeTimer: Timer?
    
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
                        
                        GeometryReader { geometry in
                            VStack {
                                Text(displayWordName)
                                    .font(.system(size: 80))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .padding()
                            }
                            .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.6)
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 10)
//                                    .stroke(Color.primary, lineWidth: 2)
//                            )
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 3 * 2)
                        }
                    }
                    .onAppear {
                        if playMode == "part" {
                            shownWords = modelData.words.filter { $0.isKnowWord }
                        }
                        showRandomWord()
                    }
                    .frame(height: UIScreen.main.bounds.height / 3) // 화면 높이의 절반으로 고정
                    
                    Text(showMeaning ? displayWordMeaning : " ")
                        .foregroundColor(.orange)
                        .font(.system(size: 40))
                        .frame(height: 80)
                    
//                    Divider()
//                        .frame(height: 2) // Divider의 높이를 2로 설정
//                        .background(Color.gray) // Divider의 색상 설정
                    
                    Spacer()
                    
                    ZStack(alignment: .leading) {
                        Capsule()
                            .frame(height: 20)
                            .foregroundColor(.gray.opacity(0.3))

                        Capsule()
                            .frame(width: UIScreen.main.bounds.width * 0.8 * progress, height: 20)
                            .foregroundColor(.red)
                            .animation(.linear(duration: 0.03), value: progress)
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.8)
                    .padding()
                    
//                    // 초시계 텍스트를 정중앙에 배치하기 위해 Spacer로 조정
//                    Text(String(format: "%.2f", Double(timerMilliseconds) / 100))
//                        .font(.largeTitle)
//                        .onAppear {
//                            startTimer()
//                        }
                    
                    Spacer()
                    
                    VStack {
                        if showNextWordButton {
                            playViewButton(action: {
                                showRandomWord()
                                showNextWordButton = false
                            }, systemIconName: "arrow.right.circle", accessibilityLabel: "다음 단어")
                        }
                    }
                    .frame(height: 80) // 항상 동일 높이 유지
                    
//                    if showKnowWordButton {
//                        HStack {
//                            VStack {
//                                playViewButton(action: {
//                                    setIsKnowWord(isKnowWord: false)
//                                    showRandomWord()
//                                }, systemIconName: "hand.thumbsdown", accessibilityLabel: "사실 모르는 단어")
//                            }
//                            .frame(maxWidth: .infinity)
//                            
//                            VStack {
//                                playViewButton(action: {
//                                    setIsKnowWord(isKnowWord: true)
//                                    showRandomWord()
//                                }, systemIconName: "hand.thumbsup", accessibilityLabel: "아는 단어가 맞음")
//                            }
//                            .frame(maxWidth: .infinity)
//                        }
//
//                    } else if showDontKnowWordButton {
//                        VStack {
//                            playViewButton(action: {
//                                showRandomWord()
//                                showDontKnowWordButton = false
//                            }, systemIconName: "arrow.right.circle", accessibilityLabel: "다음 단어")
//                        }
//                    } else {
//                        HStack {
//                            VStack {
//                                playViewButton(action: {
//                                    setIsKnowWord(isKnowWord: false)
//                                    showDontKnowWordButton = true
//                                    showMeaning = true
//                                    stopTimer()
//                                }, systemIconName: "xmark.circle", accessibilityLabel: "모르는 단어")
//                            }
//                            .frame(maxWidth: .infinity)
//                            
//                            VStack {
//                                playViewButton(action: {
//                                    showMeaning = true
//                                    showKnowWordButton = true
//                                    stopTimer()
//                                }, systemIconName: "checkmark.circle", accessibilityLabel: "아는 단어")
//                            }
//                            .frame(maxWidth: .infinity)
//                        }
//                    }
                    
                    Spacer()
                }
            }
        }
        
//        BannerAdView() // ✅ 배너 광고 추가
//            .frame(height: 50)
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
        startGauge() // ✅ 게이지 시작 추가
        
//        showKnowWordButton = false
        showMeaning = false
        showNextWordButton = false
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
    
    private func startGauge() {
        gaugeTimer?.invalidate()
        progress = 1.0
        
        gaugeTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            if progress > 0 {
                progress -= 0.01
            } else {
                timer.invalidate()
                stopTimer()
                // 👉 여기서 다음 단어로 넘기거나 showMeaning 표시할 수 있어요
                showMeaning = true
//                showDontKnowWordButton = true
                showNextWordButton = true
            }
        }
    }

    private func stopGauge() {
        gaugeTimer?.invalidate()
        gaugeTimer = nil
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
//        .preferredColorScheme(.dark)
}
#endif

struct playViewButton: View {
    let action: () -> Void
    let systemIconName: String
    let accessibilityLabel: String // VoiceOver 사용자를 위한 접근성 라벨

    var body: some View {
        Button(action: action) {
            Image(systemName: systemIconName)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .padding()
                .foregroundColor(.primary)
                .accessibilityLabel(accessibilityLabel)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 10)
//                        .stroke(Color.primary, lineWidth: 2)
//                )
        }
    }
}
