import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import CoreLocation

struct UserInformationView: View {
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var country: String = ""
    @State private var profileImage: UIImage? = nil
    @State private var isImagePickerDisplayed = false
    @State private var isLocationEnabled = CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways
    @State private var showAlert = false // アラート表示のための状態
    @State private var alertMessage = "" // アラートのメッセージ
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Your Information")) {
                    TextField("Name", text: $name)
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                    TextField("Country", text: $country)
                    
                    if let profileImage = profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFit()
                    }
                    Button("Upload Profile Image") {
                        self.isImagePickerDisplayed = true
                    }
                }
                Section {
                    Toggle(isOn: $isLocationEnabled) {
                        Text("Enable Location")
                    }
                    .onChange(of: isLocationEnabled) { newValue in
                        if newValue {
                            // スイッチがオンにされたときに設定アプリを開く
                            if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .green))
                }
                Button("Save") {
                    saveUserInfo()
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .cornerRadius(10)
            }
            .sheet(isPresented: $isImagePickerDisplayed) {
                ImagePicker(image: self.$profileImage)
            }
            .alert(isPresented: $showAlert) { // アラートを表示
                Alert(title: Text("Save Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                loadUserInfo()
            }
        }
    }
    
    func loadUserInfo() {
        // ユーザーIDの取得に失敗した場合、以降の処理を行わないようにしますが、エラーメッセージは設定しません。
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { (document, error) in
            if let document = document, document.exists, let data = document.data() {
                DispatchQueue.main.async {
                    self.name = data["name"] as? String ?? ""
                    self.age = "\(data["age"] as? Int ?? 0)"
                    self.country = data["country"] as? String ?? ""
                    // 画像URLを取得し、表示する処理はここに追加
                }
            } else {
                // ドキュメントが存在しない場合の処理をここに追加できますが、
                // 初回アクセス時にはユーザーデータが存在しないことが普通なので、
                // 不要なエラーメッセージは表示しない方がユーザー体験が向上します。
                print("No user data found or user is not logged in.")
            }
        }
    }

    
    func saveUserInfo() {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.alertMessage = "Failed to get user ID."
            self.showAlert = true
            return
        }
        let db = Firestore.firestore()
        
        if let profileImage = self.profileImage {
            uploadProfileImage(profileImage) { url in
                db.collection("users").document(userId).setData([
                    "name": self.name,
                    "age": Int(self.age) ?? 0,
                    "country": self.country,
                    "profileImageUrl": url?.absoluteString ?? ""
                ], merge: true) { err in
                    if let err = err {
                        self.alertMessage = "Error updating Profile: \(err)"
                        self.showAlert = true
                    } else {
                        self.alertMessage = "Profile successfully updated"
                        self.showAlert = true
                    }
                }
            }
        } else { // 画像がない場合でも情報は保存
            db.collection("users").document(userId).setData([
                "name": self.name,
                "age": Int(self.age) ?? 0,
                "country": self.country
            ], merge: true) { err in
                if let err = err {
                    self.alertMessage = "Error updating Profile: \(err)"
                    self.showAlert = true
                } else {
                    self.alertMessage = "Profile successfully updated"
                    self.showAlert = true
                }
            }
        }
    }
    
    func uploadProfileImage(_ image: UIImage, completion: @escaping (_ url: URL?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.4) else {
            completion(nil)
            return
        }
        let storageRef = Storage.storage().reference().child("profileImages/\(UUID().uuidString).jpg")
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
                return
            }
            storageRef.downloadURL { url, error in
                if let error = error {
                    print(error.localizedDescription)
                    completion(nil)
                    return
                }
                completion(url)
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.image = image
            }
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

struct UserInformationView_Previews: PreviewProvider {
    static var previews: some View {
        UserInformationView()
    }
}

