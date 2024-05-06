import Foundation
import Firebase
import FirebaseFirestore


// VerifyLocationManager.swift
class VerifyLocationManager {
    static let shared = VerifyLocationManager()
    
    private init() {}
    
    func checkAndSendCheckpointData(checkpointId: Int, checkpointName: String, userId: String) {
        let db = Firestore.firestore()
        let docId = "\(userId)_\(checkpointId)"
        let checkpointRef = db.collection("checkpoints").document(docId)
        
        // ユーザー名を取得
        userDocRef.getDocument { (userDoc, userError) in
            if let userError = userError {
                print("Error retrieving user document: \(userError.localizedDescription)")
                return
            }
            
            guard let userData = userDoc?.data(), let userName = userData["name"] as? String else {
                print("User document is missing 'name'")
                return
            }
            
            let docId = "\(userId)_\(checkpointId)"
            let checkpointRef = db.collection("checkpoints").document(docId)
        
        // ドキュメントが存在するか確認
        checkpointRef.getDocument { document, error in
            if let error = error {
                print("Error retrieving document: \(error.localizedDescription)")
                return
            }
            
            // ドキュメントが存在しない場合、新たにデータをセット
            if document?.exists == false {
                let timestamp = Timestamp(date: Date())
                checkpointRef.setData([
                    "checkpointsId": checkpointId,
                    "checkpointsName": checkpointName,
                    "timestamp": timestamp,
                    "userId": userId
                ]) { err in
                    if let err = err {
                        print("Error setting document: \(err)")
                    } else {
                        print("Document successfully set with ID: \(docId)")
                    }
                }
                // 追加の処理、例えば画像のダウンロードと編集を行う
                EditCardsManager.shared.editAndUploadImage(checkpointId: String(checkpointId), userId: userId, date: Date())
            }
        }
    }
}

class VerifyStoreManager {
    static let shared = VerifyStoreManager()
    
    private init() {}
    
    func sendStoreData(storeId: Int, storeName: String, userId: String, category: String, country: String, pricePerScan: Int, region: String) {
        let db = Firestore.firestore()
        let timestamp = Timestamp(date: Date())
        db.collection("stores").addDocument(data: [
            "userId": userId,
            "category": category,
            "country": country,
            "pricePerScan": pricePerScan,
            "region": region,
            "storeId": storeId,
            "timestamp": timestamp
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with checkpointId: \(storeId)")
            }
        }
    }
}
