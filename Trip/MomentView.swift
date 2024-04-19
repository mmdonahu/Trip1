import SwiftUI
import Firebase
import FirebaseStorage

struct MomentView: View {
    @ObservedObject var momentManager = MomentManager.shared
    @State private var showingMomentPostView = false
    
    var body: some View {
        VStack {
            // タイトルと投稿ボタン
            HStack {
                Spacer()
                Text("Moment")
                    .font(.largeTitle)
                    .padding()
                Spacer()
                Button(action: {
                    showingMomentPostView = true
                }) {
                    Image(systemName: "plus")
                        .padding()
                }
                .sheet(isPresented: $showingMomentPostView) {
                    MomentPostView()
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            // 投稿リスト
            List(momentManager.posts) { post in
                HStack {
                    VStack(alignment: .leading) {
                        UserInfoView(userName: post.userName, timestamp: post.timestamp)
                        
                        Text(post.postText)
                            .padding(.vertical, 5)
                        
                        if !post.postImageUrl.isEmpty {
                            AsyncImage(url: URL(string: post.postImageUrl)) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .scaledToFit()
                        }
                        
                        LikeButton(postId: post.id, likes: post.likes, likedBy: post.likedBy)

                        
                    }
                    .padding(.leading, 10) // ここで左側の余白を調整
                    Spacer() // これによりコンテンツが左寄せになる
                }
            }
        }
    }
}

struct UserInfoView: View {
    let userName: String
    let timestamp: Date
    @State private var profileImage: Image? = nil // SwiftUIのImageに変更
    
    var body: some View {
        HStack {
            if let profileImage = profileImage {
                profileImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 2))
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 2))
            }
            
            VStack(alignment: .leading) {
                Text(userName)
                    .font(.headline)
                Text(timestamp, formatter: RelativeDateTimeFormatter())
                    .font(.subheadline)
            }
        }
        .onAppear {
            // ユーザープロファイルの画像URLを取得して画像をダウンロードする
            MomentManager.shared.loadUserProfile { displayName, profileImageUrl in
                downloadImage(from: profileImageUrl) { uiImage in
                    self.profileImage = Image(uiImage: uiImage)
                }
            }
        }
    }
    
    private func downloadImage(from urlString: String?, completion: @escaping (UIImage) -> Void) {
        guard let urlString = urlString, let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(uiImage)
                }
            }
        }.resume()
    }
}

struct LikeButton: View {
    let postId: String
    var likes: Int
    var likedBy: [String]
    
    @State private var isLiked: Bool
    
    init(postId: String, likes: Int, likedBy: [String]) {
        self.postId = postId
        self.likes = likes
        self.likedBy = likedBy
        self._isLiked = State(initialValue: likedBy.contains(Auth.auth().currentUser?.uid ?? ""))
    }
    
    var body: some View {
        Button(action: {
            isLiked.toggle() // ユーザーがいいね状態を変更
            MomentManager.shared.likePost(postId: postId) // MomentManagerに更新を通知
        }) {
            HStack {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .foregroundColor(isLiked ? .pink : .gray)
                Text("\(likes)")
            }
        }
    }
}

struct MomentView_Previews: PreviewProvider {
    static var previews: some View {
        MomentView()
    }
}

