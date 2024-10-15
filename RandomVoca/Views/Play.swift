//
//  Play.swift
//  RandomVoca
//
//  Created by Hyeongbok Jeon on 9/11/24.
//

import SwiftUI

struct Play: View {
    var words: [Word]
    @State private var currentIndex: Int = 0
    @State private var displayWordName: String = ""
    @State private var displayWordMeaning: String = ""
    @State private var showMeaning: Bool = false  // 뜻을 표시할지 여부를 관리하는 상태
    @State private var shownWords: [Word] = [] // 이미 보여준 단어를 추적하는 배열
    
    var body: some View {
        Spacer()
        
        VStack {
            Text(displayWordName)
                .font(.largeTitle)
            

        }
        .onAppear {
            showRandomWord()
        }
        
        Spacer()
        
        if showMeaning {
            Text(displayWordMeaning)
        } else {
            Button {
                showMeaning = true // 뜻을 표시하도록 상태 업데이트
            } label: {
                Text("뜻 보기")
            }
        }
        
        Spacer()
        
        Button {
            showRandomWord()
        } label: {
            Text("다음 단어")
        }
        
        Spacer()
    }

    private func showRandomWord() {
        showMeaning = false
        
        let availableWords = words.filter { !shownWords.contains($0) } // 아직 보여주지 않은 단어들만 선택

        guard !availableWords.isEmpty else {
            shownWords.removeAll() // 모든 단어를 보여줬다면, 기록 초기화
            showRandomWord() // 다시 처음부터 시작
            return
        }

        let randomWord = availableWords.randomElement()! // 아직 보여주지 않은 단어 중에서 랜덤 선택
        displayWordName = randomWord.name
        displayWordMeaning = randomWord.meaning
        currentIndex = words.firstIndex(of: randomWord) ?? 0
        shownWords.append(randomWord) // 선택된 단어를 기록
     }
}

#Preview {
    Play(words: [
        Word(name: "vanish", meaning: "사라지다"),
        Word(name: "order", meaning: "주문하다"),
        Word(name: "hold", meaning: "유지하다")
    ])
}
