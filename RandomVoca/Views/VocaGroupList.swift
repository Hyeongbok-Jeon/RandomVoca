import SwiftUI

struct VocaGroupList: View {
    @EnvironmentObject var modelData: ModelData
    @State private var showAddGroupPopup = false
    @State private var newGroupName: String = ""
    
    // 그룹명 수정 시 사용되는 상태 변수
    @State private var editingGroup: VocaGroup?
    @State private var newEditedGroupName: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                    // ForEach 에서 바인딩($modelData.groups)을 사용하면,
                    // 패턴에서 $group을 사용하여 동적 멤버 접근이 가능해집니다.
                    ForEach($modelData.groups) { $group in
                        NavigationLink(destination: VocaList()) {
                            VStack {
                                // 동적 멤버 접근을 사용하여 group.name으로 접근 (wrappedValue를 명시하지 않아도 됩니다)
                                Text(group.name)
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding()
                            }
                            .frame(width: 150, height: 150)
                            .background(Color.blue)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            // 그룹 선택 시, 선택된 그룹은 실제 값(group)로 전달됩니다.
                            modelData.selectedGroup = group
                        })
                        .contextMenu {
                            Button("그룹명 변경") {
                                editingGroup = group
                                newEditedGroupName = group.name
                            }
                            Button("그룹 삭제", role: .destructive) {
                                deleteGroup(group: group)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("단어 그룹")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddGroupPopup = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            // 새 그룹 추가 알럿
            .alert("새 그룹 추가", isPresented: $showAddGroupPopup) {
                TextField("그룹 이름", text: $newGroupName)
                Button("추가") {
                    let newGroup = VocaGroup(name: newGroupName, words: [])
                    modelData.groups.append(newGroup)
                    modelData.saveGroups()
                    newGroupName = ""
                }
                Button("취소", role: .cancel) {}
            }
            // 그룹명 변경 알럿: editingGroup이 nil이 아닐 때 표시
            .alert("그룹명 변경", isPresented: Binding<Bool>(
                get: { editingGroup != nil },
                set: { if !$0 { editingGroup = nil } }
            )) {
                TextField("새 그룹명", text: $newEditedGroupName)
                Button("저장") {
                    if let editingGroup = editingGroup,
                       let index = modelData.groups.firstIndex(where: { $0.id == editingGroup.id }) {
                        modelData.groups[index].name = newEditedGroupName
                        modelData.saveGroups()
                    }
                    editingGroup = nil
                }
                Button("취소", role: .cancel) {
                    editingGroup = nil
                }
            } message: {
                Text("새 그룹명을 입력해주세요")
            }
        }
    }
    
    // 그룹 삭제 함수
    func deleteGroup(group: VocaGroup) {
        modelData.groups.removeAll { $0.id == group.id }
        if modelData.selectedGroup?.id == group.id {
            modelData.selectedGroup = nil
        }
        modelData.saveGroups()
    }
}

#Preview {
    VocaGroupList()
        .environmentObject(ModelData())
        .preferredColorScheme(.dark)
}
