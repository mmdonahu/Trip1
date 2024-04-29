import SwiftUI

struct CongratulationsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var cardsManager: CardsManager
    @State private var cardImage: UIImage?
    let cardIndex: Int  // カードのインデックスを受け取る
    
    var body: some View {
        VStack {
            if let image = cardImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 300)
            } else {
                Text("Loading image...")
            }
            Button("Get the Certificate!") {
                // カード獲得メソッドを呼び出す
                cardsManager.acquireCard(at: cardIndex)
                presentationMode.wrappedValue.dismiss()
            }
            .font(.title)
        }
        .onAppear {
            loadNextUnseenImage()
        }
    }
    
    func loadNextUnseenImage() {
        let fileManager = FileManager.default
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        guard let directoryPath = paths.first else { return }
        
        do {
            let files = try fileManager.contentsOfDirectory(at: directoryPath, includingPropertiesForKeys: nil)
            let unseenFiles = files.filter { !UserDefaults.standard.bool(forKey: $0.lastPathComponent) }
            
            if let nextFile = unseenFiles.first {
                if let imageData = try? Data(contentsOf: nextFile), let image = UIImage(data: imageData) {
                    cardImage = image
                    UserDefaults.standard.set(true, forKey: nextFile.lastPathComponent)
                }
            }
        } catch {
            print("Error loading images from documents directory: \(error)")
        }
    }
}

struct CongratulationsView_Previews: PreviewProvider {
    static var previews: some View {
        CongratulationsView(cardsManager: CardsManager(), cardIndex: 0)
    }
}

