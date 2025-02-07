import UIKit
import GoogleMobileAds

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // ✅ 최신 AdMob 초기화 코드
        MobileAds.shared.start(completionHandler: nil)
        print("✅ Google Mobile Ads SDK 초기화 완료")
        return true
    }
}
