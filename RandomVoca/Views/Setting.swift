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

struct Setting: View {
  @State private var isLoggedIn = false
  @State private var currentNonce: String?

  var body: some View {
    NavigationStack {
      Form {
        Section(header: Text("계정")) {
          if isLoggedIn {
            Text("Apple 계정으로 로그인됨")
              .foregroundColor(.green)
            Button("로그아웃") {
              signOut()
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
                    withProviderID: "apple.com",
                    idToken: idTokenString,
                    rawNonce: nonce
                  )

                  Auth.auth().signIn(with: credential) { (authResult, error) in
                    if let error = error {
                      print("Error authenticating: \(error.localizedDescription)")
                      return
                    }
                    print("Login Success")
                    isLoggedIn = true
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
}

#Preview {
  Setting()
}
