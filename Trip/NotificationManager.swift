import Foundation
import UserNotifications
import Combine

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var bellState: BellState = .normal
    
    // ベルの状態を管理するプロパティ
    enum BellState {
        case normal
        case alerted // 赤いベル
        case visited // 訪問済み
    }
    
    func updateBellState(for checkpointId: Int, hasCertificate: Bool) {
        print("Update Bell State Called: hasCertificate = \(hasCertificate)")
        if hasCertificate {
            bellState = .visited
            print("Bell state updated to visited.")
        } else {
            bellState = .alerted
            print("Bell state updated to alerted.")
        }
    }
    
    // 通知をトリガーする新しい関数
    func triggerBellStateNotification(for message: String, checkpointId: Int) {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "Alert", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: message, arguments: nil)
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: "checkpointNotification_\(checkpointId)", content: content, trigger: nil)
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }
    
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
