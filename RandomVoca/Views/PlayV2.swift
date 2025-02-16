import SwiftUI

struct PlayV2: View {
    @EnvironmentObject var modelData: ModelDataV2
    @Environment(\.presentationMode) var presentationMode

    @State private var displayWordName: String = "단어 없음"
    @State private var displayWordMeaning: String = ""
    @State private var shownWords: [WordEntity] = [] // 이미 보여준 단어를 추적하는 배열

    var body: some View {
        ZStack {
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
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width < -50 {
                        showRandomWord() // 왼쪽 스와이프 → 다음 단어
                    } else if value.translation.width > 50 {
                        showPreviousWord() // 오른쪽 스와이프 → 이전 단어
                    }
                }
        )
        .onAppear {
            showRandomWord()
        }
    }

    private func showRandomWord() {
        let availableWords = modelData.words.filter { !shownWords.contains($0) } // 아직 안 나온 단어 선택

        guard let randomWord = availableWords.randomElement() else {
            presentationMode.wrappedValue.dismiss()
            return
        }

        displayWordName = randomWord.name ?? "단어 없음"
        shownWords.append(randomWord) // 선택된 단어 기록
    }

    private func showPreviousWord() {
        if !shownWords.isEmpty {
            shownWords.removeLast()
            if let previousWord = shownWords.last {
                displayWordName = previousWord.name ?? "단어 없음"
            }
        }
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
