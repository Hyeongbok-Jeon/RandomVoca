import SwiftUI

struct VocaGroupList: View {
    @EnvironmentObject var modelData: ModelData
    @State private var showAddGroupPopup = false
    @State private var newGroupName: String = ""
    @State private var showEmptyNameAlert = false // 그룹명이 비어있을 때 얼럿 상태

    // 그룹명 수정 시 사용되는 상태 변수
    @State private var editingGroup: VocaGroup?
    @State private var newEditedGroupName: String = ""

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    Spacer().frame(height: 40) // 상단 여백 추가
                    
                    if modelData.groups.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "book.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("단어 그룹을 추가하고 학습을 시작하세요!")
                                .font(.title2)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 30)
                            
                            Text("단어 그룹을 만들면, 원하는 단어들을 저장하고 랜덤으로 학습할 수 있습니다.")
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 30)

                            Button(action: { showAddGroupPopup = true }) {
                                Label("새 그룹 만들기", systemImage: "plus.circle.fill")
                                    .font(.title3)
                                    .padding()
                                    .frame(width: 200)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .shadow(radius: 3)
                            }
                        }
                        .padding(.top, 50)
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 20) {
                            ForEach($modelData.groups) { $group in
                                NavigationLink(destination: VocaList()) {
                                    VStack {
                                        Text(group.name)
                                            .font(.title3)
                                            .bold()
                                            .foregroundColor(.primary)
                                            .padding()
                                    }
                                    .frame(width: 160, height: 160)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color(UIColor.systemBackground))
                                            .shadow(color: Color.primary.opacity(0.2), radius: 5, x: 2, y: 2)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.primary.opacity(0.7), lineWidth: 2)
                                    )
                                }
                                .simultaneousGesture(TapGesture().onEnded {
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
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("단어 그룹")
            .toolbar {
                if !modelData.groups.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showAddGroupPopup = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
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
//            .alert("알림", isPresented: $showEmptyNameAlert) { // 🚨 빈 그룹명 입력 시 얼럿
//                Text("그룹명을 입력해주세요.")
//                Button("확인", role: .cancel) {}
//            }
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
