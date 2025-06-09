import Foundation
import FirebaseFirestore
import FirebaseAuth

class ModelData: ObservableObject {
  @Published var words: [Word] = []
  @Published var groups: [VocaGroup] = []
  @Published var selectedGroup: VocaGroup? {
    didSet {
      if let group = selectedGroup {
        fetchWords(for: group)
      }
    }
  }
  @Published var isGroupLoading = true

  private var db = Firestore.firestore()
  private var uid: String? {
    Auth.auth().currentUser?.uid
  }

  init() {
    NotificationCenter.default.addObserver(self, selector: #selector(handleMigration), name: .didMigrateLocalData, object: nil)
    
    fetchGroups()
  }

  @objc func handleMigration() {
    fetchGroups()
  }
  // MARK: - 단어 저장 및 불러오기 (Firestore)

  func fetchWords(for group: VocaGroup) {
    guard let uid else { return }

    db.collection("users")
      .document(uid)
      .collection("groups")
      .document(group.id.uuidString)
      .collection("words")
      .getDocuments { snapshot, error in
        if let error = error {
          print("[Error] 단어 불러오기 실패: \(error.localizedDescription)")
          self.words = []
          return
        }

        self.words = snapshot?.documents.compactMap { doc in
          let data = doc.data()
          return Word(
            id: UUID(uuidString: doc.documentID) ?? UUID(),
            name: data["name"] as? String ?? "",
            meaning: data["meaning"] as? String ?? "",
            isKnowWord: data["isKnowWord"] as? Bool ?? false,
            knowTime: data["knowTime"] as? Double ?? 0
          )
        } ?? []
      }
  }

  func saveWord(_ word: Word) {
    guard let uid, let group = selectedGroup else { return }

    let ref = db.collection("users")
      .document(uid)
      .collection("groups")
      .document(group.id.uuidString)
      .collection("words")
      .document(word.id.uuidString)

    let data: [String: Any] = [
      "name": word.name,
      "meaning": word.meaning,
      "isKnowWord": word.isKnowWord,
      "knowTime": word.knowTime
    ]

    ref.setData(data)
  }

  func deleteWord(_ word: Word) {
    guard let uid, let group = selectedGroup else { return }

    let ref = db.collection("users")
      .document(uid)
      .collection("groups")
      .document(group.id.uuidString)
      .collection("words")
      .document(word.id.uuidString)

    ref.delete()
    words.removeAll { $0.id == word.id }
  }

  // MARK: - 그룹 저장 및 불러오기 (Firestore)

  func fetchGroups() {
    guard let uid else {
      print("[Error] 로그인되지 않음 → 그룹 불러오기 건너뜀")
      self.groups = []
      self.isGroupLoading = false // ✅ 이 줄 추가!
      return
    }
    
    isGroupLoading = true

    db.collection("users")
      .document(uid)
      .collection("groups")
      .getDocuments { snapshot, error in
        self.isGroupLoading = false  // ✅ 여기!
        
        if let error = error {
          print("[Error] 그룹 불러오기 실패: \(error.localizedDescription)")
          self.groups = []
          return
        }

        self.groups = snapshot?.documents.compactMap { doc in
          let data = doc.data()
          return VocaGroup(
            id: UUID(uuidString: doc.documentID) ?? UUID(),
            name: data["name"] as? String ?? ""
          )
        } ?? []
      }
  }

  func saveGroup(_ group: VocaGroup) {
    guard let uid else { return }

    let ref = db.collection("users")
      .document(uid)
      .collection("groups")
      .document(group.id.uuidString)

    let data: [String: Any] = ["name": group.name]
    ref.setData(data)
  }

  func deleteGroup(_ group: VocaGroup) {
    guard let uid else { return }

    let groupRef = db.collection("users")
      .document(uid)
      .collection("groups")
      .document(group.id.uuidString)

    groupRef.delete()
    
    groups.removeAll { $0.id == group.id }
    if selectedGroup?.id == group.id {
      selectedGroup = nil
      words = []
    }
  }

  func selectGroup(_ group: VocaGroup) {
    selectedGroup = group
  }
  
#if DEBUG
  func getSampleWords() -> [Word] {
    return [
      Word(name: "betray", meaning: "배신하다", isKnowWord: false, knowTime: 99.99),
      Word(name: "apply", meaning: "지원하다", isKnowWord: false, knowTime: 999.999),
      Word(name: "celebrate", meaning: "축하하다", isKnowWord: false, knowTime: 0),
      Word(name: "choose", meaning: "선택하다", isKnowWord: false, knowTime: 0),
      Word(name: "complain", meaning: "불평하다", isKnowWord: false, knowTime: 0),
      Word(name: "decide", meaning: "결정하다", isKnowWord: false, knowTime: 0),
      Word(name: "deny", meaning: "부인하다", isKnowWord: false, knowTime: 0),
      Word(name: "explain", meaning: "설명하다", isKnowWord: false, knowTime: 0),
      Word(name: "guess", meaning: "추측하다", isKnowWord: false, knowTime: 0),
      Word(name: "hurry", meaning: "서두르다", isKnowWord: false, knowTime: 0),
      Word(name: "imagine", meaning: "상상하다", isKnowWord: false, knowTime: 0),
      Word(name: "improve", meaning: "개선하다", isKnowWord: false, knowTime: 0),
      Word(name: "interrupt", meaning: "방해하다", isKnowWord: false, knowTime: 0),
      Word(name: "invite", meaning: "초대하다", isKnowWord: false, knowTime: 0),
      Word(name: "offer", meaning: "제안하다", isKnowWord: false, knowTime: 0),
      Word(name: "pretend", meaning: "척하다", isKnowWord: false, knowTime: 0),
      Word(name: "protect", meaning: "보호하다", isKnowWord: false, knowTime: 0),
      Word(name: "realize", meaning: "깨닫다", isKnowWord: false, knowTime: 0),
      Word(name: "recommend", meaning: "추천하다", isKnowWord: false, knowTime: 0),
      Word(name: "reduce", meaning: "줄이다", isKnowWord: false, knowTime: 0),
      Word(name: "refuse", meaning: "거절하다", isKnowWord: false, knowTime: 0),
      Word(name: "regret", meaning: "후회하다", isKnowWord: false, knowTime: 0),
      Word(name: "remember", meaning: "기억하다", isKnowWord: false, knowTime: 0),
      Word(name: "respect", meaning: "존경하다", isKnowWord: false, knowTime: 0),
      Word(name: "return", meaning: "돌아오다", isKnowWord: false, knowTime: 0),
      Word(name: "share", meaning: "공유하다", isKnowWord: false, knowTime: 0),
      Word(name: "shout", meaning: "외치다", isKnowWord: false, knowTime: 0),
      Word(name: "suggest", meaning: "제안하다", isKnowWord: false, knowTime: 0),
      Word(name: "survive", meaning: "생존하다", isKnowWord: false, knowTime: 0),
      Word(name: "trust", meaning: "믿다", isKnowWord: false, knowTime: 0),
      Word(name: "understand", meaning: "이해하다", isKnowWord: false, knowTime: 0),
      Word(name: "visit", meaning: "방문하다", isKnowWord: false, knowTime: 0),
      Word(name: "agree", meaning: "동의하다", isKnowWord: false, knowTime: 0),
      Word(name: "arrive", meaning: "도착하다", isKnowWord: false, knowTime: 0),
      Word(name: "assist", meaning: "돕다", isKnowWord: false, knowTime: 0),
      Word(name: "avoid", meaning: "피하다", isKnowWord: false, knowTime: 0),
      Word(name: "borrow", meaning: "빌리다", isKnowWord: false, knowTime: 0),
      Word(name: "bring", meaning: "가져오다", isKnowWord: false, knowTime: 0),
      Word(name: "build", meaning: "짓다", isKnowWord: false, knowTime: 0),
      Word(name: "carry", meaning: "운반하다", isKnowWord: false, knowTime: 0),
      Word(name: "catch", meaning: "잡다", isKnowWord: false, knowTime: 0),
      Word(name: "change", meaning: "변경하다", isKnowWord: false, knowTime: 0),
      Word(name: "clean", meaning: "청소하다", isKnowWord: false, knowTime: 0),
      Word(name: "close", meaning: "닫다", isKnowWord: false, knowTime: 0),
      Word(name: "connect", meaning: "연결하다", isKnowWord: false, knowTime: 0),
      Word(name: "control", meaning: "통제하다", isKnowWord: false, knowTime: 0),
      Word(name: "create", meaning: "창조하다", isKnowWord: false, knowTime: 0),
      Word(name: "decide", meaning: "결정하다", isKnowWord: false, knowTime: 0)
    ]
  }
#endif
}
