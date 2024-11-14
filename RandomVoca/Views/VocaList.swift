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
        
        @FocusState private var focusedField: FocusField?  // 포커스 관리용 변수
        
        var body: some View {
            NavigationStack {
                List {
                    if modelData.words.isEmpty {
                        HStack {
                            Spacer()
                            Text("단어를 추가해주세요.")
                            Spacer()
                        }
                    } else {
                        ForEach($modelData.words) { $word in
                            HStack {
                                TextField("단어", text: $word.name)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(maxWidth: .infinity)
                                    .multilineTextAlignment(.center)  // 텍스트 가운데 정렬
                                    .focused($focusedField, equals: .word(word.id))  // 포커스 설정
                                    .onChange(of: focusedField) { oldFocus, newFocus in
                                        // 단어 필드에서 다른 곳으로 포커스 이동
                                        if oldFocus == .word(word.id) && newFocus != .word(word.id) {
                                            if word.name.isEmpty {
                                                removeEmptyWord()
                                            } else {
                                                print("else")
                                                // word.name 값을 변경
                                                DispatchQueue.main.async {
                                                    word.name = word.name.lowercased()
                                                }
                                            }
                                        }
                                        
                                        
//                                        if newFocus == nil {
//                                            modelData.loadWords()
//                                        }
//                                        // 포커스가 사라졌을 때 빈 단어를 삭제하거나 저장하는 로직
//                                        if newFocus != .word(word.id) && word.name.isEmpty {
//                                            removeEmptyWord()
//                                        }
                                    }
                                    .autocapitalization(.none)  // 대문자 자동 입력 비활성화
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                                
                                TextField("뜻", text: $word.meaning)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(maxWidth: .infinity)
                                    .multilineTextAlignment(.center)  // 텍스트 가운데 정렬
                                    .focused($focusedField, equals: .meaning(word.id))  // 포커스 설정
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                                
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
                            NavigationLink(destination: Play(playMode: "part")) {
                                Image(systemName: "play.fill")
                            }
                            .simultaneousGesture(TapGesture().onEnded {
                                focusedField = nil  // Play 버튼 누를 때 포커스 해제
                            })
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: addWord) {
                            Image(systemName: "plus")
                        }
                    }
                }
                
                Spacer()
            }
        }
        
        // 빈 단어 제거 함수
        func removeEmptyWord() {
            focusedField = nil
            
            DispatchQueue.main.async {
                modelData.words.removeAll { word in
                    word.name.isEmpty
                }
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
                modelData.words.append(newWord)
                focusedField = .word(newWord.id)
            }
        }
        
        // 단어 삭제 함수
        func deleteWord(at offsets: IndexSet) {
            modelData.words.remove(atOffsets: offsets) // 기본 리스트에서 삭제
        }
    }

    #Preview {
        VocaList()
            .environmentObject(ModelData())
            .preferredColorScheme(.dark)
    }
