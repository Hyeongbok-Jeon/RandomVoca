//
//  AdMobInterstitial.swift
//  RandomVoca
//
//  Created by Hyeongbok Jeon on 5/12/25.
//

import GoogleMobileAds
import UIKit

class AdMobInterstitial: NSObject, FullScreenContentDelegate {
  private var interstitial: InterstitialAd?
  private let adUnitID: String

  override init() {
#if DEBUG
    self.adUnitID = "ca-app-pub-3940256099942544/4411468910" // 테스트용 전면 광고 ID
#else
    self.adUnitID = "ca-app-pub-9381709608642362/4066514731" // 실제 전면 광고 ID
#endif
    super.init()
    loadAd()
  }

  private func loadAd() {
    let request = Request()
    InterstitialAd.load(with: adUnitID, request: request) { ad, error in
      if let error = error {
        print("전면 광고 로드 실패: \(error.localizedDescription)")
        return
      }
      self.interstitial = ad
      self.interstitial?.fullScreenContentDelegate = self
    }
  }

  func showAdIfAvailable(from viewController: UIViewController) {
    if let ad = interstitial {
      ad.present(from: viewController)
    } else {
      print("전면 광고가 아직 준비되지 않음")
    }
    loadAd() // 항상 다음 광고 미리 로드
  }

  // 광고 닫힌 후 다음 광고 로드
  func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
    loadAd()
  }
}
