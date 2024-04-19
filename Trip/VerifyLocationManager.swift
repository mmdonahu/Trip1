import Foundation
import Firebase

class VerifyCheckpontManager {
    static let shared = VerifyCheckpontManager()
    
    private init() {}
    
    func sendCheckpointData(checkpointId: Int, checkpointName: String, userId: String) {
        let db = Firestore.firestore()
        let timestamp = Timestamp(date: Date())
        db.collection("checkpoints").addDocument(data: [
            "checkpointsId": checkpointId,
            "checkpointsName": checkpointName,
            "timestamp": timestamp,
            "userId": userId
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(checkpointId)")
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
