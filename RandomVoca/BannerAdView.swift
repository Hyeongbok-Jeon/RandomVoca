import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
  private let adUnitID: String
  
  init() {
#if DEBUG
    self.adUnitID = "ca-app-pub-3940256099942544/293473571" // 테스트용 광고 ID
#else
    self.adUnitID = "ca-app-pub-9381709608642362/9421948070" // 실제 광고 ID
#endif
  }
  func makeUIView(context: Context) -> BannerView {
    let bannerView = BannerView(adSize: AdSizeBanner)
    bannerView.adUnitID = adUnitID
    bannerView.rootViewController = findRootViewController()
    bannerView.load(Request())
    bannerView.backgroundColor = .clear
    return bannerView
  }
  
  func updateUIView(_ uiView: BannerView, context: Context) {}
  
  private func findRootViewController() -> UIViewController? {
    guard let windowScene = UIApplication.shared.connectedScenes
      .first(where: { $0 is UIWindowScene }) as? UIWindowScene,
          let window = windowScene.windows.first,
          let rootViewController = window.rootViewController else {
      return nil
    }
    return rootViewController
  }
}
