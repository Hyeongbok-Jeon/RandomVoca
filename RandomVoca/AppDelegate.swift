import UIKit
import SwiftUI
import GoogleMobileAds
import UserNotifications
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
  
  var window: UIWindow?
  var selectedWord: String? // ✅ 알림에서 받은 단어 저장
  
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // ✅ 최신 AdMob 초기화 코드
    MobileAds.shared.start(completionHandler: nil)
    print("✅ Google Mobile Ads SDK 초기화 완료")
    //        UNUserNotificationCenter.current().delegate = self
    //        NotificationManager.shared.requestNotificationPermission() // ✅ 앱 실행 시 알림 권한 요청 및 설정
    
    // ✅ Firebase 초기화
    FirebaseApp.configure()
    print("✅ FirebaseApp configured: \(FirebaseApp.app() != nil)")
    
    // ✅ 현재 인증 상태 확인 후 처리
    checkAuthValidity()
    
    return true
  }
  
  //    func userNotificationCenter(
  //        _ center: UNUserNotificationCenter,
  //        willPresent notification: UNNotification,
  //        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  //    ) {
  //        completionHandler([.banner, .sound])
  //    }
  //
  //    func userNotificationCenter(
  //        _ center: UNUserNotificationCenter,
  //        didReceive response: UNNotificationResponse,
  //        withCompletionHandler completionHandler: @escaping () -> Void
  //    ) {
  //        // ✅ 알림에서 단어 정보 추출
  //        let userInfo = response.notification.request.content.userInfo
  //        if let word = userInfo["word"] as? String {
  //            selectedWord = word
  //            DispatchQueue.main.async {
  //                self.navigateToPlayScreen(with: word)
  //            }
  //        }
  //        completionHandler()
  //    }
  //
  //    // ✅ PlayV2 화면으로 이동 + 단어 전달
  //    private func navigateToPlayScreen(with word: String) {
  //        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
  //           let window = windowScene.windows.first {
  //            let modelData = ModelDataV2()
  //            let rootView = PlayV2(initialWord: word) // ✅ 초기 단어 전달
  //                .environmentObject(modelData)
  //            window.rootViewController = UIHostingController(rootView: rootView)
  //            window.makeKeyAndVisible()
  //        }
  //    }

  /// ✅ 현재 인증 상태 확인
  func checkAuthValidity() {
    if let user = Auth.auth().currentUser {
      user.getIDTokenResult { _, error in
        if let error = error {
          print("❌ 인증 유효성 실패 → 로그아웃 및 재로그인: \(error.localizedDescription)")
          try? Auth.auth().signOut()
          self.signInAnonymouslyIfNeeded()
        } else {
          print("✅ 유효한 로그인 상태, UID: \(user.uid)")
        }
      }
    } else {
      print("🔓 로그인되어 있지 않음 → 익명 로그인 시도")
      signInAnonymouslyIfNeeded()
    }
  }

  /// ✅ 익명 로그인 수행
  func signInAnonymouslyIfNeeded() {
    if Auth.auth().currentUser == nil {
      Auth.auth().signInAnonymously { result, error in
        if let error = error {
          print("익명 로그인 실패: \(error)")
          return
        }
        print("익명 로그인 성공, UID: \(result?.user.uid ?? "")")
        self.createUserDocumentIfNeeded() // ✅ 문서 생성으로 변경
      }
    } else {
      print("이미 로그인된 UID: \(Auth.auth().currentUser?.uid ?? "")")
      self.createUserDocumentIfNeeded() // ✅ 문서 생성으로 변경
    }
  }
  
  func createUserDocumentIfNeeded() {
    guard let uid = Auth.auth().currentUser?.uid else { return }

    let userDocRef = Firestore.firestore().collection("users").document(uid)
    userDocRef.getDocument { snapshot, error in
      if let error = error {
        print("❌ Firestore 유저 확인 실패: \(error.localizedDescription)")
        return
      }

      if snapshot?.exists == true {
        print("✅ Firestore에 사용자 문서 존재")
      } else {
        print("📄 Firestore에 사용자 문서 없음 → 새로 생성")
        userDocRef.setData(["createdAt": FieldValue.serverTimestamp()]) { error in
          if let error = error {
            print("❌ 사용자 문서 생성 실패: \(error.localizedDescription)")
          } else {
            print("✅ 사용자 문서 생성 완료")
            
            /// ✅ 마이그레이션 시작
            if self.hasLocalData() {
              self.migrateLocalDataToFirestore(uid: uid)
            } else {
              print("📦 로컬 데이터 없음 → 마이그레이션 생략")
              NotificationCenter.default.post(name: .didMigrateLocalData, object: nil) // ✅ 강제 리프레시 유도
            }
          }
        }
      }
    }
  }
  
  func hasLocalData() -> Bool {
    let groupKey = "groups"
    if let data = UserDefaults.standard.data(forKey: groupKey),
       let groups = try? JSONDecoder().decode([VocaGroup].self, from: data) {
      return !groups.isEmpty
    }
    return false
  }
  
  func migrateLocalDataToFirestore(uid: String) {
    let db = Firestore.firestore()
    let groupKey = "groups"

    guard let groupData = UserDefaults.standard.data(forKey: groupKey),
          let groups = try? JSONDecoder().decode([VocaGroup].self, from: groupData) else {
      print("❌ 그룹 로컬 데이터 없음")
      return
    }

    for group in groups {
      let groupRef = db.collection("users").document(uid).collection("groups").document(group.id.uuidString)
      groupRef.setData([
        "id": group.id.uuidString,
        "name": group.name,
        "createdAt": FieldValue.serverTimestamp()
      ]) { error in
        if let error = error {
          print("❌ 그룹 \(group.name) 업로드 실패: \(error.localizedDescription)")
        } else {
          print("✅ 그룹 \(group.name) 업로드 완료")
        }
      }

      // 각 단어 저장
      let wordKey = "words_\(group.id.uuidString)"
      if let wordData = UserDefaults.standard.data(forKey: wordKey),
         let words = try? JSONDecoder().decode([Word].self, from: wordData) {
        for word in words {
          let wordRef = groupRef.collection("words").document(word.id.uuidString)
          wordRef.setData([
            "id": word.id.uuidString,
            "name": word.name,
            "meaning": word.meaning,
            "isKnowWord": word.isKnowWord,
            "createdAt": FieldValue.serverTimestamp()
          ])
        }
      }
    }

    // AppDelegate.swift 마지막에
    print("🎉 로컬 데이터 마이그레이션 완료")
    NotificationCenter.default.post(name: .didMigrateLocalData, object: nil)
  }
}
