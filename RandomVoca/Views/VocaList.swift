import SwiftUI

struct VocaList: View {
  enum FocusField: Hashable {
    case word(UUID)
    case meaning(UUID)
  }

  @EnvironmentObject var modelData: ModelData

  @State private var wordName: String = ""
  @State private var wordMeaning: String = ""
  @State private var showPopup = false
  @State private var showAlert = false
  @State private var showPlayOptions = false
  @State private var navigateToPlay: Bool = false
  @State private var selectedPlayMode: String = ""
  @State private var isEditing = false
  @State private var isAdding = false
  @State private var selectedWords = Set<UUID>()

  @FocusState private var focusedField: FocusField?
  @State private var wordFirstResponder: [UUID: Bool] = [:]
  @State private var meaningFirstResponder: [UUID: Bool] = [:]
  @State private var isKeyboardVisible = false

  var body: some View {
    ZStack {
      Color(UIColor.systemGray6).ignoresSafeArea()

      VStack {
        ScrollViewReader { proxy in
          ScrollView {
            VStack {
              if modelData.words.isEmpty {
                Spacer().frame(height: 50)

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
                          .imageScale(.large)
                      }
                    }

                    CustomUITextField(
                      text: $word.name,
                      placeholder: "단어",
                      onCommit: { focusedField = .meaning(word.id) },
                      isFocused: bindingForFocus(word.id, isWord: true)
                    )
                    .focused($focusedField, equals: .word(word.id))
                    .onChange(of: focusedField) { oldValue, newValue in
                      if newValue == .word(word.id) {
                        isAdding = true
                      }
                    }
                    .cornerRadius(10)
                    .onChange(of: word.name) { _, _ in
                      modelData.saveWord(word) // ✅ Firestore에 저장
                    }

                    CustomUITextField(
                      text: $word.meaning,
                      placeholder: "뜻",
                      onCommit: { addWord(proxy: proxy) },
                      isFocused: bindingForFocus(word.id, isWord: false)
                    )
                    .focused($focusedField, equals: .meaning(word.id))
                    .onChange(of: focusedField) { oldValue, newValue in
                      if newValue == .meaning(word.id) {
                        isAdding = true
                      }
                    }
                    .cornerRadius(10)
                    .onChange(of: word.meaning) { _, _ in
                      modelData.saveWord(word) // ✅ Firestore에 저장
                    }

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
            }
            .navigationTitle(modelData.selectedGroup?.name ?? "그룹명")
            .toolbar {
#if DEBUG
              ToolbarItem(placement: .navigationBarLeading) {
                Button {
                  modelData.words = modelData.getSampleWords()
                  modelData.words.forEach { modelData.saveWord($0) }
                  isAdding = false
                  
                  // ✅ Firestore에 샘플 단어 저장
//                  for word in modelData.words {
//                    modelData.saveWord(word)
//                  }
                  
                } label: {
                  Text("샘플")
                }
              }
              ToolbarItem(placement: .navigationBarLeading) {
                Button {
                  isAdding = false
                  DispatchQueue.main.async {
                    modelData.words.forEach { modelData.deleteWord($0) }
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
                    selectedWords.removeAll()
                  }
                } label: {
                  Text(isEditing ? "완료" : "편집")
                }
                .disabled(modelData.words.isEmpty || isAdding)
              }
              ToolbarItem(placement: .navigationBarTrailing) {
                if isEditing {
                  Button(action: deleteSelectedWords) {
                    Text("삭제")
                  }
                  .disabled(selectedWords.isEmpty)
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
              .presentationDetents([.fraction(0.2)])
              .presentationDragIndicator(.visible)
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
      }

      let isButtonEnabled = !(modelData.words.isEmpty || modelData.words.contains(where: { $0.name.isEmpty }) || isEditing)

      if !isAdding {
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

  func toggleSelection(for id: UUID) {
    if selectedWords.contains(id) {
      selectedWords.remove(id)
    } else {
      selectedWords.insert(id)
    }
  }

  func deleteSelectedWords() {
    for word in modelData.words where selectedWords.contains(word.id) {
      modelData.deleteWord(word)
    }
    modelData.words.removeAll { selectedWords.contains($0.id) }
    selectedWords.removeAll()
    if modelData.words.isEmpty {
      isEditing = false
    }
  }

  func removeEmptyWords() {
    focusedField = nil
    DispatchQueue.main.async {
      isAdding = false
      let emptyWords = modelData.words.filter { $0.name.isEmpty }
      emptyWords.forEach { modelData.deleteWord($0) }
      modelData.words.removeAll { $0.name.isEmpty }
    }
  }

  func addWord(proxy: ScrollViewProxy) {
    if case .meaning(let currentWordId) = focusedField {
      if let index = modelData.words.firstIndex(where: { $0.id == currentWordId }) {
        if modelData.words[index].name.isEmpty {
          let wordToDelete = modelData.words[index]
          modelData.words.remove(at: index)
          modelData.deleteWord(wordToDelete)
          focusedField = nil
          isAdding = false
          return
        }
      }
    }

    let newWord = Word(name: "", meaning: "", isKnowWord: false, knowTime: 0)
    modelData.words.append(newWord)
    modelData.saveWord(newWord)
    isAdding = true

    DispatchQueue.main.async {
      focusedField = .word(newWord.id)
    }
  }

  func deleteWord(at offsets: IndexSet) {
    for index in offsets {
      let word = modelData.words[index]
      modelData.deleteWord(word)
    }
    modelData.words.remove(atOffsets: offsets)
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

// 모르는 단어만/전체 학습 옵션
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
      Divider().frame(height: 2).background(Color.gray)
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
