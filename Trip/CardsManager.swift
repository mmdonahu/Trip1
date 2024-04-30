import Foundation

class CardsManager: ObservableObject {
    @Published var cards: [Card] = []
    
    init() {
        // IDを基にカードオブジェクトを初期化します。
        cards = (1...15).map { index in
            Card(isAcquired: false, identifier: "card\(index)")
        }
    }
    
    // カードを獲得するメソッド
    func acquireCard(identifier: String) {
        if let index = cards.firstIndex(where: { $0.identifier == identifier }) {
            cards[index].isAcquired = true
            // 獲得したカードの情報を更新するためのコードをここに追加します。
            // 例えば、ローカルのファイル名を取得し、Cardオブジェクトを更新します。
        }
    }
    
    func moveAcquiredCardToFront(at index: Int) {
        guard index < cards.count, cards[index].isAcquired else { return }
        
        let acquiredCard = cards.remove(at: index)
        cards.insert(acquiredCard, at: 0)
    }
}

struct Card: Identifiable {
    let id: UUID = UUID()
    var isAcquired: Bool
    var identifier: String // Firebaseのファイル名に対応する識別子
    // ローカルに保存された画像へのパスを格納するプロパティも追加することができます。
    var localImagePath: String?
}
