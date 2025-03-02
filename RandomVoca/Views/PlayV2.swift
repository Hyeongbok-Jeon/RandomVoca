import SwiftUI

struct PlayV2: View {
    @EnvironmentObject var modelData: ModelDataV2

    @State private var displayWordName: String
    @State private var displayWordPronunciation: String
    @State private var displayWordMeaning: String
    @State private var shownWords: [WordEntity] = [] // 이미 보여준 단어를 추적하는 배열
    @State private var showMeaning: Bool = false // 뜻 표시 여부
    @State private var textOpacity: Double = 1.0 // 단어/발음 텍스트의 opacity 제어
    
    // 초기 단어를 받을 수 있도록 init 추가
    init(initialWord: String = "단어 없음") {
        _displayWordName = State(initialValue: initialWord)
        _displayWordPronunciation = State(initialValue: "")
        _displayWordMeaning = State(initialValue: "")
    }

    var body: some View {
        ZStack {
            // 그라디언트 배경 추가 (블루 & 퍼플 계열)
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.9)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .contentShape(Rectangle()) // 터치 가능 영역을 전체 화면으로 설정
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showRandomWord() // 새로운 단어 표시 (애니메이션 적용)
                }
            }
            
            VStack {
                VStack {
                    Spacer()
                    
                    // 단어와 발음 텍스트를 감싸는 컨테이너에 opacity 적용
                    VStack {
                        // 단어 표시 (큰 폰트 + 커스텀 글꼴)
                        Text(displayWordName)
                            .font(.system(size: 90, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(radius: 10)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showMeaning.toggle() // 단어 터치 시 뜻 토글
                                }
                            }
                        
                        // 발음기호 (반투명 배경 추가)
                        Text(displayWordPronunciation)
                            .font(.system(size: 30, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 5)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Capsule())
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showMeaning.toggle() // 발음기호 터치 시 뜻 토글
                                }
                            }
                    }
                    .opacity(textOpacity)
                    
//                    Spacer()
                }
                .frame(maxHeight: UIScreen.main.bounds.height / 3)
                
                Spacer()
                
                // 고정된 공간을 예약하는 ZStack: 뜻 텍스트는 opacity로 제어
                ZStack {
                    Text(displayWordMeaning)
                        .font(.title)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.top, 10)
                        .opacity(showMeaning ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5), value: showMeaning)
                }
                .frame(height: 50) // 뜻 영역의 높이를 고정

                Spacer()
                
                // "뜻 보기" 버튼 - 위치 고정을 위해 독립된 컨테이너에 배치
                Button {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showMeaning = true
                    }
                } label: {
                    Text("뜻 보기")
                        .font(.title)
                        .bold()
                        .padding()
                        .frame(width: 200, height: 60)
                        .background(
                            LinearGradient(colors: [Color.blue, Color.purple], startPoint: .top, endPoint: .bottom)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(30)
                        .shadow(color: .purple.opacity(0.5), radius: 10, x: 0, y: 5)
                }
                
                Spacer()
            }
        }
        .onAppear {
            if displayWordName == "단어 없음" {
                showRandomWord()
            }
        }
    }

    private func showRandomWord() {
        // 뜻 표시를 초기화
        showMeaning = false
        
        // 먼저 fade out 효과 적용
        withAnimation(.easeOut(duration: 0.3)) {
            textOpacity = 0.0
        }
        
        // 0.3초 후에 단어 업데이트 및 fade in 효과
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            guard !modelData.words.isEmpty else { return }
            
            if shownWords.count == modelData.words.count {
                shownWords.removeAll()
            }
            
            let availableWords = modelData.words.filter { !shownWords.contains($0) }
            guard let randomWord = availableWords.randomElement() else {
                return
            }
            
            displayWordName = randomWord.name ?? "단어 없음"
            displayWordPronunciation = randomWord.pronunciation ?? "발음기호 없음"
            displayWordMeaning = randomWord.meaning ?? "뜻 없음"
            
            shownWords.append(randomWord)
            
            withAnimation(.easeIn(duration: 0.3)) {
                textOpacity = 1.0
            }
        }
    }
}

#if DEBUG
#Preview {
    let modelData = ModelDataV2()
    return PlayV2()
        .environmentObject(modelData)
        .preferredColorScheme(.dark)
}
#endif
