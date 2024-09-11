    import SwiftUI

    struct VocaList: View {
        @State private var wordName: String = ""      // 입력한 단어 이름
        @State private var words: [Word] = []         // 저장된 단어 리스트
        
        var sortedWords: [Word] {
            words.sorted { $0.name < $1.name }
        }
        
        var body: some View {
            HStack {
                Text("단어 그룹 1")
                    .font(.largeTitle)
                
                Spacer()
            }
            .padding(.all, 20)
            
            NavigationView {
                List{
                    ForEach(sortedWords) { word in
                        Text(word.name)
                    }
                    .onDelete(perform: deleteWord)
                }
                .listStyle(PlainListStyle())
                .onAppear(perform: loadWords) // 로컬 저장된 단어 불러오기
            }
            .frame(height: UIScreen.main.bounds.height / 3) // 높이를 디바이스의 절반으로 설정
            
    //        Divider()
            
            HStack(alignment: .center) {
                TextField("단어를 입력하세요", text: $wordName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
    //            Spacer()
                
                Button("추가") {
                    if !wordName.isEmpty {
                        let newWord = Word(name: wordName)
                        words.insert(newWord, at: 0)  // 단어 리스트에 추가
                        saveWords()                 // 로컬 저장
                        wordName = ""                   // 입력 필드 초기화
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
            
            Spacer()
            
            Button(action: {
                // 재생 버튼 눌렀을 때의 동작
                playWord(words)
            }) {
                Image(systemName: "play.fill")
                    .resizable() // 이미지 크기 조정 가능하게 설정
                    .aspectRatio(contentMode: .fit) // 이미지 비율 유지
                    .foregroundColor(.blue)
                    .padding()
                    .frame(width: 100, height: 100) // 버튼의 크기 지정
            }
            
            Spacer()
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
            words.remove(atOffsets: offsets)
            UserDefaults.standard.set(words, forKey: "SavedWords")
        }
        
        // 재생 버튼 눌렀을 때 호출되는 함수
        func playWord(_ words: [Word]) {
            
        }
    }

    #Preview {
        VocaList()
    }
