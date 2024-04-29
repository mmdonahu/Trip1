import Foundation
import UserNotifications
import Combine

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var bellState: BellState = .normal
    
    // ベルの状態を管理するプロパティ
    enum BellState {
        case normal
        case alerted // チェックポイント訪問後ダウンロード済み未表示画像
        case visited // 訪問済み
    }
    
    // 以下の関数は、新しい条件に基づいてベルの状態を更新します。
    func updateBellState(for checkpointId: Int, hasDownloaded: Bool, hasBeenViewed: Bool) {
        print("Update Bell State Called: hasDownloaded = \(hasDownloaded), hasBeenViewed = \(hasBeenViewed)")
        if hasDownloaded && !hasBeenViewed {
            bellState = .alerted
            print("Bell state updated to alerted.")
        } else {
            bellState = .normal
            print("Bell state updated to normal.")
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
