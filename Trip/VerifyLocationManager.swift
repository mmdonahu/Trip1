import Foundation
import Firebase

class FirebaseManager {
    static let shared = FirebaseManager()
    
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

