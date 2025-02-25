import SwiftUI

struct PlayV2: View {
    @EnvironmentObject var modelData: ModelDataV2

    @State private var displayWordName: String
    @State private var displayWordPronunciation: String
    @State private var displayWordMeaning: String
    @State private var shownWords: [WordEntity] = [] // 이미 보여준 단어를 추적하는 배열
    @State private var showMeaning: Bool = false // ✅ 뜻 표시 여부
    
    // ✅ 초기 단어를 받을 수 있도록 init 추가
    init(initialWord: String = "단어 없음") {
        _displayWordName = State(initialValue: initialWord)
        _displayWordPronunciation = State(initialValue: "")
        _displayWordMeaning = State(initialValue: "")
    }

    var body: some View {
        ZStack {
            // ✅ 그라디언트 배경 추가 (블루 & 퍼플 계열)
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.9)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .contentShape(Rectangle()) // 터치 가능 영역을 전체 화면으로 설정
            .onTapGesture {
                if showMeaning {
                    showMeaning = false // 뜻이 보이면 숨기기
                } else {
                    showRandomWord() // 새로운 단어 표시
                }
            }
            
            VStack {
                VStack {
                    Spacer()
                    
                    // ✅ 단어 표시 (큰 폰트 + 커스텀 글꼴)
                    Text(displayWordName)
                        .font(.system(size: 90, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 10) // ✅ 부드러운 그림자 추가
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .onTapGesture {
                            showMeaning.toggle() // ✅ 단어 터치 시 뜻 표시
                        }
                    
                    // ✅ 발음기호 (반투명 배경 추가)
                    Text(displayWordPronunciation)
                        .font(.system(size: 30, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule()) // ✅ 둥근 형태 적용
                        .onTapGesture {
                            showMeaning.toggle()
                        }
                    
                    // ✅ 뜻 (부드러운 페이드 효과 추가)
                    if showMeaning {
                        Text(displayWordMeaning)
                            .font(.title)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.top, 10)
                            .transition(.opacity.animation(.easeInOut(duration: 0.5))) // ✅ 부드러운 전환 효과
                    }
                    
                    Spacer()
                }
                .frame(maxHeight: UIScreen.main.bounds.height / 5 * 2) // ✅ 화면의 절반 높이만 사용
                
//                Divider()
//                    .frame(width: 300, height: 2)
//                    .background(Color.white.opacity(0.8)) // ✅ 밝은 컬러로 변경
                
                Spacer()

                // ✅ "뜻 보기" 버튼 개선 (둥글게 & 빛나는 효과)
                Button {
                    showDictionary(for: displayWordName)
                } label: {
                    Text("뜻 보기")
                        .font(.title)
                        .bold()
                        .padding()
                        .frame(width: 180, height: 60)
                        .background(
                            LinearGradient(colors: [Color.blue, Color.purple], startPoint: .top, endPoint: .bottom)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(30)
                        .shadow(color: .purple.opacity(0.5), radius: 10, x: 0, y: 5) // ✅ 부드러운 그림자 추가
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
    }

    // iOS 내장 사전 호출 함수
    func showDictionary(for word: String) {
        Task { @MainActor in
            if UIReferenceLibraryViewController.dictionaryHasDefinition(forTerm: word) {
                let dictionaryVC = UIReferenceLibraryViewController(term: word)
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first?.rootViewController {
                    rootVC.present(dictionaryVC, animated: true)
                }
            } else {
                print("사전에 해당 단어가 없습니다.")
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
