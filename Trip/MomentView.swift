import SwiftUI
import Firebase
import FirebaseStorage

struct MomentView: View {
    @ObservedObject var momentManager = MomentManager.shared
    @State private var showingMomentPostView = false
    
    var body: some View {
        List(momentManager.posts) { post in
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Text("Moment")
                        .padding()
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
                MomentPostView() // この行のコメントアウトを解除
            }
            
            
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                
                VStack(alignment: .leading) {
                    Text(post.userName)
                        .font(.headline)
                    Text(post.timestamp, formatter: RelativeDateTimeFormatter())
                        .font(.subheadline)
                }
            }
            
            Text(post.postText)
                .padding(.vertical, 5)
            
            FirebaseImageView(imageUrl: post.postImageUrl)
                .scaledToFit()
            
            HStack {
                Button(action: {
                    MomentManager.shared.likePost(postId: post.id)
                }) {
                    Image(systemName: "heart")
                }
                Text("\(post.likedBy.count)")
                Spacer()
            }
            .padding(.vertical, 5)
        }
    }
}
    // FirebaseImageViewの機能をここに組み込む
    struct FirebaseImageView: View {
        let imageUrl: String
        @State private var downloadedImage: UIImage?
        
        var body: some View {
            Group {
                if let downloadedImage = downloadedImage {
                    Image(uiImage: downloadedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            .frame(width: 200, height: 200)
            .onAppear {
                downloadImage()
            }
        }
        
        private func downloadImage() {
            let storageRef = Storage.storage().reference(withPath: imageUrl)
            storageRef.getData(maxSize:Int64(1 * 1024 * 1024)) { data, error in
                if let error = error {
                    print("Error downloading image: \(error)")
                    return
                }
                if let data = data, let image = UIImage(data: data) {
                    self.downloadedImage = image
                }
            }
        }
    }


struct MomentView_Previews: PreviewProvider {
    static var previews: some View {
        MomentView()
    }
}

