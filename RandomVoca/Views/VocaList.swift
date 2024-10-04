import SwiftUI

struct VocaList: View {
    @State private var wordName: String = ""      // 입력한 단어 이름
    @State private var wordMeaning: String = ""
    @State private var words: [Word] = []         // 저장된 단어 리스트
    @State private var showPopup = false          // 팝업창 제어 상태 변수
    @State private var showWordNameEmptyError = false
    @State private var showWordMeaningEmptyError = false
    @State private var showAlert = false
    
    var sortedWords: [Word] {
        words.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        ZStack {
            NavigationStack {
                HStack {
                    Text("단어 그룹 1")
                        .font(.largeTitle)
                    
                    Spacer()
                    
                    NavigationLink {
                        Play(words: words)
                    } label: {
                        if !words.isEmpty {
                            Text("Play")
                        } else {
                            Button("Play") {
                                showAlert = true
                            }
                            .alert(isPresented: $showAlert) {
                                Alert(
                                    title: Text(""),
                                    message: Text("단어를 추가해주세요.")
                                )
                            }
                        }
                    }
                }
                .padding()
                
                List {
                    ForEach(sortedWords) { word in
                        HStack {
                            Text(word.name)
                                .frame(maxWidth: .infinity, alignment: .leading)  // 왼쪽 정렬 및 최대 너비 설정
                            Text(word.meaning)
                                .frame(maxWidth: .infinity, alignment: .leading)  // 왼쪽 정렬 및 최대 너비 설정
                        }
                    }
                    .onDelete(perform: deleteWord)
                }
                .listStyle(PlainListStyle())
                .onAppear(perform: loadWords)
                
                Spacer()
            }
            
            // Floating Button
            Button(action: {
                showPopup = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.blue)
                    .padding()
            }
            .position(x: UIScreen.main.bounds.width - 70, y: UIScreen.main.bounds.height - 140)
            
            // Custom Popup View
            if showPopup {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all) // 화면 전체에 반투명 배경 적용
                
                VStack {
                    Text("단어 추가")
                        .font(.title)
                        .padding()
                    
                    TextField("단어", text: $wordName)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    if (showWordNameEmptyError) {
                        Text("단어를 입력해주세요.")
                            .foregroundColor(.red)
                    }
                    
                    TextField("뜻", text: $wordMeaning)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    if (showWordMeaningEmptyError) {
                        Text("뜻을 입력해주세요.")
                            .foregroundColor(.red)
                    }
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            showPopup = false // 팝업 닫기
                            wordName = ""
                            wordMeaning = ""
                            showWordNameEmptyError = false
                            showWordMeaningEmptyError = false
                        }) {
                            Text("취소")
                                .font(.title2)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showWordNameEmptyError = wordName.isEmpty
                            showWordMeaningEmptyError = wordMeaning.isEmpty
                            
                            if !wordName.isEmpty && !wordMeaning.isEmpty {
                                let newWord = Word(name: wordName, meaning: wordMeaning)
                                words.insert(newWord, at: 0)  // 단어 리스트에 추가
                                saveWords()                 // 로컬 저장
                                wordName = ""                   // 입력 필드 초기화
                                wordMeaning = ""
                                showPopup = false // 팝업 닫기
                                showWordNameEmptyError = false
                                showWordMeaningEmptyError = false
                            }
                        }) {
                            Text("추가")
                                .font(.title2)
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
                .frame(width: UIScreen.main.bounds.width * 0.8)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 10)
                .transition(.scale) // 팝업 등장 애니메이션
                .padding()
            }
        }
        .animation(.easeInOut, value: showPopup) // 애니메이션 적용
    }
    
    // 단어 저장 함수 (UserDefaults 사용)
    func saveWords() {
        if let encoded = try? JSONEncoder().encode(words) {
            UserDefaults.standard.set(encoded, forKey: "SavedWords")
        }
    }
    
    // 로컬 저장된 단어 불러오기
    func loadWords() {
        if let savedData = UserDefaults.standard.data(forKey: "SavedWords"),
           let decodedWords = try? JSONDecoder().decode([Word].self, from: savedData) {
            words = decodedWords
        }
    }
    
    // 단어 삭제 함수
    func deleteWord(at offsets: IndexSet) {
        let sortedOffsets = offsets.map { sortedWords[$0] } // Get the actual Word objects from sortedWords
        for word in sortedOffsets {
            if let index = words.firstIndex(where: { $0.id == word.id }) {
                words.remove(at: index) // Remove from original words array
            }
        }
        saveWords() // Save the updated list after deletion
    }
}

#Preview {
    VocaList()
}
