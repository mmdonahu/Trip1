import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func scheduleNotification(for checkpointName: String, checkpointId: Int) {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Arrived Checkpoint！", arguments: nil)
        // チェックポイントの名前と番号を含めたメッセージ
        content.body = NSString.localizedUserNotificationString(forKey: "You've arrived at \(checkpointId). \(checkpointName)! Would you like to record your visit?", arguments: nil)
        content.sound = UNNotificationSound.default
        
        // チェックポイントIDを元にした一意のidentifierを使用
        let request = UNNotificationRequest(identifier: "checkpointNotification_\(checkpointId)", content: content, trigger: nil) // 即時発火するためtriggerはnil
        
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }
}
