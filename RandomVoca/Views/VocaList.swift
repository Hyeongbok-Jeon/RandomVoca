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
  @State private var isAdding = false // 추가 모드 상태 변수
  @State private var selectedWords = Set<UUID>() // 선택된 단어 ID 저장
  
  @FocusState private var focusedField: FocusField?  // 포커스 관리용 변수
  
  @State private var wordFirstResponder: [UUID: Bool] = [:]
  @State private var meaningFirstResponder: [UUID: Bool] = [:]
  
  @State private var isKeyboardVisible = false
  
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
                      onCommit: { focusedField = .meaning(word.id) },
                      isFocused: bindingForFocus(word.id, isWord: true) // ✅ isFocused 바인딩 연결
                    )
                    .focused($focusedField, equals: .word(word.id))
                    .onChange(of: focusedField) { oldValue, newValue in
                      if newValue == .word(word.id) {
                        isAdding = true
                      }
                    }
                    .cornerRadius(10)
                    
                    CustomUITextField(
                      text: $word.meaning,
                      placeholder: "뜻",
                      onCommit: { addWord(proxy: proxy) },
                      isFocused: bindingForFocus(word.id, isWord: false) // ✅ isFocused 바인딩 연결
                    )
                    .focused($focusedField, equals: .meaning(word.id))
                    .onChange(of: focusedField) { oldValue, newValue in
                      if newValue == .meaning(word.id) {
                        isAdding = true
                      }
                    }
                    .cornerRadius(10)
                    
                    HStack {
                      Text("\(String(word.knowTime))")
                        .padding(.horizontal)
                        .frame(width: 80)
                      Circle()
                        .fill(word.isKnowWord ? Color.green : Color.red)
                        .frame(width: 10)
                    }
                  }
                  .padding(.horizontal, 30)
                }
                .onDelete(perform: deleteWord)
              }
            }
            .onAppear {
              NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
                isKeyboardVisible = true
              }
              NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                isKeyboardVisible = false
              }
              modelData.loadWords()
            }
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
              ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                  isEditing.toggle()
                  if !isEditing {
                    selectedWords.removeAll() // 편집 종료 시 선택 초기화
                  }
                } label: {
                  Text(isEditing ? "완료" : "편집")
                }
                .disabled(
                  modelData.words.isEmpty || isAdding
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
        
//        if !isAdding {
//          BannerAdView()
//            .frame(height: 50)
//        }
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
            .padding(.bottom, 20)
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
    focusedField = nil
    
    // 빈 단어 제거는 비동기 처리
    DispatchQueue.main.async {
      // 상태 업데이트
      isAdding = false
      modelData.words.removeAll { $0.name.isEmpty }
    }
  }
  
  // 단어 추가 함수: 빈 단어를 리스트의 맨 아래에 추가
  func addWord(proxy: ScrollViewProxy) {
    // 현재 편집 중인 단어의 ID를 찾습니다.
    if case .meaning(let currentWordId) = focusedField {
      // 해당 단어의 인덱스를 찾습니다.
      if let index = modelData.words.firstIndex(where: { $0.id == currentWordId }) {
        // 해당 단어의 '단어' 이름이 비어 있다면 해당 단어를 제거합니다.
        if modelData.words[index].name.isEmpty {
          modelData.words.remove(at: index)
          focusedField = nil // 포커스 해제
          isAdding = false
          return // 함수 종료
        }
      }
    }
    
    let newWord = Word(name: "", meaning: "", isKnowWord: false, knowTime: 0)
    modelData.words.append(newWord)
    isAdding = true
    
    // UI 업데이트 후 포커스 설정
    DispatchQueue.main.async {
      focusedField = .word(newWord.id) // ✅ 새로 추가된 단어의 '단어' 필드에 포커스 설정
    }
  }
  
  // 단어 삭제 함수
  func deleteWord(at offsets: IndexSet) {
    modelData.words.remove(atOffsets: offsets) // 기본 리스트에서 삭제
  }
  
  func bindingForFocus(_ id: UUID, isWord: Bool) -> Binding<Bool> {
    Binding(
      get: {
        (isWord && focusedField == .word(id)) || (!isWord && focusedField == .meaning(id))
      },
      set: { newValue in
        focusedField = newValue ? (isWord ? .word(id) : .meaning(id)) : nil
      }
    )
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
  }
}
