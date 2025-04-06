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
    
    @State private var showExplanation: Bool = false
    
    @AppStorage("hasSeenPlayExplanation") private var hasSeenExplanation: Bool = false
    
    var body: some View {
        ZStack {
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
                            
                            Text(showMeaning ? displayWordMeaning : " ")
                                .foregroundColor(.primary)
                                .font(.system(size: 40))
                                .frame(height: 80)
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

                    // ✅ 설명 처음이면 자동 표시
                    if !hasSeenExplanation {
                        showExplanation = true
                        hasSeenExplanation = true
                    }

                    showRandomWord()
                }
                .frame(height: UIScreen.main.bounds.height / 100 * 39) // 화면 높이의 절반으로 고정
                
//                    Divider()
//                        .frame(height: 2) // Divider의 높이를 2로 설정
//                        .background(Color.gray) // Divider의 색상 설정
                
                Spacer()
                
//                    ZStack(alignment: .leading) {
//                        Capsule()
//                            .frame(height: 20)
//                            .foregroundColor(.gray.opacity(0.3))
//
//                        Capsule()
//                            .frame(width: UIScreen.main.bounds.width * 0.8 * progress, height: 20)
//                            .foregroundColor(.red)
//                            .animation(.linear(duration: 0.03), value: progress)
//                    }
//                    .frame(width: UIScreen.main.bounds.width * 0.8)
//                    .padding()
                
                // 초시계 텍스트를 정중앙에 배치하기 위해 Spacer로 조정
                Text(String(format: "%.2f", Double(timerMilliseconds) / 100))
                    .font(.title)
                    .onAppear {
                        startTimer()
                    }
                
                Spacer()
                
//                    VStack {
//                        if showNextWordButton {
//                            playViewButton(action: {
//                                showRandomWord()
//                                showNextWordButton = false
//                            }, systemIconName: "arrow.right.circle", accessibilityLabel: "다음 단어")
//                        }
//                    }
//                    .frame(height: 80) // 항상 동일 높이 유지
                
                if showKnowWordButton {
                    HStack {
                        VStack {
                            playViewButton(action: {
                                setIsKnowWord(isKnowWord: false)
                                showRandomWord()
                            }, systemIconName: "xmark.circle", accessibilityLabel: "사실 모르는 단어", color: .red)
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack {
                            playViewButton(action: {
                                setIsKnowWord(isKnowWord: true)
                                showRandomWord()
                            }, systemIconName: "checkmark.circle", accessibilityLabel: "아는 단어가 맞음", color: .green)
                        }
                        .frame(maxWidth: .infinity)
                    }

                } else if showDontKnowWordButton {
                    VStack {
                        playViewButton(action: {
                            showRandomWord()
                            showDontKnowWordButton = false
                        }, systemIconName: "arrow.right.circle", accessibilityLabel: "다음 단어", color: .primary)
                    }
                } else {
                    HStack {
                        VStack {
                            playViewButton(action: {
                                setIsKnowWord(isKnowWord: false)
                                showDontKnowWordButton = true
                                showMeaning = true
                                stopTimer()
//                                    stopGauge()
                            }, systemIconName: "xmark.circle", accessibilityLabel: "모르는 단어", color: .primary)
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack {
                            playViewButton(action: {
                                showMeaning = true
                                showKnowWordButton = true
                                stopTimer()
//                                    stopGauge()
                            }, systemIconName: "checkmark.circle", accessibilityLabel: "아는 단어", color: .primary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                
                Spacer()
                
                BannerAdView() // ✅ 배너 광고 추가
                    .frame(height: 50)
            }
            
            if showExplanation {
                Color.black.opacity(0.4) // 반투명 배경
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 16) {
                    Text("학습 방법 안내")
                        .font(.title2)
                        .bold()

                    Group {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.primary)

                            Text("알고 있는 단어일 때 클릭. 뜻을 확인합니다.")
                        }
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "xmark.circle")
                                .foregroundColor(.primary)

                            Text("모르는 단어일 때 클릭. 뜻을 확인합니다.")
                        }
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.green)

                            Text("뜻을 확인 후 정말로 알고 있는 단어라면 아는 단어로 체크합니다.")
                        }
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "xmark.circle")
                                .foregroundColor(.red)

                            Text("뜻을 확인했지만 사실 몰랐던 단어라면 모르는 단어로 체크합니다.")
                        }
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "arrow.right.circle")
                                .foregroundColor(.primary)

                            Text("다음 단어로 넘어갑니다.")
                        }
                    }
                    .font(.body)

                    Button("확인했어요") {
                        withAnimation {
                            showExplanation = false
                        }
                    }
//                    .padding(.top, 10)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(20)
                .padding(.top, 20)
                .padding(.horizontal, 40)
                .padding(.bottom, 90)
                .shadow(radius: 10)
            }
        }
        .toolbar {
            ToolbarItem {
                Button {
                    showExplanation = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.title3)
                        .padding()
                }
            }
        }
        .background(Color(UIColor.systemGray6).ignoresSafeArea())
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
//        startGauge() // ✅ 게이지 시작 추가
        
        showKnowWordButton = false
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
                showDontKnowWordButton = true
                showNextWordButton = true
                setIsKnowWord(isKnowWord: false)
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
    let color: Color // ✅ 추가된 파라미터

    var body: some View {
        Button(action: action) {
            Image(systemName: systemIconName)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .padding()
                .foregroundColor(color) // ✅ 전달받은 색상 사용
                .accessibilityLabel(accessibilityLabel)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 10)
//                        .stroke(Color.primary, lineWidth: 2)
//                )
        }
    }
}

struct ExplanationView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("플레이 방법 안내")
                .font(.title)
                .bold()

            Group {
                Text("1. 단어를 보고 \"아는 단어\" 버튼(✔️) 또는 \"모르는 단어\" 버튼(❌)을 선택하세요.")
                Text("2. \"아는 단어\" 버튼을 누르면 뜻이 공개됩니다.")
                Text("3. 뜻을 보고 나서 다시 \"✔️\" 버튼을 누르면 정말 아는 단어로 기록됩니다.")
                Text("4. 뜻을 보고 \"❌\" 버튼을 누르면 '알고 있다고 생각했지만 사실은 모르는 단어'로 처리됩니다.")
            }

            Text("이 과정을 통해 정확한 암기 상태를 판단할 수 있어요!")
                .foregroundColor(.gray)
                .padding(.top, 10)

            Spacer()

            HStack {
                Spacer()
                Button("닫기") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
            }
        }
        .padding()
    }
}
