import Foundation
import Firebase
import FirebaseFirestore

class MomentManager: ObservableObject {
    static let shared = MomentManager()
    @Published var posts: [PostData] = []
    
    private var db = Firestore.firestore()
    
    private var momentsCollectionRef: CollectionReference {
        return db.collection("moments")
    }
    
    init() {
        loadMoments()
    }
    
    func loadMoments() {
        momentsCollectionRef.order(by: "timestamp", descending: true).addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents found")
                return
            }
            
            self.posts = documents.map { (queryDocumentSnapshot) -> PostData in
                let data = queryDocumentSnapshot.data()
                let userId = data["userId"] as? String ?? ""
                let userName = data["userName"] as? String ?? ""
                let postText = data["postText"] as? String ?? ""
                let postImageUrl = data["postImageUrl"] as? String ?? ""
                let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                let likes = data["likes"] as? Int ?? 0
                let likedBy = data["likedBy"] as? [String] ?? []
                
                return PostData(id: queryDocumentSnapshot.documentID,
                                userId: userId,
                                userName: userName,
                                postText: postText,
                                postImageUrl: postImageUrl,
                                timestamp: timestamp,
                                likes: likes)
            }
        }
    }
    
    func addPost(post: PostData) {
        let data: [String: Any] = [
            "userId": post.userId,
            "userName": post.userName,
            "postText": post.postText,
            "postImageUrl": post.postImageUrl,
            "timestamp": FieldValue.serverTimestamp(),
            "likes": post.likes
        ]
        
        momentsCollectionRef.addDocument(data: data) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    func updateLikes(postId: String, newLikes: Int) {
        momentsCollectionRef.document(postId).updateData(["likes": newLikes]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func likePost(postId: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let postRef = momentsCollectionRef.document(postId)
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let postDocument: DocumentSnapshot
            do {
                try postDocument = transaction.getDocument(postRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            var likedBy = postDocument.data()?["likedBy"] as? [String] ?? []
            if likedBy.contains(userId) {
                // すでに「いいね」している場合、リストからユーザーIDを削除
                likedBy.removeAll { $0 == userId }
            } else {
                // 「いいね」していない場合は、ユーザーIDを追加
                likedBy.append(userId)
            }
            transaction.updateData(["likedBy": likedBy], forDocument: postRef)
            
            return nil
        }) { _, error in
            if let error = error {
                print("Error liking/unliking post: \(error.localizedDescription)")
            }
        }
    }
    
    func loadUserProfile(completion: @escaping (_ displayName: String?, _ profileImageUrl: String?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(nil, nil)
            return
        }
        
        let userRef = db.collection("users").document(userId)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let displayName = document.get("name") as? String
                let profileImageUrl = document.get("profileImageUrl") as? String
                completion(displayName, profileImageUrl)
            } else {
                print("Document does not exist")
                completion(nil, nil)
            }
        }
    }

}

struct PostData: Identifiable {
    var id: String
    var userId: String
    var userName: String
    var postText: String
    var postImageUrl: String
    var timestamp: Date
    var likes: Int
    var likedBy: [String] = [] // 「いいね」したユーザーIDのリスト
}

