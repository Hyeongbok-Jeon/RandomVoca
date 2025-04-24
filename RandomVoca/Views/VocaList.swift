import SwiftUI

struct VocaList: View {
//    enum FocusField: Hashable {
//        case word(UUID)
//        case meaning(UUID)
//    }

    @EnvironmentObject var modelData: ModelData
    
    @State private var wordName: String = ""      // 입력한 단어 이름
    @State private var wordMeaning: String = ""
    @State private var showPopup = false          // 팝업창 제어 상태 변수
    @State private var showAlert = false
    @State private var showPlayOptions = false   // Play 옵션 Sheet 제어 상태 변수
    @State private var navigateToPlay: Bool = false
    @State private var selectedPlayMode: String = ""
    @State private var isEditing = false // 편집 모드 상태 변수
    @State private var isAdding = false // 추가 모드 상태 변수
    @State private var selectedWords = Set<UUID>() // 선택된 단어 ID 저장
    
//    @FocusState private var focusedField: FocusField?  // 포커스 관리용 변수
    
    @State private var wordFirstResponder: [UUID: Bool] = [:]
    @State private var meaningFirstResponder: [UUID: Bool] = [:]
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6)
                .ignoresSafeArea()
            
            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack {
                            if modelData.words.isEmpty {
                                Spacer()
                                    .frame(height: 50)
                                
                                HStack {
                                    Spacer()
                                    Text("단어를 추가해주세요.")
                                    Spacer()
                                }
                            } else {
                                ForEach($modelData.words) { $word in
                                    HStack {
                                        if isEditing {
                                            Button(action: {
                                                toggleSelection(for: word.id)
                                            }) {
                                                Image(systemName: selectedWords.contains(word.id) ? "checkmark.circle.fill" : "circle")
                                                    .imageScale(.large) // 체크마크 크기 조절
                                            }
                                        }
                                                                                
                                        CustomUITextField(
                                            text: $word.name,
                                            placeholder: "단어",
                                            onCommit: {
                                                meaningFirstResponder[word.id] = true
                                                wordFirstResponder[word.id] = false
                                            },
                                            isFirstResponder: bindingForWord(word.id, isMeaning: false)
                                        )
                                        .onChange(of: wordFirstResponder[word.id] ?? false) { updateIsAddingState()
                                        }
                                        .disabled(!isAdding)

                                        CustomUITextField(
                                            text: $word.meaning,
                                            placeholder: "뜻",
                                            onCommit: {
                                                meaningFirstResponder[word.id] = false
                                                addWord(proxy: proxy)
                                            },
                                            isFirstResponder: bindingForWord(word.id, isMeaning: true)
                                        )
                                        .frame(maxWidth: .infinity)
                                        .onChange(of: meaningFirstResponder[word.id] ?? false) {
                                            updateIsAddingState()
                                        }
                                        .disabled(!isAdding)
                                        
                                        HStack {
                                            Text("\(String(word.knowTime))")
                                                .frame(maxWidth: .infinity)
                                            Spacer()
                                            Circle()
                                                .fill(word.isKnowWord ? Color.green : Color.red)
                                                .frame(width: 10, height: 10)
                                        }
                                    }
                                    .padding(.horizontal, 30)
                                }
                                .onDelete(perform: deleteWord)
                            }
                        }
                        .onAppear(perform: modelData.loadWords)
                        .navigationTitle(modelData.selectedGroup?.name ?? "그룹명")
                        .toolbar {
#if DEBUG
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button {
                                    modelData.words = modelData.getSampleWords()
                                    modelData.loadWords()
                                    isAdding = false
                                } label: {
                                    Text("샘플")
                                }
                            }
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button {
                                    isAdding = false
                                    
                                    DispatchQueue.main.async {
                                        modelData.words.removeAll()
                                    }
                                } label: {
                                    Text("모두 삭제")
                                }
                            }
#endif
                            //                            ToolbarItem(placement: .navigationBarTrailing) {
                            //                                Button {
                            //                                    showPlayOptions = true
                            //                                } label: {
                            //                                    Image(systemName: "play.fill")
                            //                                }
                            //                                .disabled(
                            //                                    modelData.words.isEmpty
                            //                                    || modelData.words.contains(where: { $0.name.isEmpty })
                            //                                    || isEditing
                            //                                )
                            //                            }
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
//                                    focusedField = nil
                                    
                                    isEditing.toggle()
                                    if !isEditing {
                                        selectedWords.removeAll() // 편집 종료 시 선택 초기화
                                    }
                                } label: {
                                    Text(isEditing ? "완료" : "편집")
                                }
                                .disabled(
                                    modelData.words.isEmpty
//                                        || modelData.words.contains(where: { $0.name.isEmpty })
                                    || isAdding
                                )
                            }
                            ToolbarItem(placement: .navigationBarTrailing) {
                                if isEditing {
                                    Button(action: deleteSelectedWords) {
                                        Text("삭제")
                                    }
                                    .disabled(selectedWords.isEmpty) // 선택된 항목 없을 시 비활성화
                                } else {
                                    if isAdding {
                                        Button(action: {
                                            removeEmptyWords()
                                        }) {
                                            Text("완료")
                                        }
                                    } else {
                                        Button(action: {
                                            addWord(proxy: proxy)
                                        }) {
                                            Image(systemName: "plus")
                                        }
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
                            .presentationDetents([.fraction(0.2)]) // 높이를 30% 또는 50%로 설정
                            .presentationDragIndicator(.visible) // 드래그 바 표시
                            .environmentObject(modelData)
                        }
                        .navigationDestination(isPresented: $navigateToPlay) {
                            NavigationStack {
                                Play(playMode: selectedPlayMode)
                            }
                        }
                    }
                    .onTapGesture {
                        removeEmptyWords()
                    }
                }
                
                if !isAdding {
                    BannerAdView()
                        .frame(height: 50)
                }
            }
            
            // 버튼 활성화 여부 계산
            let isButtonEnabled = !(modelData.words.isEmpty ||
                                    modelData.words.contains(where: { $0.name.isEmpty }) ||
                                    isEditing)
            
            if !isAdding {
                // 오른쪽 아래 플로팅 재생 버튼
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            showPlayOptions = true
                        }) {
                            Image(systemName: "play.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 35))
                                .padding(20)
                                .background(isButtonEnabled ? Color.blue : Color.gray)
                                .clipShape(Circle())
                                .shadow(radius: 6)
                        }
                        .padding(.bottom, 80)
                        .padding(.trailing, 20)
                        .disabled(!isButtonEnabled)
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
    
    func removeEmptyWords() {
        // 모든 포커스 해제
        
        for key in wordFirstResponder.keys {
            wordFirstResponder[key] = false
        }
        for key in meaningFirstResponder.keys {
            meaningFirstResponder[key] = false
        }
        
        // 상태 업데이트
        isAdding = false

        // 빈 단어 제거는 비동기 처리
        DispatchQueue.main.async {
            modelData.words.removeAll { $0.name.isEmpty }
        }
    }
    
    // 단어 추가 함수: 빈 단어를 리스트의 맨 아래에 추가
    func addWord(proxy: ScrollViewProxy) {
        let newWord = Word(name: "", meaning: "", isKnowWord: false, knowTime: 0)
        modelData.words.append(newWord)
        wordFirstResponder[newWord.id] = true
        meaningFirstResponder[newWord.id] = false

        // ✅ 포커스 상태 반영되도록 isAdding 강제 업데이트
        updateIsAddingState()
    }
    
    // 단어 삭제 함수
    func deleteWord(at offsets: IndexSet) {
        modelData.words.remove(atOffsets: offsets) // 기본 리스트에서 삭제
    }
    
    // ✅ 뷰 본문 내에 Binding 생성 함수 추가
    func bindingForWord(_ id: UUID, isMeaning: Bool) -> Binding<Bool> {
        Binding(
            get: {
                isMeaning ? (meaningFirstResponder[id] ?? false) : (wordFirstResponder[id] ?? false)
            },
            set: {
                if isMeaning {
                    meaningFirstResponder[id] = $0
                } else {
                    wordFirstResponder[id] = $0
                }
            }
        )
    }
    
    func updateIsAddingState() {
        // 어떤 필드라도 포커스 되어있으면 true
        let anyWordFocused = wordFirstResponder.values.contains(true)
        let anyMeaningFocused = meaningFirstResponder.values.contains(true)
        isAdding = anyWordFocused || anyMeaningFocused
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
                Text("전체 학습")
                    .font(.title2)
            }
            
            Spacer()
            
            Divider()
                .frame(height: 2) // Divider의 높이를 2로 설정
                .background(Color.gray) // Divider의 색상 설정
            
            Spacer()
            
            Button {
                onSelect("part")
            } label: {
                Text("모르는 단어만 학습")
                    .font(.title2)
            }
            .disabled(!modelData.words.contains(where: { !$0.isKnowWord }))
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        VocaList()
            .environmentObject(ModelData())
//            .preferredColorScheme(.dark)
    }
}
