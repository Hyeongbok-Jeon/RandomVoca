import SwiftUI

struct PlayV2: View {
    @EnvironmentObject var modelData: ModelDataV2

    @State private var displayWordName: String = "단어 없음"
    @State private var shownWords: [WordEntity] = [] // 이미 보여준 단어를 추적하는 배열

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
                Spacer()

                Text(displayWordName)
                    .font(.system(size: 80))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding()

                Spacer()

                Button {
                    showDictionary(for: displayWordName)
                } label: {
                    Text("뜻 보기")
                        .font(.largeTitle)
                }

                Spacer()
            }
        }
        .onAppear {
            showRandomWord()
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
