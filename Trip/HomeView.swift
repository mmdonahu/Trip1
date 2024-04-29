import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String?
    var age: Int?
    var country: String?
    var hunterRank: String?
    var profileImageUrl: String?
}

struct ProfileImageView: View {
    let urlString: String?
    
    var body: some View {
        if let urlString = urlString, let imageUrl = URL(string: urlString) {
            AsyncImage(url: imageUrl) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } placeholder: {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            }
        } else {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipShape(Circle())
        }
    }
}

struct HomeView: View {
    @ObservedObject private var userInfoManager = UserInfoManager.shared
    @EnvironmentObject var checkpointManager: CheckpointManager
    @State private var showCheckpointArrivedMessage = false
    @State private var showCongratulationsView = false
    @ObservedObject var notificationManager = NotificationManager.shared
    @StateObject var cardsManager = CardsManager()
    
    // ユーザーのサンプルデータ
    var nextHunterRank = "Hunter Rank Single"
    var nextRankRequirement = "2 Locations and 1 QR Code"
    var visitedCheckpoints: [Int] = [1, 3, 5]
    
    // グリッドで使用するカラム定義
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack {
                        Text("Japan Hunter Rank")
                            .font(.title)
                            .padding()
                        
                        if let imageUrl = userInfoManager.user?.profileImageUrl, !imageUrl.isEmpty {
                            ProfileImageView(urlString: imageUrl)
                                .frame(width: 100, height: 100)  // 必要に応じてサイズ調整
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                        }
                        
                        Text("Hunter Rank: \(userInfoManager.user?.hunterRank ?? "Zero")")
                            .font(.headline)
                            .padding(.bottom, 1)
                        
                        Text(userInfoManager.user?.name ?? "Unknown User")
                            .font(.title2)
                            .padding(.bottom, 1)
                        
                        HStack {
                            Text("Age: \(userInfoManager.user?.age?.description ?? "?")")
                            Text("Country: \(userInfoManager.user?.country?.description ?? "?")")
                        }.font(.body)
                        
                        HStack {
                            VStack {
                                if notificationManager.bellState == .alerted {
                                    Text("Get a Certificate!")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                                Image(systemName: "bell.fill")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(notificationManager.bellState == .alerted ? .red : .black)
                                    .padding()
                                    .onTapGesture {
                                        if notificationManager.bellState == .alerted {
                                            self.showCongratulationsView = true
                                            NotificationManager.shared.updateBellState(for: 1, hasDownloaded: true, hasBeenViewed: false)
                                        }
                                    }
                            }
                            
                            NavigationLink(destination: UserInformationView()) {
                                Text("Edit Profile")
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Text("Next Hunter Rank: \(nextHunterRank)")
                            .font(.headline)
                            .padding([.bottom], 1)
                        
                        Text("To Next Rank: \(nextRankRequirement)")
                            .font(.headline)
                            .padding(.bottom, 20)
                        
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(cardsManager.cards) { card in
                                Image(card.isAcquired ? card.frontImageName : "behindCardPic")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 140)
                                    .onTapGesture {
                                        // ここでカードのタップに応じた処理を追加する
                                        // 例えばカードを獲得するなど
                                    }
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                userInfoManager.loadUserInfo()
                NotificationManager.shared.updateBellState(for: 1, hasDownloaded: true, hasBeenViewed: false)
            }
        }
        .sheet(isPresented: $showCongratulationsView) {
            CongratulationsView()
        }
    }
}
        

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(CheckpointManager.shared)
    }
}

