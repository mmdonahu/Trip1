import Firebase
import FirebaseFirestore

class UserInfoManager: ObservableObject {
    static let shared = UserInfoManager()
    @Published var user: User?
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    func loadUserInfo() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("ユーザーIDが見つかりません。")
            return
        }
        
        // 既存のリスナーを取り除く
        listener?.remove()
        
        listener = db.collection("users").document(userId).addSnapshotListener { [weak self] documentSnapshot, error in
            guard let snapshot = documentSnapshot else {
                print("ユーザーデータの読み込みに失敗しました: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                self?.user = try snapshot.data(as: User.self)
            } catch {
                print("ユーザー情報のデコードに失敗しました: \(error)")
            }
        }
    }
    
    deinit {
        listener?.remove()
    }
}

