import SwiftUI
import Firebase

struct MomentPostView: View {
    @State private var postText: String = ""
    @State private var showPhotoPicker: Bool = false
    @State private var inputImage: UIImage?
    @State private var postImage: Image?
    @State private var isPosting: Bool = false
    @State private var postError: String?
    @State private var userDisplayName: String = "Loading..."
    @State private var userProfileImage: UIImage? = UIImage(systemName: "person.circle.fill")
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                }
                .padding()
                
                Spacer()
                Text("Post Moment")
                    .font(.largeTitle)
                    .padding()
                Spacer() // タイトルとボタンの間にスペースを追加
                
                Button(action: {
                    self.postToFirebase()
                }) {
                    Text("Post")
                        .bold()
                        .foregroundColor(.blue)
                }
                .padding()
            }
            
            HStack {
                if let userProfileImage = userProfileImage {
                    Image(uiImage: userProfileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .padding()
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .padding()
                }
                
                VStack(alignment: .leading) {
                    Text(userDisplayName)
                        .font(.headline)
                    
                    TextEditor(text: $postText)
                        .frame(minHeight: 30, idealHeight: 100, maxHeight: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.secondary, lineWidth: 1)
                        )
                }
                
                Button(action: {
                    self.showPhotoPicker = true
                }) {
                    Image(systemName: "photo")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding()
                }
            }
            
            if let postImage = postImage {
                postImage
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .padding()
            }
            
            if isPosting {
                ProgressView()
            }
            
            Spacer()
        }
        .sheet(isPresented: $showPhotoPicker, onDismiss: loadImage) {
            PhotoPicker(image: self.$inputImage)
        }
        .alert(isPresented: .constant($postError.wrappedValue != nil)) {
            Alert(title: Text("Error"), message: Text($postError.wrappedValue ?? "Unknown error"), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            self.loadUserData()
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        postImage = Image(uiImage: inputImage)
    }
    
    func loadUserData() {
        MomentManager.shared.loadUserProfile { displayName, profileImageUrl in
            DispatchQueue.main.async {
                self.userDisplayName = displayName ?? "No Name"
                if let profileImageUrl = profileImageUrl, let url = URL(string: profileImageUrl) {
                    URLSession.shared.dataTask(with: url) { data, _, _ in
                        if let data = data {
                            DispatchQueue.main.async {
                                self.userProfileImage = UIImage(data: data)
                            }
                        }
                    }.resume()
                }
            }
        }
    }
    
    func postToFirebase() {
        guard let currentUser = Auth.auth().currentUser, let inputImage = inputImage else {
            self.postError = "Authentication failed or no image selected."
            return
        }
        
        guard !postText.isEmpty else {
            self.postError = "Please enter some text for the post."
            return
        }
        
        isPosting = true
        
        // 1. 画像をDataに変換
        guard let imageData = inputImage.jpegData(compressionQuality: 0.75) else {
            self.postError = "Image conversion failed."
            self.isPosting = false
            return
        }
        
        // 2. Firebase Storageに画像をアップロード
        let imageRef = Storage.storage().reference().child("postImages/\(UUID().uuidString).jpg")
        imageRef.putData(imageData, metadata: nil) { (metadata, error) in
            guard error == nil else {
                self.postError = "Image upload failed: \(error!.localizedDescription)"
                self.isPosting = false
                return
            }
            
            // 3. アップロードされた画像のURLを取得
            imageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    self.postError = "Fetch image URL failed: \(error!.localizedDescription)"
                    self.isPosting = false
                    return
                }
                
                // 4. Firestoreに投稿データを保存
                let db = Firestore.firestore()
                db.collection("moments").addDocument(data: [
                    "userId": currentUser.uid,
                    "postText": self.postText,
                    "postimageUrl": downloadURL.absoluteString,
                    "timestamp": FieldValue.serverTimestamp()
                ]) { error in
                    if let error = error {
                        self.postError = "Firestore save failed: \(error.localizedDescription)"
                    } else {
                        // 投稿成功
                        self.postError = nil
                        self.postText = "" // テキストフィールドをクリア
                        self.postImage = nil // 投稿イメージをクリア
                    }
                    self.isPosting = false
                    self.presentationMode.wrappedValue.dismiss() // ここで画面を閉じる
                }
            }
        }
    }
}

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Do nothing
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct MomentPostView_Previews: PreviewProvider {
    static var previews: some View {
        MomentPostView()
    }
}

