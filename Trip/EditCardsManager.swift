import UIKit
import Firebase

class EditCardsManager {
    static let shared = EditCardsManager()
    var cardsManager: CardsManager
    
    init(cardsManager: CardsManager) {
        self.cardsManager = cardsManager
    }
    
    // 画像をドキュメントディレクトリに保存するメソッド
    func saveImageToDocumentsDirectory(image: UIImage, imageName: String) {
        let fileManager = FileManager.default
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let filePath = paths[0].appendingPathComponent("\(imageName).png")
        
        if let data = image.pngData() {
            do {
                try data.write(to: filePath)
                print("Saved image to documents directory.")
            } catch {
                print("Could not save image: \(error)")
            }
        }
    }
    
    // Firebase Storageから画像をダウンロードし、アプリ内に保存するメソッド
    func downloadEditAndSaveImage(checkpointId: String, username: String, completion: @escaping (UIImage?) -> Void) {
        let storageRef = Storage.storage().reference().child("CheckpointCards/\(checkpointId).png")
        storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
                completion(nil)
            } else if let data = data, let image = UIImage(data: data) {
                if let editedImage = self.drawText(image: image, username: username, date: Date()) {
                    self.saveImageToDocumentsDirectory(image: editedImage, imageName: checkpointId)
                    // 未獲得カードとしてCardsManagerに通知
                    self.cardsManager.updateCardAsUnacquired(identifier: checkpointId)
                    completion(editedImage)
                } else {
                    completion(nil)
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
