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
            
            // 画像にテキストを追加
            guard let editedImage = self.drawText(image: image, username: userId, date: date),
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
    
    // 画像にユーザー名と日時のテキストを追加するメソッド
    func drawText(image: UIImage, username: String, date: Date) -> UIImage? {
        // ユーザー名と日付のスタイルを設定
        let userNameAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 44, weight: .bold),
            .foregroundColor: UIColor.white,
            .paragraphStyle: centeredParagraphStyle()
        ]
        
        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 36, weight: .regular),
            .foregroundColor: UIColor.white,
            .paragraphStyle: centeredParagraphStyle()
        ]
        
        // UIGraphicsBeginImageContextWithOptionsでPNGとしての透明度を保持
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0)
        
        image.draw(at: .zero)
        
        // ユーザー名と日付のテキストを描画
        let userNameString = NSAttributedString(string: username, attributes: userNameAttributes)
        let dateString = NSAttributedString(string: DateFormatter.localizedString(from: date, dateStyle: .long, timeStyle: .none), attributes: dateAttributes)
        
        // テキストを描画する位置を計算
        let userNameStringSize = userNameString.size()
        let dateStringSize = dateString.size()
        
        let userNameStringRect = CGRect(x: (image.size.width - userNameStringSize.width) / 2, y: image.size.height * 0.82, width: userNameStringSize.width, height: userNameStringSize.height)
        let dateStringRect = CGRect(x: (image.size.width - dateStringSize.width) / 2, y: image.size.height * 0.86, width: dateStringSize.width, height: dateStringSize.height)
        
        // テキストを描画
        userNameString.draw(in: userNameStringRect)
        dateString.draw(in: dateStringRect)
        
        // 編集済みの画像を取得
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
