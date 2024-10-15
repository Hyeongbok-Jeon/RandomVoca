import SwiftUI

struct VocaGroupList: View {
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @State private var vocaGroups: [WordGroup] = []
    @State private var isEditing = false
    @State private var showAlert = false
    @State private var groupToDelete: WordGroup? = nil
    @State private var showPopup = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                if vocaGroups.isEmpty {
                    // 빈 상태 화면
                    Text("그룹을 추가해주세요.")
                        .font(.title)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(vocaGroups, id: \.self) { group in
                            // 그룹을 클릭하면 해당 그룹의 VocaList로 이동
                            NavigationLink(destination: VocaList()) {
                                VStack {
                                    Text(group.name)
                                        .font(.headline)
                                        .padding()
                                        .frame(maxWidth: .infinity, minHeight: 200)
                                        .background(Color.blue.opacity(0.7))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .overlay(
                                            // 삭제 버튼을 항목 왼쪽 상단에 정확하게 배치
                                            deleteButton(for: group),
                                            alignment: .topLeading
                                        )
                                        .onLongPressGesture {
                                            withAnimation {
                                                isEditing = true
                                            }
                                        }
                                }
                                .padding(10)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarTitle("단어 그룹", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        vocaGroups.removeAll()
                        saveGroups()
                    } label: {
                        Text("모두 삭제")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation {
                            isEditing.toggle()
                        }
                    } label: {
                        if isEditing {
                            Text("취소")
                        } else {
                            Text("편집")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation {
                            isEditing = false
                        }
                        addNewGroup()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                loadGroups()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("단어 그룹 삭제"),
                    message: Text("\(groupToDelete?.name ?? "그룹") 삭제하시겠습니까?"),
                    primaryButton: .destructive(Text("삭제")) {
                        if let group = groupToDelete {
                            deleteGroup(group)
                        }
                    },
                    secondaryButton: .cancel(Text("취소"))
                )
            }
        }
    }
    
    // 삭제 버튼 뷰
    @ViewBuilder
    private func deleteButton(for group: WordGroup) -> some View {
        if isEditing {
            Button {
                // 삭제 확인을 위해 Alert를 띄움
                groupToDelete = group
                showAlert = true
            } label: {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
                    .padding(8)
            }
            .background(Color.white.opacity(0.0)) // 투명 배경을 추가해 정확한 터치 영역 확보
            .offset(x: -15, y: -15) // 버튼이 모서리 밖으로 살짝 나가도록 위치 조정
            .transition(.scale)
        }
    }
    
    // 새 그룹 추가 함수
    private func addNewGroup() {
        let newGroup = WordGroup(name: "새 그룹 \(vocaGroups.count + 1)")
        vocaGroups.append(newGroup)
        saveGroups()
    }
    
    // 그룹 삭제 함수
    private func deleteGroup(_ group: WordGroup) {
        if let index = vocaGroups.firstIndex(of: group) {
            vocaGroups.remove(at: index)
            saveGroups()
        }
    }
    
    // 그룹 저장 함수
    private func saveGroups() {
        if let data = try? JSONEncoder().encode(vocaGroups) {
            UserDefaults.standard.set(data, forKey: "vocaGroups")
        }
    }
    
    // 그룹 불러오기 함수
    private func loadGroups() {
        if let data = UserDefaults.standard.data(forKey: "vocaGroups"),
           let savedGroups = try? JSONDecoder().decode([WordGroup].self, from: data) {
            vocaGroups = savedGroups
        }
    }
}

#Preview {
    VocaGroupList()
}
