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
            // ✅ 전체 화면을 터치 가능하게 설정
            Color.black
                .ignoresSafeArea()
                .contentShape(Rectangle()) // 터치 가능 영역을 전체 화면으로 설정
                .onTapGesture {
                    showRandomWord()
                }
            
            VStack {
                VStack {
                    Spacer()
                    
                    Text(displayWordName)
                        .font(.system(size: 80))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
//                        .padding()
                    
                    Text(displayWordPronunciation)
                        .font(.system(size: 30))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
//                        .padding()
                    
                    // ✅ 뜻 (발음기호 아래에 표시)
//                    if showMeaning {
//                        Text(displayWordMeaning)
//                            .font(.title)
//                            .foregroundColor(.primary)
//                            .padding(.top, 10) // 발음기호와 간격 조정
//                            .transition(.opacity) // 부드러운 전환 효과 추가
//                    }
                    
                    Spacer()
                }
                .frame(maxHeight: UIScreen.main.bounds.height / 5 * 2) // ✅ 화면의 절반 높이만 사용
                
                Divider()
                    .frame(width: 300, height: 2) // ✅ 200px만 표시
                    .background(Color.primary) // ✅ 파란색 Divider
                
                Spacer()

                // ✅ "뜻 보기" 버튼은 계속 유지
                Button {
                    showMeaning = true // ✅ 버튼을 누르면 뜻 표시
                } label: {
                    Text("뜻 보기")
                        .font(.largeTitle)
                        .padding()
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                }

                Spacer()
            }
        }
        .onAppear {
            // ✅ 푸시에서 전달된 단어가 있을 경우 랜덤 단어 실행 안 함
            if displayWordName == "단어 없음" {
                showRandomWord()
            }
        }
    }

    private func showRandomWord() {
        // ✅ 모든 단어를 다 보여줬으면 배열 초기화하고 다시 시작
        if shownWords.count == modelData.words.count {
            shownWords.removeAll()
        }
        
        let availableWords = modelData.words.filter { !shownWords.contains($0) } // 아직 안 나온 단어 선택

        // ✅ guard let 유지, 단어 없으면 "단어 없음" 표시
        guard let randomWord = availableWords.randomElement() else {
            return
        }

        displayWordName = randomWord.name ?? "단어 없음"
        displayWordPronunciation = randomWord.pronunciation ?? "발음기호 없음"
        shownWords.append(randomWord) // 선택된 단어 기록
    }

    // iOS 내장 사전 호출 함수
    func showDictionary(for word: String) {
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

#if DEBUG
#Preview {
    let modelData = ModelDataV2()
    return PlayV2()
        .environmentObject(modelData)
        .preferredColorScheme(.dark)
}
#endif
