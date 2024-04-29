import Foundation

class CardsManager: ObservableObject {
    @Published var cards: [Card] = []
    
    init() {
        // カードの初期化
        cards = (0..<15).map { _ in Card(isAcquired: false) }
    }
    
    func acquireCard(at index: Int) {
        guard index < cards.count else { return }
        cards[index].isAcquired = true
    }
}

struct Card: Identifiable {
    let id = UUID()
    var isAcquired: Bool
    var frontImageName: String
}

