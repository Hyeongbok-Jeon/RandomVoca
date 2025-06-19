//
//  Setting.swift
//  RandomVoca
//
//  Created by Hyeongbok Jeon on 5/11/25.
//

import SwiftUI
import FirebaseAuth
import AuthenticationServices
import CryptoKit
import FirebaseFirestore

struct Setting: View {
  @State private var isLoggedIn = false
  @State private var currentNonce: String?
  @State private var showConflictDialog = false
  @State private var pendingCredential: AuthCredential? = nil
  @State private var showAppleRestoreAlert = false
  @State private var showDeleteConfirmAlert = false
  @StateObject private var donationManager = DonationManager()

  var body: some View {
    NavigationStack {
      Form {
        Section(header: Text("계정")) {
          if isLoggedIn {
            Text("Apple 계정으로 로그인됨")
              .foregroundColor(.green)
            
            Button("로그아웃") {
              logoutAndCloneFromAppleUID()
            }
            
            Button("계정 탈퇴", role: .destructive) {
              showDeleteConfirmAlert = true
            }
          } else {
            SignInWithAppleButton(.signIn, onRequest: { request in
              let nonce = randomNonceString()
              currentNonce = nonce
              request.requestedScopes = [.fullName, .email]
              request.nonce = sha256(nonce)
            }, onCompletion: { result in
              switch result {
              case .success(let authResults):
                if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
                  guard let nonce = currentNonce else {
                    fatalError("Invalid state: A login callback was received, but no login request was sent.")
                  }
                  guard let appleIDToken = appleIDCredential.identityToken,
                        let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to fetch identity token")
                    return
                  }

                  let credential = OAuthProvider.credential(
                    providerID: .apple,                // ✅ 여기!
                    idToken: idTokenString,
                    rawNonce: nonce,
                    accessToken: nil
                  )

                  if let user = Auth.auth().currentUser {
                    user.link(with: credential) { authResult, error in
                      if let error = error as NSError?,
                         error.code == AuthErrorCode.credentialAlreadyInUse.rawValue {

                        print("⚠️ 이미 연동된 Apple 계정 → 그냥 로그인 시도")
                        
                        if let updatedCredential = error.userInfo[AuthErrorUserInfoUpdatedCredentialKey] as? AuthCredential {
                          print("⚠️ 이미 연동된 Apple 계정 → 로그인 여부 확인 필요")
                          pendingCredential = updatedCredential
                          showAppleRestoreAlert = true
                        } else {
                          print("❌ 업데이트된 credential 정보가 없음")
                        }
                      } else if let authResult = authResult {
                        print("✅ Apple 계정으로 익명 계정 link 성공: \(authResult.user.uid)")
                        isLoggedIn = true  // ✅ 여기도 추가
                      } else {
                        print("❌ link 실패: \(error?.localizedDescription ?? "")")
                      }
                    }
                  }
                }
              case .failure(let error):
                print("Authorization failed: \(error.localizedDescription)")
              }
            })
            .signInWithAppleButtonStyle(.black)
            .frame(height: 45)
          }
        }
        
        Section(header: Text("지원")) {
          Button("개발자에게 문의하기") {
            contactDeveloper()
          }
        }
        
        if !donationManager.products.isEmpty {
          ForEach(donationManager.products, id: \.id) { product in
            Button("\(product.displayName) - \(product.displayPrice)") {
              Task {
                await donationManager.donate(product)
              }
            }
          }
        }
        
//        Section(header: Text("후원")) {
//          if donationManager.products.isEmpty {
//            Text("후원 옵션을 불러오는 중...")
//          } else {
//            ForEach(donationManager.products, id: \.id) { product in
//              Button("후원하기 - \(product.displayPrice)") {
//                Task {
//                  await donationManager.donate(product)
//                }
//              }
//            }
//          }
//        }
        
        Section {
          Text("앱 버전 \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")")
            .foregroundColor(.gray)
        }
        
#if DEBUG
        Section(header: Text("테스트")) {
          // ✅ [로컬 테스트 데이터 저장] 버튼
          Button("로컬 테스트 데이터 저장") {
            let testGroup = VocaGroup(id: UUID(), name: "🔥 테스트 그룹")
            let testWord = Word(
              id: UUID(),
              name: "apple",
              meaning: "사과",
              isKnowWord: true,
              knowTime: 3.22, // ← 빠뜨렸던 부분
              order: 0
            )
            
            let groupKey = "groups"
            let wordKey = "words_\(testGroup.id.uuidString)"
            
            if let encodedGroups = try? JSONEncoder().encode([testGroup]) {
              UserDefaults.standard.set(encodedGroups, forKey: groupKey)
              print("✅ 그룹 저장 완료")
            }
            
            if let encodedWords = try? JSONEncoder().encode([testWord]) {
              UserDefaults.standard.set(encodedWords, forKey: wordKey)
              print("✅ 단어 저장 완료")
            }
          }
          
          // ✅ [로컬 데이터 확인] 버튼
          Button("로컬 데이터 콘솔 출력") {
            let groupKey = "groups"
            if let savedGroupData = UserDefaults.standard.data(forKey: groupKey),
               let decodedGroups = try? JSONDecoder().decode([VocaGroup].self, from: savedGroupData) {
              print("✅ 저장된 그룹들:")
              decodedGroups.forEach { print("- \($0.name) (\($0.id))") }
              
              for group in decodedGroups {
                let wordKey = "words_\(group.id.uuidString)"
                if let wordData = UserDefaults.standard.data(forKey: wordKey),
                   let decodedWords = try? JSONDecoder().decode([Word].self, from: wordData) {
                  print("📚 그룹 \(group.name)의 단어:")
                  decodedWords.forEach { print("  - \($0.name): \($0.meaning)") }
                } else {
                  print("📭 그룹 \(group.name)의 단어 없음")
                }
              }
            } else {
              print("❌ 저장된 그룹 없음")
            }
          }
          Button("계정 탈퇴 후 앱 종료", role: .destructive) {
            deleteAccountAndTerminate()
          }
        }
#endif
      }
      .navigationTitle("설정")
      .navigationBarTitleDisplayMode(.inline)
    }
    .onAppear {
      if let user = Auth.auth().currentUser, !user.isAnonymous {
        isLoggedIn = true
      } else {
        isLoggedIn = false
      }
    }
    .alert("Apple 계정에 기존 데이터가 있습니다", isPresented: $showAppleRestoreAlert) {
      Button("불러오기", role: .none) {
        if let credential = pendingCredential {
          Auth.auth().signIn(with: credential) { result, error in
            if let user = result?.user {
              print("✅ Apple 계정으로 로그인 완료: \(user.uid)")
              isLoggedIn = true
            } else {
              print("❌ 로그인 실패: \(error?.localizedDescription ?? "")")
            }
          }
        }
      }

      Button("취소", role: .cancel) {
        pendingCredential = nil
      }
    } message: {
      Text("Apple 계정에 저장된 데이터로 덮어쓰시겠습니까?\n※ 현재 익명 계정 데이터는 사라집니다.")
    }
    .alert("정말로 계정을 삭제하시겠습니까?", isPresented: $showDeleteConfirmAlert) {
      Button("계정 삭제", role: .destructive) {
        deleteAccountAndCloneToAnonymous()
      }
      Button("취소", role: .cancel) {}
    } message: {
      Text("Apple 계정과 연동된 모든 단어 그룹 및 단어 정보가 삭제됩니다.\n삭제 후에는 복구가 불가능합니다.")
    }
  }

  // 로그아웃 처리
  func signOut() {
    do {
      try Auth.auth().signOut()
      isLoggedIn = false
    } catch {
      print("Sign out failed: \(error.localizedDescription)")
    }
  }
  
  // 난수 생성
  func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] =
      Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length

    while remainingLength > 0 {
      let randoms: [UInt8] = (0..<16).map { _ in
        var random: UInt8 = 0
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
        if errorCode != errSecSuccess {
          fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        return random
      }

      randoms.forEach { random in
        if remainingLength == 0 {
          return
        }

        if random < charset.count {
          result.append(charset[Int(random)])
          remainingLength -= 1
        }
      }
    }

    return result
  }

  // SHA256 해싱
  func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    return hashedData.compactMap { String(format: "%02x", $0) }.joined()
  }
  
  func deleteAccountAndCloneToAnonymous() {
    guard let user = Auth.auth().currentUser else { return }
    let oldUID = user.uid

    user.delete { error in
      if let error = error {
        print("❌ 계정 삭제 실패: \(error.localizedDescription)")
      } else {
        print("✅ 계정 삭제 완료")

        Auth.auth().signInAnonymously { result, error in
          guard let newUID = result?.user.uid, error == nil else {
            print("❌ 익명 로그인 실패: \(error?.localizedDescription ?? "")")
            return
          }

          print("✅ 익명 로그인 완료: \(newUID)")
          cloneData(from: oldUID, to: newUID)
          isLoggedIn = false
        }
      }
    }
  }
  
  func checkServerDataExists(uid: String, completion: @escaping (Bool) -> Void) {
    let ref = Firestore.firestore().collection("users").document(uid).collection("groups")
    ref.getDocuments { snapshot, error in
      if let docs = snapshot?.documents, !docs.isEmpty {
        completion(true)
      } else {
        completion(false)
      }
    }
  }
  
  func logoutAndCloneFromAppleUID() {
    guard let oldUID = Auth.auth().currentUser?.uid else {
      print("❌ 현재 로그인된 사용자가 없음")
      return
    }

    do {
      try Auth.auth().signOut()
      print("✅ 로그아웃 완료")

      Auth.auth().signInAnonymously { result, error in
        guard let newUID = result?.user.uid, error == nil else {
          print("❌ 익명 로그인 실패: \(error?.localizedDescription ?? "")")
          return
        }

        print("✅ 익명 로그인 완료: \(newUID)")
        cloneData(from: oldUID, to: newUID)
        isLoggedIn = false
      }
    } catch {
      print("❌ 로그아웃 실패: \(error.localizedDescription)")
    }
  }

  func cloneData(from oldUID: String, to newUID: String) {
    let db = Firestore.firestore()

    let sourceRef = db.collection("users").document(oldUID).collection("groups")
    let targetRef = db.collection("users").document(newUID).collection("groups")

    sourceRef.getDocuments { snapshot, error in
      guard let docs = snapshot?.documents, error == nil else {
        print("❌ 기존 그룹 데이터 불러오기 실패: \(error?.localizedDescription ?? "")")
        return
      }

      for doc in docs {
        let data = doc.data()
        let groupID = doc.documentID

        targetRef.document(groupID).setData(data) { error in
          if let error = error {
            print("❌ 그룹 \(groupID) 복사 실패: \(error.localizedDescription)")
          } else {
            print("✅ 그룹 \(groupID) 복사 완료")
          }
        }

        // 단어(word) 컬렉션도 복사
        let wordSource = sourceRef.document(groupID).collection("words")
        let wordTarget = targetRef.document(groupID).collection("words")

        wordSource.getDocuments { wordSnapshot, error in
          guard let wordDocs = wordSnapshot?.documents else { return }
          for wordDoc in wordDocs {
            wordTarget.document(wordDoc.documentID).setData(wordDoc.data())
          }
        }
      }
    }
  }
  
  func deleteAccountAndTerminate() {
    guard let user = Auth.auth().currentUser else { return }

    user.delete { error in
      if let error = error {
        print("❌ 계정 삭제 실패: \(error.localizedDescription)")
      } else {
        print("✅ 계정 삭제 완료 → 앱 종료")
        // 앱 강제 종료 (테스트용)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          fatalError("앱을 종료합니다 (테스트용 강제 종료)")
        }
      }
    }
  }
  
  func contactDeveloper() {
    let email = "monomer.verb-7p@icloud.com"
    let subject = "랜덤보카 문의사항"
    let body = """
    아래에 문의 내용을 작성해 주세요:

    
    
    ----------------------
    앱 버전: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "알 수 없음")
    iOS 버전: \(UIDevice.current.systemVersion)
    기기: \(UIDevice.current.model)
    ----------------------
    """

    let urlString = "mailto:\(email)?subject=\(subject)&body=\(body)"
      .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

    if let url = URL(string: urlString) {
      UIApplication.shared.open(url)
    }
  }
}

#Preview {
  Setting()
}
