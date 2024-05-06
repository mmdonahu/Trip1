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
        
        // ユーザーIDが取得できるかチェック
        guard let userId = Auth.auth().currentUser?.uid else {
            print("ユーザーIDが取得できません。")
            return
        }
        
        // Firebaseでチェックイン状態を確認
        let checkpointRef = Firestore.firestore().collection("checkpoints").document("\(userId)_\(checkpointId)")
        checkpointRef.getDocument { document, error in
            if let error = error {
                print("エラー: \(error.localizedDescription)")
                return
            }
            
            // ドキュメントが存在しない場合、ユーザーはまだこのチェックポイントに到達していない
            if document?.exists == false {
                // Firebaseにデータを送信
                VerifyCheckpontManager.shared.sendCheckpointData(checkpointId: checkpointId, checkpointName: region.identifier, userId: userId)
                
                // EditCardsManagerを使用して画像のダウンロードと編集を行う
                EditCardsManager.shared.editAndUploadImage(checkpointId: checkpointIdString, userId: userId, date: Date())
                        print("画像の編集に失敗しました。")
                        return
                    }
                    // 必要に応じて編集した画像を処理する
                    // 例: アプリ内の画像ビューに表示するなど
                }
                
                // Firebaseにチェックインを記録
                checkpointRef.setData(["checkedIn": true, "timestamp": FieldValue.serverTimestamp()])
            }
        }

class CheckpointManager: ObservableObject {
    static let shared = CheckpointManager() // シングルトンパターンを使用
    @Published var notificationReceived = false
}

