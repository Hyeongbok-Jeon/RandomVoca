import SwiftUI

struct VocaList: View {
    enum FocusField: Hashable {
        case word(UUID)
        case meaning(UUID)
    }

    @EnvironmentObject var modelData: ModelData
    
    @State private var wordName: String = ""      // 입력한 단어 이름
    @State private var wordMeaning: String = ""
    @State private var showPopup = false          // 팝업창 제어 상태 변수
    @State private var showAlert = false
    @State private var showPlayOptions = false   // Play 옵션 Sheet 제어 상태 변수
    @State private var navigateToPlay: Bool = false
    @State private var selectedPlayMode: String = ""
    @State private var isEditing = false // 편집 모드 상태 변수
    @State private var selectedWords = Set<UUID>() // 선택된 단어 ID 저장
    
    @FocusState private var focusedField: FocusField?  // 포커스 관리용 변수
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack {
                        if modelData.words.isEmpty {
                            HStack {
                                Spacer()
                                Text("단어를 추가해주세요..ç")
                                Spacer()
                            }
                        } else {
                            ForEach($modelData.words) { $word in
                                HStack {
                                    if isEditing {
                                        Button(action: {
                                            toggleSelection(for: word.id)
                                        }) {
                                            Circle()
                                                .stroke(selectedWords.contains(word.id) ? Color.blue : Color.gray, lineWidth: 2)
                                                .background(selectedWords.contains(word.id) ? Circle().fill(Color.blue.opacity(0.3)) : nil)
                                                .frame(width: 24, height: 24)
                                        }
                                    }
                                    
                                    TextField("단어", text: $word.name)
                                        .focused($focusedField, equals: .word(word.id))  // 포커스 설정
                                        .autocapitalization(.none)  // 대문자 자동 입력 비활성화
                                        .onChange(of: focusedField) { oldFocus, newFocus in
                                            if newFocus != .word(word.id) && word.name.isEmpty {
                                                removeEmptyWord(for: word.id)
                                            } else if newFocus == nil {
                                                modelData.loadWords()
                                            }
                                        }
                                        .onChange(of: word.name, { oldValue, newValue in
                                            word.isKnowWord = false
                                            word.knowTime = 0
                                        })
                                        .textFieldStyle(.roundedBorder)
                                        .frame(maxWidth: .infinity)
                                        .multilineTextAlignment(.leading)
                                    
                                    TextField("뜻", text: $word.meaning)
                                        .focused($focusedField, equals: .meaning(word.id))  // 포커스 설정
                                        .textFieldStyle(.roundedBorder)
                                        .frame(maxWidth: .infinity)
                                        .multilineTextAlignment(.leading)
                                    
                                    HStack {
                                        Text("\(String(word.knowTime)) 초")
                                            .frame(maxWidth: .infinity)
                                        
                                        Circle()
                                            .fill(word.isKnowWord ? Color.green : Color.red)
                                            .frame(width: 10, height: 10)
                                    }
                                    .frame(maxWidth: .infinity)
                                    
                                }
                                .padding(.horizontal, 30)
                            }
                            .onDelete(perform: deleteWord)
                        }
                    }
                    .onAppear(perform: modelData.loadWords)
                    .onTapGesture {
                        focusedField = nil
                    }
                    .navigationBarTitle("단어 목록")
                    .toolbar {
#if DEBUG
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                modelData.words = modelData.getSampleWords()
                                modelData.loadWords()
                            } label: {
                                Text("샘플")
                            }
                        }
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                focusedField = nil
                                
                                DispatchQueue.main.async {
                                    modelData.words.removeAll()
                                }
                            } label: {
                                Text("모두 삭제")
                            }
                        }
#endif
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                showPlayOptions = true
                            } label: {
                                Image(systemName: "play.fill")
                            }
                            .disabled(
                                modelData.words.isEmpty
                                || modelData.words.contains(where: { $0.name.isEmpty })
                                || isEditing
                            )
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                focusedField = nil
                                
                                isEditing.toggle()
                                if !isEditing {
                                    selectedWords.removeAll() // 편집 종료 시 선택 초기화
                                }
                            } label: {
                                Text(isEditing ? "완료" : "편집")
                            }
                            .disabled(
                                modelData.words.isEmpty
                                || modelData.words.contains(where: { $0.name.isEmpty })
                            )
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            if isEditing {
                                Button(action: deleteSelectedWords) {
                                    Text("삭제")
                                }
                                .disabled(selectedWords.isEmpty) // 선택된 항목 없을 시 비활성화
                            } else {
                                Button(action: {
                                    addWord(proxy: proxy)
                                }) {
                                    Image(systemName: "plus")
                                }
                            }
                        }
                    }
                    .sheet(isPresented: $showPlayOptions) {
                        PlayOptionsView { playMode in
                            showPlayOptions = false
                            if !playMode.isEmpty {
                                selectedPlayMode = playMode
                                navigateToPlay = true
                            }
                        }
                        .presentationDetents([.fraction(0.25)]) // 높이를 30% 또는 50%로 설정
                        .presentationDragIndicator(.visible) // 드래그 바 표시
                        .environmentObject(modelData)
                    }
                    .navigationDestination(isPresented: $navigateToPlay) {
                        Play(playMode: selectedPlayMode)
                    }
                }
            }
        }
    }
    
    // 선택된 단어 ID를 토글
    func toggleSelection(for id: UUID) {
        if selectedWords.contains(id) {
            selectedWords.remove(id)
        } else {
            selectedWords.insert(id)
        }
    }
    
    // 선택된 단어 삭제
    func deleteSelectedWords() {
        modelData.words.removeAll { word in
            selectedWords.contains(word.id)
        }
        selectedWords.removeAll() // 삭제 후 선택 초기화
        if modelData.words.isEmpty {
            isEditing = false
        }
    }
    
    // 빈 단어 제거 함수
    func removeEmptyWord(for id: UUID) {
        focusedField = nil
        
        DispatchQueue.main.async {
            modelData.words.removeAll { $0.id == id } // 해당 id만 삭제
        }
    }
    
    // 단어 추가 함수: 빈 단어를 리스트의 맨 아래에 추가
    func addWord(proxy: ScrollViewProxy) {
        if let lastWord = modelData.words.last, lastWord.name.isEmpty {
            // 이미 빈 단어가 있을 경우 그 단어에 포커스 맞추기
            focusedField = .word(lastWord.id)
        } else {
            // 새 단어 추가
            let newWord = Word(name: "", meaning: "", isKnowWord: false, knowTime: 0)
//            modelData.words.insert(newWord, at: 0)
            modelData.words.append(newWord)
            focusedField = .word(newWord.id)
        }
    }
    
    // 단어 삭제 함수
    func deleteWord(at offsets: IndexSet) {
        modelData.words.remove(atOffsets: offsets) // 기본 리스트에서 삭제
    }
}

// PlayOptionsView 구현
struct PlayOptionsView: View {
    @EnvironmentObject var modelData: ModelData
    
    var onSelect: (String) -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            Button {
                onSelect("all")
            } label: {
                Text("전체 플레이")
                    .font(.title)
            }
            
            Spacer()
            
            Divider()
                .frame(height: 2) // Divider의 높이를 2로 설정
                .background(Color.gray) // Divider의 색상 설정
            
            Spacer()
            
            Button {
                onSelect("part")
            } label: {
                Text("모르는 단어만 플레이")
                    .font(.title)
            }
            .disabled(!modelData.words.contains(where: { !$0.isKnowWord }))
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    VocaList()
        .environmentObject(ModelData())
        .preferredColorScheme(.dark)
}
