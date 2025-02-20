import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ 알림 권한 허용됨")
                self.self.scheduleHourlyNotification()
            } else {
                print("❌ 알림 권한 거부됨")
            }
        }
    }

    func scheduleHourlyNotification() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests() // 기존 알림 제거

        for hour in 1...24 { // 하루 동안 1시간마다 알림 설정
            let randomWord = getRandomWord() // ✅ Core Data에서 랜덤 단어 가져오기
            let content = UNMutableNotificationContent()
            content.title = "💡 영어 단어 퀴즈!"
            content.body = randomWord
            content.sound = .default
            content.userInfo = ["word": randomWord] // ✅ 알림에 단어 정보 포함

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(hour * 3600), repeats: false)
            let request = UNNotificationRequest(identifier: "wordReminder_\(hour)", content: content, trigger: trigger)

            center.add(request) { error in
                if let error = error {
                    print("❌ 알림 등록 실패: \(error)")
                }
            }
        }
        print("✅ 1시간마다 단어 알림 등록 완료")
    }

    private func getRandomWord() -> String {
        let words = CoreDataHelper.shared.fetchWords()
        return words.randomElement()?.name ?? "단어 없음"
    }
}
