import SwiftUI

struct VocaGroupList: View {
  @EnvironmentObject var modelData: ModelData
  @State private var showAddGroupPopup = false
  @State private var newGroupName: String = ""
  @State private var showEmptyNameAlert = false

  @State private var editingGroup: VocaGroup?
  @State private var newEditedGroupName: String = ""

  @State private var showDeleteConfirmation = false
  @State private var groupToDelete: VocaGroup?

  @State private var isNameEmpty = false
  @State private var isEditedNameEmpty = false

  var body: some View {
    NavigationStack {
      VStack {
        ScrollView {
          if modelData.isGroupLoading {
            VStack(spacing: 20) {
              ProgressView()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 100)
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
                  .frame(width: 160, height: 100)
                  .background(
                    RoundedRectangle(cornerRadius: 10)
                      .fill(Color(UIColor.systemBackground))
                      .shadow(color: Color.primary.opacity(0.2), radius: 5, x: 2, y: 2)
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
                    groupToDelete = group
                    showDeleteConfirmation = true
                  }
                }
              }
              
              // ➕ 새 그룹 추가 버튼
              Button(action: {
                showAddGroupPopup = true
              }) {
                VStack(spacing: 8) {
                  Image(systemName: "plus")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white) // ✅ 흰색 아이콘
                }
                .frame(width: 160, height: 100)
                .background(
                  RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white) // ✅ 흰색 dashed 테두리
                )
              }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, -30)
          }
        }
      }
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text("단어 그룹")
            .font(.title2)
        }
      }
      .alert("새 그룹 추가", isPresented: $showAddGroupPopup) {
        TextField("그룹 이름", text: $newGroupName)
          .overlay(
            RoundedRectangle(cornerRadius: 10)
              .stroke(isNameEmpty ? Color.red : Color.clear, lineWidth: 2)
          )

        Button("추가") {
          if newGroupName.trimmingCharacters(in: .whitespaces).isEmpty {
            isNameEmpty = true
          } else {
            let newGroup = VocaGroup(name: newGroupName)
            modelData.groups.append(newGroup)
            modelData.saveGroup(newGroup)
            newGroupName = ""
          }
        }
        Button("취소", role: .cancel) {
          newGroupName = ""
        }
      }
      .alert("그룹명 변경", isPresented: Binding<Bool>(
        get: { editingGroup != nil },
        set: { if !$0 { editingGroup = nil } }
      )) {
        TextField("새 그룹명", text: $newEditedGroupName)
        Button("저장") {
          if let editingGroup = editingGroup,
             let index = modelData.groups.firstIndex(where: { $0.id == editingGroup.id }) {
            modelData.groups[index].name = newEditedGroupName
            modelData.saveGroup(modelData.groups[index])
          }
          editingGroup = nil
        }
        Button("취소", role: .cancel) {
          editingGroup = nil
        }
      } message: {
        Text("새 그룹명을 입력해주세요")
      }
      .alert("그룹 삭제", isPresented: $showDeleteConfirmation) {
        Button("삭제", role: .destructive) {
          if let group = groupToDelete {
            deleteGroup(group: group)
          }
        }
        Button("취소", role: .cancel) {
          groupToDelete = nil
        }
      } message: {
        Text("그룹 내 단어가 모두 삭제됩니다.")
      }
      .background(Color(UIColor.systemGray6).ignoresSafeArea())
    }
  }

  func deleteGroup(group: VocaGroup) {
    modelData.deleteGroup(group)
  }
}

#Preview {
  VocaGroupList()
    .environmentObject(ModelData())
}
