import SwiftUI

struct MomentView: View {
    @ObservedObject var momentManager = MomentManager.shared
    @State private var showingMomentPostView = false // ここに追加します
    
    var body: some View {
        List(momentManager.posts) { postTime in
            VStack(alignment: .leading) {
                HStack {
                    
                    Spacer()
                    
                    Text("Moments")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    Spacer()
                    
                    Button(action: {
                        showingMomentPostView = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
                
                Spacer()
            }
            .sheet(isPresented: $showingMomentPostView) {
                MomentPostView() // 実際のMomentPostViewに置き換え
            }
            
                HStack {
                    Image(systemName: "person.circle.fill") // 本来はユーザーのプロフィール画像を表示する
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                    
                    VStack(alignment: .leading) {
                        Text(postTime.userName)
                            .font(.headline)
                        // 実際のタイムスタンプから相対的な時間を計算する必要があります
                        Text(postTime.timestamp, formatter: RelativeDateTimeFormatter())
                            .font(.subheadline)
                    }
                }
                
                Text(postTime.postText)
                    .padding(.vertical, 5)
                
                // 実際の画像をFirebase StorageのURLから取得して表示する
                // この部分はダミーの画像で置き換えられるべきです
                FirebaseImageView(imageUrl: postTime.postImageUrl)
                    .scaledToFit()
                
                HStack {
                    Button(action: {
                        // いいね機能を実装
                        momentManager.updateLikes(postId: postTime.id, newLikes: postTime.likes + 1)
                    }) {
                        Image(systemName: "heart")
                    }
                    Text("\(postTime.likes)")
                    Spacer()
                    // その他のアクションボタンや表示はここに配置
                }
                .padding(.vertical, 5)
            }
        }
    }
    struct postTime: Identifiable {
        var id: String
        var userId: String
        var userName: String
        var postText: String
        var postImageUrl: String
        var timestamp: Date
        var likes: Int
    }
    
    // Preview
    struct MomentView_Previews: PreviewProvider {
        static var previews: some View {
            MomentView()
        }
    }
    
    // 仮のFirebaseImageView実装
    struct FirebaseImageView: View {
        let imageUrl: String
        
        var body: some View {
            // ここで実際のFirebase Storageの画像をダウンロードして表示するコンポーネントが必要
            Image(systemName: "photo") // 仮のプレースホルダー
                .resizable()
                .frame(width: 200, height: 200)
                .aspectRatio(contentMode: .fit)
        }
    }

