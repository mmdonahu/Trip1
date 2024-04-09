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
    
    var body: some View {
        VStack {
            HStack {
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
        // Load user data from Firebase and update the state variables
    }
    
    func postToFirebase() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        guard !postText.isEmpty, let inputImage = inputImage else {
            postError = "Please enter text and select an image."
            return
        }
        
        isPosting = true
        // Here you would call the method to upload the image and create the post
        // After creating the post, you should set isPosting to false and clear the postError
    }
}

// 'PhotoPicker'の部分にこれを書くんだ
struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // ここは特に何も書かなくても大丈夫だよ
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


// Make sure to create a Preview Provider for your SwiftUI view
struct MomentPostView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { // ここでNavigationViewを追加
            MomentPostView()
        }
    }
}


