import SwiftUI

struct MomentView: View {
    // サンプルの投稿データを模擬的に作成
    let moments = [
        Moment(userName: "佐藤 太郎", timeAgo: "32分", postImage: "river", likes: 3, postText: "テスト"),
        Moment(userName: "さら 大原", timeAgo: "22分", postImage: "selfie", likes: 1, postText: "今日大阪で17:00-21:00くらいまで空いてる方いませんか😳"),
        Moment(userName: "てくん", timeAgo: "42分", postImage: "food", likes: 3, postText: "ランチ最高")
    ]
    
    var body: some View {
        List(moments) { moment in
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                    
                    VStack(alignment: .leading) {
                        Text(moment.userName)
                            .font(.headline)
                        Text("\(moment.timeAgo)前")
                            .font(.subheadline)
                    }
                }
                
                Text(moment.postText)
                    .padding(.vertical, 5)
                
                Image(moment.postImage)
                    .resizable()
                    .scaledToFit()
                
                HStack {
                    Button(action: {}) {
                        Image(systemName: "heart")
                    }
                    Text("\(moment.likes)")
                    Spacer()
                    // その他のアクションボタンや表示はここに配置
                }
                .padding(.vertical, 5)
            }
        }
    }
}

struct Moment: Identifiable {
    let id = UUID()
    let userName: String
    let timeAgo: String
    let postImage: String
    let likes: Int
    let postText: String
}

// Preview
struct MomentView_Previews: PreviewProvider {
    static var previews: some View {
        MomentView()
    }
}

