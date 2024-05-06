import SwiftUI

struct CongratulationsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var cardsManager: CardsManager
    @State private var cardImage: UIImage?
    @State private var errorMessage: String?
    let cardIndex: Int
    
    var body: some View {
        VStack {
            if let image = cardImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 300)
            } else if let message = errorMessage {
                Text(message)
                    .foregroundColor(.red)
            } else {
                Text("Loading image...")
                    .foregroundColor(.gray)
            }
            
            // This button will always be displayed, regardless of the image loading state
            Button("Get the Certificate!") {
                let cardIdentifier = cardsManager.cards[cardIndex].identifier
                cardsManager.acquireCard(identifier: cardIdentifier)
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
        guard let directoryPath = paths.first else {
            errorMessage = "Error: Could not find the documents directory."
            return
        }
        
        do {
            let files = try fileManager.contentsOfDirectory(at: directoryPath, includingPropertiesForKeys: nil)
            let unseenFiles = files.filter { !UserDefaults.standard.bool(forKey: $0.lastPathComponent) }
            
            if let nextFile = unseenFiles.first {
                if let imageData = try? Data(contentsOf: nextFile), let image = UIImage(data: imageData) {
                    cardImage = image
                    UserDefaults.standard.set(true, forKey: nextFile.lastPathComponent)
                } else {
                    errorMessage = "Error: Unable to load image from disk."
                }
            } else {
                errorMessage = "No unseen images available."
            }
        } catch {
            errorMessage = "Error loading images from documents directory: \(error)"
        }
    }
}

struct CongratulationsView_Previews: PreviewProvider {
    static var previews: some View {
        CongratulationsView(cardsManager: CardsManager(), cardIndex: 0)
    }
}

