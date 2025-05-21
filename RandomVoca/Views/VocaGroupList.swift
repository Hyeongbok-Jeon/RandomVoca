//import SwiftUI
//
//struct VocaGroupList: View {
//  @EnvironmentObject var modelData: ModelData
//  @State private var showAddGroupPopup = false
//  @State private var newGroupName: String = ""
//  @State private var showEmptyNameAlert = false
//  
//  @State private var editingGroup: VocaGroup?
//  @State private var newEditedGroupName: String = ""
//  
//  // 삭제 확인 팝업 상태 변수
//  @State private var showDeleteConfirmation = false
//  @State private var groupToDelete: VocaGroup?
//  
//  // 🚨 빈칸 체크 상태 변수
//  @State private var isNameEmpty = false
//  @State private var isEditedNameEmpty = false
//  
//  var body: some View {
//    NavigationStack {
//      VStack {
//        ScrollView {
//          if modelData.groups.isEmpty {
//            VStack(spacing: 20) {
//              Image(systemName: "book.fill")
//                .font(.system(size: 60))
//                .foregroundColor(.gray)
//              
//              Text("단어 그룹을 추가하고 학습을 시작하세요!")
//                .font(.title2)
//                .multilineTextAlignment(.center)
//                .foregroundColor(.primary)
//                .padding(.horizontal, 30)
//              
//              Text("단어 그룹을 만들면, 원하는 단어들을 저장하고 랜덤으로 학습할 수 있습니다.")
//                .font(.body)
//                .multilineTextAlignment(.center)
//                .foregroundColor(.gray)
//                .padding(.horizontal, 30)
//              
//              Button(action: { showAddGroupPopup = true }) {
//                Label("새 그룹 만들기", systemImage: "plus.circle.fill")
//                  .font(.title3)
//                  .padding()
//                  .frame(width: 200)
//                  .background(Color.blue)
//                  .foregroundColor(.white)
//                  .clipShape(RoundedRectangle(cornerRadius: 10))
//                  .shadow(radius: 3)
//              }
//            }
//            .padding(.top, 50)
//          } else {
//            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 20) {
//              ForEach($modelData.groups) { $group in
//                NavigationLink(destination: VocaList()) {
//                  VStack {
//                    Text(group.name)
//                      .font(.title3)
//                      .bold()
//                      .foregroundColor(.primary)
//                      .padding()
//                  }
//                  .frame(width: 160, height: 100)
//                  .background(
//                    RoundedRectangle(cornerRadius: 10)
//                      .fill(Color(UIColor.systemBackground))
//                      .shadow(color: Color.primary.opacity(0.2), radius: 5, x: 2, y: 2)
//                  )
//                  //                                    .overlay(
//                  //                                        RoundedRectangle(cornerRadius: 10)
//                  //                                            .stroke(Color.primary.opacity(0.7), lineWidth: 2)
//                  //                                    )
//                }
//                .simultaneousGesture(TapGesture().onEnded {
//                  modelData.selectedGroup = group
//                })
//                .contextMenu {
//                  Button("그룹명 변경") {
//                    editingGroup = group
//                    newEditedGroupName = group.name
//                  }
//                  Button("그룹 삭제", role: .destructive) {
//                    groupToDelete = group
//                    showDeleteConfirmation = true
//                  }
//                }
//              }
//            }
//            .padding(.horizontal, 20)
//            .padding(.vertical, -30)
//          }
//        }
//        
////        BannerAdView() // ✅ 하단 고정 광고
////          .frame(height: 50)
//      }
//      //            .navigationTitle("홈")
//      .toolbar {
//        ToolbarItem(placement: .principal) {
//          Text("단어 그룹")
//            .font(.title2) // 또는 .title, .title2 등
//        }
//        
//        if !modelData.groups.isEmpty {
//          ToolbarItem(placement: .navigationBarTrailing) {
//            Button(action: { showAddGroupPopup = true }) {
//              Image(systemName: "plus.circle.fill")
//                .font(.title3)
//                .foregroundColor(.primary)
//            }
//          }
//        }
//      }
//      .alert("새 그룹 추가", isPresented: $showAddGroupPopup) {
//        TextField("그룹 이름", text: $newGroupName)
//          .overlay(
//            RoundedRectangle(cornerRadius: 10)
//              .stroke(isNameEmpty ? Color.red : Color.clear, lineWidth: 2) // 🚨 빈칸일 때 빨간 테두리
//          )
//        
//        Button("추가") {
//          if newGroupName.trimmingCharacters(in: .whitespaces).isEmpty {
//            isNameEmpty = true // 🚨 빈칸일 때 빨간 테두리
//          } else {
//            let newGroup = VocaGroup(name: newGroupName, words: [])
//            modelData.groups.append(newGroup)
//            modelData.saveGroups()
//            newGroupName = ""
//          }
//        }
//        Button("취소", role: .cancel) {
//          newGroupName = ""
//        }
//      }
//      .alert("그룹명 변경", isPresented: Binding<Bool>(
//        get: { editingGroup != nil },
//        set: { if !$0 { editingGroup = nil } }
//      )) {
//        TextField("새 그룹명", text: $newEditedGroupName)
//        Button("저장") {
//          if let editingGroup = editingGroup,
//             let index = modelData.groups.firstIndex(where: { $0.id == editingGroup.id }) {
//            modelData.groups[index].name = newEditedGroupName
//            modelData.saveGroups()
//          }
//          editingGroup = nil
//        }
//        Button("취소", role: .cancel) {
//          editingGroup = nil
//        }
//      } message: {
//        Text("새 그룹명을 입력해주세요")
//      }
//      // 🌟 삭제 확인 팝업
//      .alert("그룹 삭제", isPresented: $showDeleteConfirmation) {
//        Button("삭제", role: .destructive) {
//          if let group = groupToDelete {
//            deleteGroup(group: group)
//          }
//        }
//        Button("취소", role: .cancel) {
//          groupToDelete = nil
//        }
//      } message: {
//        Text("그룹 내 단어가 모두 삭제됩니다.")
//      }
//      .background(Color(UIColor.systemGray6).ignoresSafeArea())
//    }
//  }
//  
//  // 그룹 삭제 함수
//  func deleteGroup(group: VocaGroup) {
//    modelData.groups.removeAll { $0.id == group.id }
//    if modelData.selectedGroup?.id == group.id {
//      modelData.selectedGroup = nil
//    }
//    modelData.saveGroup()
//  }
//}
//
//#Preview {
//  VocaGroupList()
//    .environmentObject(ModelData())
//  //        .preferredColorScheme(.dark)
//}




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
//          } else if modelData.groups.isEmpty {
//            VStack {
//              Image(systemName: "book.fill")
//                .font(.system(size: 60))
//                .foregroundColor(.gray)

//              Text("단어 그룹을 추가하고 학습을 시작하세요!")
//                .font(.title2)
//                .multilineTextAlignment(.center)
//                .foregroundColor(.primary)
////                .padding(.horizontal, 30)
//
//              Text("단어 그룹을 만들면, 원하는 단어들을 저장하고 랜덤으로 학습할 수 있습니다.")
//                .font(.body)
//                .multilineTextAlignment(.center)
//                .foregroundColor(.gray)
////                .padding(.horizontal, 30)
//
//              Button(action: { showAddGroupPopup = true }) {
//                Label("새 그룹 만들기", systemImage: "plus.circle.fill")
//                  .font(.title3)
//                  .padding()
//                  .frame(width: 200)
//                  .background(Color.blue)
//                  .foregroundColor(.white)
//                  .clipShape(RoundedRectangle(cornerRadius: 10))
//                  .shadow(radius: 3)
//              }
//            }
//            .padding(.top, 50)
            
//            Spacer().frame(height: 50)
//
//            HStack {
//              Spacer()
//              Text("그룹을 추가해주세요.")
//              Spacer()
//            }
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

//                  Text("새 그룹")
//                    .font(.subheadline)
//                    .foregroundColor(.white) // ✅ 흰색 텍스트
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

//        if !modelData.groups.isEmpty {
//          ToolbarItem(placement: .navigationBarTrailing) {
//            Button(action: { showAddGroupPopup = true }) {
//              Image(systemName: "plus.circle.fill")
//                .font(.title3)
//                .foregroundColor(.primary)
//            }
//          }
//        }
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
