import SwiftUI

struct MomentPostView: View {
    @State private var postText: String = ""
    @State private var showImagePicker: Bool = false
    @State private var inputImage: UIImage?
    @State private var postImage: Image?
    
    let sampleUserName = "Username"
    let sampleUserImage = Image(systemName: "person.circle.fill")
    
    var body: some View {
        VStack {
            HStack {
                sampleUserImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .padding()
                
                VStack(alignment: .leading) {
                    Text(sampleUserName)
                        .font(.headline)
                    
                    // マルチラインテキストエリアに変更
                    TextEditor(text: $postText)
                        .frame(minHeight: 30, idealHeight: 100, maxHeight: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.secondary, lineWidth: 1)
                        )
                }
                
                Button(action: {
                    self.showImagePicker = true
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
            
            Spacer()
        }
        .navigationBarTitle("Post Moment", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            // 投稿ボタンのアクション
        }) {
            Text("Post").bold()
        })
        .sheet(isPresented: $showImagePicker, onDismiss: loadImage) {
            ImagePicker(image: $inputImage)
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        postImage = Image(uiImage: inputImage)
    }
}

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            
            picker.dismiss(animated: true)
        }
    }
}

struct MomentPostView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MomentPostView()
        }
    }
}

