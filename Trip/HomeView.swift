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

struct HomeView: View {
    @ObservedObject private var userInfoManager = UserInfoManager.shared
    @EnvironmentObject var checkpointManager: CheckpointManager
    @State private var showCheckpointArrivedMessage = false
    @State private var showCongratulationsView = false
    @State private var editedImage: UIImage?
    
    // ユーザーのサンプルデータ
    var nextHunterRank = "Hunter Rank Single"
    var nextRankRequirement = "2 Locations and 1 QR Code"
    var visitedCheckpoints: [Int] = [1, 3, 5]
    
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
                        
                        // プロファイル画像
                        ProfileImageView(urlString: userInfoManager.user?.profileImageUrl ?? "default_profile_image")
                        
                        // ハンターランク
                        Text("Hunter Rank: \(userInfoManager.user?.hunterRank ?? "Zero")")
                            .font(.headline)
                            .padding(.bottom, 1)
                        
                        // ユーザー名
                        Text(userInfoManager.user?.name ?? "Unknown User")
                            .font(.title2)
                            .padding(.bottom, 1)
                        
                        // 年齢と国
                        HStack {
                            Text("Age: \(userInfoManager.user?.age?.description ?? "?")")
                            Text("Country: \(userInfoManager.user?.country?.description ?? "?")")
                        }.font(.body)
                        
                        HStack {
                            VStack {
                                if checkpointManager.notificationReceived {
                                    Text("Get a Certificate!")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                                Image(systemName: "bell.fill")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(checkpointManager.notificationReceived ? .red : .black)
                                    .padding()
                                    .onTapGesture {
                                        if checkpointManager.notificationReceived {
                                            // EditCardsManagerを呼び出して画像のダウンロードと編集を開始
                                            EditCardsManager().downloadEditAndSaveImage(checkpointId: "1", username: "Shunya Kagawa") { image in
                                                guard let image = image else { return }
                                                self.editedImage = image
                                                self.showCongratulationsView = true
                                            }
                                        }
                                    }
                            }
                            
                            // Edit Profileボタン
                            NavigationLink(destination: UserInformationView()) {
                                Text("Edit Profile")
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                       
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
                    if showCheckpointArrivedMessage {
                        // チェックポイント到達時のメッセージまたはCongratulationsViewへの遷移を表示
                        NavigationLink(destination: CongratulationsView(cardImage: Image("sampleImage")), isActive: $showCheckpointArrivedMessage) {
                            EmptyView()
                        }
                    }
                }
          
            }.navigationBarHidden(true) // ナビゲーションバーを非表示に
            .onAppear {
                userInfoManager.loadUserInfo()
            }
        }
    }

// プロファイル画像を表示するためのビュー
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(CheckpointManager.shared)
    }
}

