import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestore

class EditCardsManager {
    static let shared = EditCardsManager()
    private init() {}
    
    // Firestoreに画像のURLを保存する
    private func saveImageURLToFirestore(userId: String, checkpointId: String, imageUrl: String) {
        let docRef = Firestore.firestore().collection("checkpoints").document("\(userId)_\(checkpointId)")
        docRef.setData(["certificateUrl": imageUrl], merge: true) { error in
            if let error = error {
                print("Error saving image URL to Firestore: \(error)")
            } else {
                print("Image URL successfully saved to Firestore.")
            }
        }
    }
    
    // Firebase Storageから元の画像をダウンロードし、テキストを追加して再アップロードするメソッド
    func editAndUploadImage(checkpointId: String, userId: String, date: Date) {
        // Firestoreからユーザーの実名を取得
        let userDocRef = Firestore.firestore().collection("users").document(userId)
        userDocRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
                return
            }
            guard let document = document, let userData = document.data(), let username = userData["name"] as? String else {
                print("User name not found.")
                return
            }
            
            // 以下の処理をユーザー名取得後に実行
            let dateString = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .none).replacingOccurrences(of: "/", with: "-")
            let imageName = "\(checkpointId)_\(dateString).png"
            let storageRef = Storage.storage().reference().child("CheckpointCards/\(checkpointId).png")
            
            // 元の画像をダウンロード
            storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
                if let error = error {
                    print("Error downloading image: \(error)")
                    return
                }
                guard let data = data, let image = UIImage(data: data) else {
                    print("Error processing downloaded data.")
                    return
                }
                
                // 画像にユーザー名と日時を追加
                guard let editedImage = self.drawText(image: image, username: username, date: date),
                      let editedImageData = editedImage.pngData() else {
                    print("Failed to edit image or convert to PNG.")
                    return
                }
                
                // 編集済みの画像をFirebase Storageにアップロード
                let editedImageRef = Storage.storage().reference().child("Certificates/\(userId)/\(imageName)")
                editedImageRef.putData(editedImageData, metadata: nil) { metadata, error in
                    if let error = error {
                        print("Error uploading edited image: \(error)")
                        return
                    }
                    editedImageRef.downloadURL { url, error in
                        if let downloadURL = url {
                            self.saveImageURLToFirestore(userId: userId, checkpointId: checkpointId, imageUrl: downloadURL.absoluteString)
                        } else {
                            print("Error getting download URL: \(error?.localizedDescription ?? "unknown error")")
                        }
                    }
                }
            }
        }
    }

    // 画像にユーザー名と日時のテキストを追加するメソッド
    func drawText(image: UIImage, username: String, date: Date) -> UIImage? {
        let userNameAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 30, weight: .bold),
            .foregroundColor: UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 1),
            .paragraphStyle: centeredParagraphStyle()
        ]
        
        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .regular),
            .foregroundColor: UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1),
            .paragraphStyle: centeredParagraphStyle()
        ]
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0)
        image.draw(at: .zero)
        
        let userNameString = NSAttributedString(string: username, attributes: userNameAttributes)
        let dateString = NSAttributedString(string: DateFormatter.localizedString(from: date, dateStyle: .long, timeStyle: .none), attributes: dateAttributes)
        
        let userNameStringSize = userNameString.size()
        let dateStringSize = dateString.size()
        
        let offset = CGFloat(250) // 左に？ポイント移動
        let userNameStringRect = CGRect(x: (image.size.width - userNameStringSize.width) / 2 - offset, y: image.size.height * 0.80, width: userNameStringSize.width, height: userNameStringSize.height)

        let rightOffset = CGFloat(250)  // 右に？ポイント移動
        let dateStringRect = CGRect(x: image.size.width - dateStringSize.width - rightOffset,y: image.size.height * 0.80,width: dateStringSize.width,
            height: dateStringSize.height)
        
        userNameString.draw(in: userNameStringRect)
        dateString.draw(in: dateStringRect)
        
        let editedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return editedImage
    }

    private func centeredParagraphStyle() -> NSParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return paragraphStyle
    }
}
