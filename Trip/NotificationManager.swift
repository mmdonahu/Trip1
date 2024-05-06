import UIKit
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    // 通知をスケジュールする関数
    func scheduleNotificationForNewCard() {
        let content = UNMutableNotificationContent()
        content.title = "Get a New Certificate！"
        content.body = "Got the New Certificate! Open the App!"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "newCardNotification", content: content, trigger: trigger)
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { error in
            if let error = error {
                print("Notification Error: \(error)")
            }
        }
    }
    
    // EditCardsManagerから呼び出される関数
    func checkAndNotifyForNewCards() {
        if CardsManager.shared.hasUnacquiredCards {
            scheduleNotificationForNewCard()
        }
    }
}

