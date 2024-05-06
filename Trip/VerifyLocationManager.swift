import Foundation
import Firebase
import FirebaseFirestore


class VerifyCheckpontManager {
    static let shared = VerifyCheckpontManager()
    
    private init() {}
    
    func sendCheckpointData(checkpointId: Int, checkpointName: String, userId: String) {
        let db = Firestore.firestore()
        let timestamp = Timestamp(date: Date())
        let docId = "\(userId)_\(checkpointId)" // ユーザーIDとチェックポイントIDを組み合わせたドキュメントID
        db.collection("checkpoints").document(docId).setData([
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
