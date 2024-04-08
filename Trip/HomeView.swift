import SwiftUI

struct HomeView: View {
    
    // ユーザーのサンプルデータ
    var profileImage = Image("image1")
    var userName = "Shunya Kagawa"
    var userAge = 32
    var userCountry = "Japan"
    var currentHunterRank = "Hunter Rank Zero"
    var nextHunterRank = "Hunter Rank Single"
    var nextRankRequirement = "2 Locations and 1 QR Code"
    
    // グリッドで使用するカラム定義
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    var body: some View {
        NavigationView { // NavigationViewを追加
            VStack(spacing: 0) {
                ScrollView {
                    VStack {
                        Text("Japan Hunter Rank")
                            .font(.title)
                            .padding()
                        
                        Text(currentHunterRank)
                            .font(.headline)
                            .padding([.bottom], 1)
                        
                        profileImage
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .padding()
                        
                        Text(userName)
                            .font(.title2)
                            .padding([.bottom], 1)
                        
                        HStack {
                            Text("Age: \(userAge), \(userCountry)")
                                .font(.body)
                            
                            // Edit Profileボタン
                            NavigationLink(destination: UserInformationView()) {
                                Text("Edit Profile")
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                        }.padding([.bottom], 1)
                        
                        Text("Next Hunter Rank: \(nextHunterRank)")
                            .font(.headline)
                            .padding([.bottom], 1)
                        
                        Text("To Next Rank: \(nextRankRequirement)")
                            .font(.headline)
                            .padding(.bottom, 20)
                        
                        // カード画像のグリッド表示
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(0..<15, id: \.self) { _ in
                                Image("skytree1") // ここにカード画像名を指定
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 140)
                            }
                        }
                        .padding(.bottom, 20) // グリッド全体の下部に余白を追加
                    }
                }
            }.navigationBarHidden(true) // ナビゲーションバーを非表示に
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

