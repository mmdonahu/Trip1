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
}

struct PostData: Identifiable {
    var id: String
    var userId: String
    var userName: String
    var postText: String
    var postImageUrl: String
    var timestamp: Date
    var likes: Int
}

