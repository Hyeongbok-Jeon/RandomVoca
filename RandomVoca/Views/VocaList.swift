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
    
    @FocusState private var focusedField: FocusField?  // 포커스 관리용 변수
    
    var body: some View {
        NavigationStack {
            List {
                if modelData.words.isEmpty {
                    HStack {
                        Spacer()
                        Text("단어를 추가해주세요..")
                        Spacer()
                    }
                } else {
                    ForEach($modelData.words) { $word in
                        HStack {
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
                                .multilineTextAlignment(.center)  // 텍스트 가운데 정렬
                            
                            TextField("뜻", text: $word.meaning)
                                .focused($focusedField, equals: .meaning(word.id))  // 포커스 설정
                                .textFieldStyle(.roundedBorder)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)  // 텍스트 가운데 정렬
                            
                            Text("\(String(word.knowTime)) 초")
                                .frame(maxWidth: .infinity)
                            
                            Circle()
                                .fill(word.isKnowWord ? Color.green : Color.red)
                                .frame(width: 10, height: 10)
                            //                                    .frame(maxWidth: .infinity)
                        }
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
                if !modelData.words.isEmpty && modelData.words.contains(where: { !$0.name.isEmpty }) {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showPlayOptions = true
                        } label: {
                            Image(systemName: "play.fill")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addWord) {
                        Image(systemName: "plus")
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
                .presentationDetents([.fraction(0.3)]) // 높이를 30% 또는 50%로 설정
                .presentationDragIndicator(.visible) // 드래그 바 표시
            }
            .background(
                NavigationLink(
                    destination: Play(playMode: selectedPlayMode),
                    isActive: $navigateToPlay,
                    label: { EmptyView() }
                )
                .hidden()
            )
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
    func addWord() {
        if let lastWord = modelData.words.last, lastWord.name.isEmpty {
            // 이미 빈 단어가 있을 경우 그 단어에 포커스 맞추기
            focusedField = .word(lastWord.id)
        } else {
            // 새 단어 추가
            let newWord = Word(name: "", meaning: "", isKnowWord: false, knowTime: 0)
            modelData.words.insert(newWord, at: 0)
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
    var onSelect: (String) -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            Button {
                onSelect("all")
            } label: {
                Text("전체 재생")
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
                Text("모르는 단어만 재생")
                    .font(.title)
            }
            
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
