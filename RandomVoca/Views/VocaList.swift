import SwiftUI

struct VocaList: View {
    @State private var wordName: String = ""      // 입력한 단어 이름
    @State private var wordMeaning: String = ""
    @State private var words: [Word] = []         // 저장된 단어 리스트
    @State private var showPopup = false          // 팝업창 제어 상태 변수
    @State private var showWordNameEmptyError = false
    @State private var showWordMeaningEmptyError = false
    @State private var showAlert = false
    
    @FocusState private var focusedField: UUID?  // 포커스 관리용 변수
    
    var body: some View {
        ZStack {
            NavigationStack {
                List {
                    ForEach($words) { $word in
                        HStack {
                            TextField("단어", text: $word.name)
                                .textFieldStyle(.roundedBorder)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)  // 텍스트 가운데 정렬
                                .focused($focusedField, equals: word.id)  // 포커스 설정
                                .onSubmit {  // 엔터를 누르면 저장
                                    saveWords()
                                }
                                .onChange(of: word.name) {
                                    saveWords()  // 단어 이름 변경 시 저장
                                }

                            TextField("뜻", text: $word.meaning)
                                .textFieldStyle(.roundedBorder)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)  // 텍스트 가운데 정렬
                                .onSubmit {  // 엔터를 누르면 저장
                                    saveWords()
                                }
                                .onChange(of: word.name) {
                                    saveWords()  // 단어 이름 변경 시 저장
                                }
                        }
                    }
                    .onDelete(perform: deleteWord)
                }
                .onAppear(perform: loadWords)
                .listStyle(PlainListStyle())
                .navigationBarTitle("단어 목록", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            words.removeAll()
                            saveWords()
                        } label: {
                            Text("모두 삭제")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
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
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: addWord) {
                            Image(systemName: "plus")
                        }
                    }
                }
                .onTapGesture {
                    // 빈 단어 또는 뜻이 있는지 확인하고 삭제
                    if let lastWord = words.last, lastWord.name.isEmpty && lastWord.meaning.isEmpty {
                        words.removeLast()
                    }
                }
                
                Spacer()
            }
            
//            // Custom Popup View
//            if showPopup {
//                Color.black.opacity(0.4)
//                    .edgesIgnoringSafeArea(.all) // 화면 전체에 반투명 배경 적용
//                
//                VStack {
//                    Text("단어 추가")
//                        .font(.title)
//                        .padding()
//                    
//                    TextField("단어", text: $wordName)
//                        .padding()
//                        .background(Color(.systemGray6))
//                        .cornerRadius(10)
//                        .padding(.horizontal)
//                    
//                    if (showWordNameEmptyError) {
//                        Text("단어를 입력해주세요.")
//                            .foregroundColor(.red)
//                    }
//                    
//                    TextField("뜻", text: $wordMeaning)
//                        .padding()
//                        .background(Color(.systemGray6))
//                        .cornerRadius(10)
//                        .padding(.horizontal)
//                    
//                    if (showWordMeaningEmptyError) {
//                        Text("뜻을 입력해주세요.")
//                            .foregroundColor(.red)
//                    }
//                    
//                    HStack {
//                        Spacer()
//                        
//                        Button(action: {
//                            closePopup()
//                        }) {
//                            Text("취소")
//                                .font(.title2)
//                        }
//                        
//                        Spacer()
//                        
//                        Button(action: {
//                            showWordNameEmptyError = wordName.isEmpty
//                            showWordMeaningEmptyError = wordMeaning.isEmpty
//                            
//                            if !showWordNameEmptyError && !showWordMeaningEmptyError {
//                                let newWord = Word(
//                                    name: wordName
//                                    , meaning: wordMeaning
//                                )
//                                words.insert(newWord, at: 0)  // 단어 리스트에 추가
//                                saveWords()                 // 로컬 저장
//                                closePopup()
//                            }
//                        }) {
//                            Text("추가")
//                                .font(.title2)
//                        }
//                        
//                        Spacer()
//                    }
//                    .padding()
//                }
//                .frame(width: UIScreen.main.bounds.width * 0.8)
//                .background(Color.white)
//                .cornerRadius(20)
//                .shadow(radius: 10)
//                .transition(.scale) // 팝업 등장 애니메이션
//                .padding()
//            }
        }
        .animation(.easeInOut, value: showPopup) // 애니메이션 적용
    }
    
    // 단어 추가 함수: 빈 단어를 리스트의 맨 아래에 추가
    func addWord() {
        let newWord = Word(name: "", meaning: "")
        words.append(newWord)  // 새 단어를 맨 아래에 추가
        focusedField = newWord.id  // 방금 추가된 단어에 포커스
    }
    
    func saveWords() {
        let key = "SavedWords"  // 그룹 이름을 키에 추가
        if let encoded = try? JSONEncoder().encode(words) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    func loadWords() {
        let key = "SavedWords"  // 그룹 이름을 키에 추가
        if let savedData = UserDefaults.standard.data(forKey: key),
           let decodedWords = try? JSONDecoder().decode([Word].self, from: savedData) {
            words = decodedWords.sorted { $0.name < $1.name }
        }
    }
    
    func closePopup() {
        showPopup = false
        wordName = ""
        wordMeaning = ""
        showWordNameEmptyError = false
        showWordMeaningEmptyError = false
    }
    
    // 단어 삭제 함수
    func deleteWord(at offsets: IndexSet) {
        words.remove(atOffsets: offsets) // 기본 리스트에서 삭제
        saveWords() // Save the updated list after deletion
    }
}

#Preview {
    VocaList()
}
