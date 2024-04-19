import SwiftUI

struct CongratulationsView: View {
    var cardImage: Image
    
    var body: some View {
        VStack {
            cardImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 300)
            
            Text("Congratulations!")
                .font(.title)
                .padding()
        }
    }
}

struct CongratulationsView_Previews: PreviewProvider {
    static var previews: some View {
        CongratulationsView(cardImage: Image("sampleImage"))
    }
}

