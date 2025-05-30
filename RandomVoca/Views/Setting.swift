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
              deleteAccount()
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
                          // ✅ 이미 연동된 Apple 계정으로 바로 로그인
                          Auth.auth().signIn(with: updatedCredential) { result, error in
                            if let user = result?.user {
                              print("✅ Apple 계정으로 로그인 완료: \(user.uid)")
                              isLoggedIn = true
                            } else {
                              print("❌ 로그인 실패: \(error?.localizedDescription ?? "")")
                            }
                          }
                        } else {
                          print("❌ 업데이트된 credential 정보가 없음")
                        }
                      } else if let authResult = authResult {
                        print("✅ Apple 계정으로 익명 계정 link 성공: \(authResult.user.uid)")
                        isLoggedIn = true  // ✅ 여기도 추가
                        
                        // ✅ 여기에 서버 데이터 존재 여부 체크 후, 팝업 띄우기
//                        checkServerDataExists(uid: authResult.user.uid) { exists in
//                          if exists {
//                            showConflictDialog = true
//                          }
//                        }
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

        Section {
          Text("앱 버전 1.0.40")
            .foregroundColor(.gray)
        }
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
    .alert("기존 데이터가 존재합니다", isPresented: $showConflictDialog) {
      Button("로컬 데이터로 덮어쓰기", role: .destructive) {
        uploadLocalDataToServer()
      }
      Button("서버 데이터 불러오기") {
        fetchServerDataToLocal()
      }
    } message: {
      Text("Apple 계정에 기존 데이터가 있습니다. 어떤 데이터를 사용할까요?")
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
  
  func deleteAccount() {
    guard let user = Auth.auth().currentUser else { return }
    user.delete { error in
      if let error = error {
        print("❌ 계정 삭제 실패: \(error.localizedDescription)")
      } else {
        print("✅ 계정이 삭제되었습니다.")
        isLoggedIn = false
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
  
  func uploadLocalDataToServer() {
    print("📝 로컬 데이터를 서버에 업로드")
    // ModelData 기반으로 Firestore에 저장
  }

  func fetchServerDataToLocal() {
    print("⬇️ 서버 데이터를 로컬로 불러오기")
    // Firestore에서 데이터를 읽어서 ModelData에 반영
  }
  
  func deleteAnonymousAndThenLogin(with credential: AuthCredential) {
    guard let user = Auth.auth().currentUser, user.isAnonymous else {
      print("❌ 현재 사용자가 익명이 아님")
      return
    }

    user.delete { error in
      if let error = error {
        print("❌ 익명 계정 삭제 실패: \(error.localizedDescription)")
        return
      }

      print("✅ 익명 계정 삭제됨. Apple 로그인 시도")

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
}

#Preview {
  Setting()
}
