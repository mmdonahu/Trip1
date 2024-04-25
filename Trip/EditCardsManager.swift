import UIKit
import Firebase

class EditCardsManager {
    static let shared = EditCardsManager()
    // チェックポイントの画像をダウンロードし、編集して保存するメソッド
    func downloadEditAndSaveImage(checkpointId: String, username: String, completion: @escaping (UIImage?) -> Void) {
        let storageRef = Storage.storage().reference().child("checkpoints/\(checkpointId).png")
        // 画像のダウンロード
        storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
                completion(nil)
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                print("画像の読み込みに失敗")
                completion(nil)
                return
            }
            // 画像の編集
            if let editedImage = self.drawText(image: image, username: username, date: Date()) {
                // 画像の保存とcompletion handlerの呼び出し
                UIImageWriteToSavedPhotosAlbum(editedImage, nil, nil, nil)
                completion(editedImage)
            } else {
                completion(nil)
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
