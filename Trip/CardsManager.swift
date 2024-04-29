import SwiftUI

class CardsManager: ObservableObject {
    @Published var cards: [Card] = []
    
    // 仮想のカードデータの初期化
    init() {
        cards = (0..<15).map { _ in
            Card(isAcquired: false) // 初期状態ではすべてのカードが獲得されていないとします
        }
    }
    
    // カードの獲得状態を更新するメソッド
    func acquireCard(at index: Int) {
        if cards.indices.contains(index) {
            cards[index].isAcquired = true
        }
    }
}

struct Card: Identifiable {
    let id = UUID()
    var isAcquired: Bool
    var frontImageName: String = "frontCardPic" // 獲得時に表示されるカードの表面の画像名
}

