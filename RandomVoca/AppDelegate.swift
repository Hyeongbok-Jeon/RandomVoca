import UIKit
import SwiftUI
import GoogleMobileAds
import UserNotifications

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
}
