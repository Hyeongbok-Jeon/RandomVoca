//
//  Play.swift
//  RandomVoca
//
//  Created by Hyeongbok Jeon on 9/11/24.
//

import SwiftUI

struct PlayV2: View {
    @EnvironmentObject var modelData: ModelData
    
    @Environment(\.presentationMode) var presentationMode // presentationMode 추가
    
    @State private var definition: String = "뜻을 보려면 버튼을 눌러주세요."
    
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
            VStack {
                Spacer()
                
                Text(displayWordName)
                    .font(.system(size: 80)) // 원하는 크기로 설정
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
                        // 왼쪽 스와이프 → 다음 단어
                        showRandomWord()
                    } else if value.translation.width > 50 {
                        // 오른쪽 스와이프 → 이전 단어
                        showPreviousWord()
                    }
                }
        )
        .onAppear {
            showRandomWord()
        }
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
        showKnowWordButton = false
        showMeaning = false
    }
    
    private func showPreviousWord() {
        if !shownWords.isEmpty {
            shownWords.removeLast()
            if let previousWord = shownWords.last {
                displayWordName = previousWord.name
                displayWordMeaning = previousWord.meaning
                currentIndex = modelData.words.firstIndex(of: previousWord) ?? 0
            }
        }
    }
    
    private func setIsKnowWord(isKnowWord: Bool) {
        modelData.words[currentIndex].isKnowWord = isKnowWord
        modelData.words[currentIndex].knowTime = isKnowWord ? Double(timerMilliseconds) / 100 : 0
        modelData.saveWords() // 속성 변경 할때는 didset이 호출되지 않으므로 따로 호출
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
    let modelData = ModelData()
    if modelData.words.isEmpty {
        modelData.words = modelData.getSampleWords()
    }
    return PlayV2()
        .environmentObject(modelData)
        .preferredColorScheme(.dark)
}
#endif
