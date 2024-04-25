import UIKit
import CoreLocation
import Foundation
import Combine
import Firebase
import FirebaseFirestore
import FirebaseAuth

class GeofenceManager: NSObject, CLLocationManagerDelegate {
    static let shared = GeofenceManager()
    private let locationManager = CLLocationManager()
    
    private override init() {
        super.init()
        self.locationManager.delegate = self
        self.setupGeofencing()
    }
    
    // 全チェックポイントのジオフェンスを設定するメソッド
    func setupGeofencing() {
        let checkpoints = [
            ("1.Skytree", CLLocationCoordinate2D(latitude: 35.710063, longitude: 139.8107)),
            ("2.Asakusa", CLLocationCoordinate2D(latitude: 35.714765, longitude: 139.796655)),
            ("3.ShinjukuCrossing", CLLocationCoordinate2D(latitude: 35.689487, longitude: 139.691706)),
            ("4.Kabukicho", CLLocationCoordinate2D(latitude: 35.693810, longitude: 139.703549)),
            ("5.TokyoTower", CLLocationCoordinate2D(latitude: 35.658580, longitude: 139.745433)),
            ("6.Arashiyama", CLLocationCoordinate2D(latitude: 35.009449, longitude: 135.666773)),
            ("7.Kinkakuji", CLLocationCoordinate2D(latitude: 35.03937, longitude: 135.729243)),
            ("8.Enoshima", CLLocationCoordinate2D(latitude: 35.299835, longitude: 139.480224)),
            ("9.Kamakura", CLLocationCoordinate2D(latitude: 35.319225, longitude: 139.546687)),
            ("10.Ebisubashi", CLLocationCoordinate2D(latitude: 34.668723, longitude: 135.501295)),
            ("11.OsakaCastle", CLLocationCoordinate2D(latitude: 34.687315, longitude: 135.526201)),
            ("12.NaraPark", CLLocationCoordinate2D(latitude: 34.685087, longitude: 135.843012)),
            ("13.Fuji", CLLocationCoordinate2D(latitude: 35.360556, longitude: 138.727778)),
            ("14.Hokkaido", CLLocationCoordinate2D(latitude: 43.064615, longitude: 141.346807)),
            ("15.Okinawa", CLLocationCoordinate2D(latitude: 26.212401, longitude: 127.680932))
        ]
        
        for (identifier, center) in checkpoints {
            let region = CLCircularRegion(center: center, radius: 100, identifier: identifier)
            region.notifyOnEntry = true
            region.notifyOnExit = true
            locationManager.startMonitoring(for: region)
        }
    }
    
    func checkInitialLocation() {
        locationManager.requestLocation() // 位置を一度だけリクエスト
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        for region in locationManager.monitoredRegions {
            if let circularRegion = region as? CLCircularRegion, circularRegion.contains(location.coordinate) {
                // チェックポイント内にいる場合の処理
                NotificationManager.shared.scheduleNotification(for: region.identifier, checkpointId: Int(region.identifier.components(separatedBy: ".").first ?? "0") ?? 0)
                CheckpointManager.shared.notificationReceived = true
                break
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("位置情報の取得に失敗: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        // チェックポイントの名前（identifier）からIDを抽出
        let checkpointIdString = region.identifier.components(separatedBy: ".").first ?? ""
        let checkpointId = Int(checkpointIdString) ?? 0 // 数値変換できない場合は0を代入
        
        // UserDefaultsを確認して既にチェックインしているかを判断
        if UserDefaults.standard.bool(forKey: "checked_in_\(checkpointId)") == false {
            // まだチェックインしていない場合はFirebaseにデータを送信
            guard let userId = Auth.auth().currentUser?.uid else {
                print("ユーザーIDが取得できません。")
                return
            }
            // Firebaseからユーザー名を取得する
            let userDocRef = Firestore.firestore().collection("users").document(userId)
            userDocRef.getDocument { (document, error) in
                if let document = document, document.exists, let userName = document.data()?["name"] as? String {
                    
                    // Firebaseにデータを送信
                    VerifyCheckpontManager.shared.sendCheckpointData(checkpointId: checkpointId, checkpointName: region.identifier, userId: userId)
                    
                    // EditCardsManagerを使用して画像のダウンロードと編集を行う
                    EditCardsManager.shared.downloadEditAndSaveImage(checkpointId: checkpointIdString, username: userName) { editedImage in
                        guard let editedImage = editedImage else {
                            print("画像の編集に失敗しました。")
                            return
                        }
                        // 必要に応じて編集した画像を処理する
                        // 例: アプリ内の画像ビューに表示するなど
                    }
                    // UserDefaultsにチェックインを記録
                    UserDefaults.standard.set(true, forKey: "checked_in_\(checkpointId)")
                    
                    // 通知をスケジュール
                    NotificationManager.shared.scheduleNotification(for: region.identifier, checkpointId: checkpointId)
                    CheckpointManager.shared.notificationReceived = true
                    
                    // チェックポイントの名前とIDを使用して通知をスケジュール
                    NotificationManager.shared.scheduleNotification(for: region.identifier, checkpointId: checkpointId)
                    CheckpointManager.shared.notificationReceived = true
                }
                
                func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
                    print("\(region.identifier)のジオフェンス領域から出ました")
                    
                    // チェックポイントの範囲外に出たらnotificationReceivedをfalseに設定
                    CheckpointManager.shared.notificationReceived = false
                }
            }
        }
    }
}

class CheckpointManager: ObservableObject {
    static let shared = CheckpointManager() // シングルトンパターンを使用
    @Published var notificationReceived = false
}

