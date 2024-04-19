import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import CoreLocation

// ユーザー情報を表示・編集するView
struct UserInformationView: View {
    // State変数の定義
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var country: String = ""
    @State private var gender: String = "Male"
    @State private var profileImage: UIImage? = nil
    @State private var isImagePickerDisplayed = false
    @State private var isLocationEnabled = CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                userInfoSection
                locationToggleSection
                saveButton
            }
            .sheet(isPresented: $isImagePickerDisplayed) {
                ImagePicker(image: $profileImage)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Save Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                loadUserInfo()
            }
        }
    }
    
    // ユーザー情報入力セクション
    private var userInfoSection: some View {
        Section(header: Text("Your Information")) {
            TextField("Name", text: $name)
            TextField("Age", text: $age)
                .keyboardType(.numberPad)
            TextField("Country", text: $country)
            Picker("Gender", selection: $gender) {
                Text("Male").tag("Male")
                Text("Female").tag("Female")
            }.pickerStyle(SegmentedPickerStyle())
            
            if let profileImage = profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFit()
            }
            Button("Upload Profile Image") {
                self.isImagePickerDisplayed = true
            }
        }
    }
    
    // 位置情報有効化トグル
    private var locationToggleSection: some View {
        Section {
            Toggle(isOn: $isLocationEnabled) {
                Text("Enable Location")
            }
            .onChange(of: isLocationEnabled) { newValue in
                promptLocationSettingsIfNeeded(isEnabled: newValue)
            }
            .toggleStyle(SwitchToggleStyle(tint: .green))
        }
    }
    
    // 保存ボタン
    private var saveButton: some View {
        Button("Save") {
            saveUserInfo()
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.green)
        .cornerRadius(10)
    }
    
    // ユーザー情報の読み込み
    func loadUserInfo() {
        // ユーザーID取得とFirestoreからの情報読み込み
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { (document, error) in
            if let document = document, document.exists, let data = document.data() {
                updateUserInfo(with: data)
            } else {
                print("No user data found or user is not logged in.")
            }
        }
    }
    
    // ユーザー情報の保存
    func saveUserInfo() {
        // ユーザーID取得とFirestoreへの情報保存
        guard let userId = Auth.auth().currentUser?.uid else {
            showAlertWith(message: "Failed to get user ID.")
            return
        }
        
        if let profileImage = self.profileImage {
            uploadProfileImage(profileImage) { url in
                saveUserData(userId: userId, imageUrl: url?.absoluteString)
            }
        } else {
            saveUserData(userId: userId)
        }
    }
    
    // Firestoreから取得したデータでUIを更新
    private func updateUserInfo(with data: [String: Any]) {
        DispatchQueue.main.async {
            self.name = data["name"] as? String ?? ""
            self.age = "\(data["age"] as? Int ?? 0)"
            self.country = data["country"] as? String ?? ""
            self.gender = data["gender"] as? String ?? "Male"
            // 画像のURLがあればそれを使ってUIImageを設定
            if let profileImageUrl = data["profileImageUrl"] as? String, let url = URL(string: profileImageUrl) {
                // この部分では、URLからUIImageを非同期で取得し、profileImageに設定する必要があります。
                // SwiftUIでは直接的な非同期画像読み込みがサポートされていないため、
                // この機能を実装するには追加のヘルパー関数やサードパーティライブラリを利用する必要があります。
                // ここではその部分の実装は示されていませんが、必要に応じて対応してください。
            }
        }
    }
    
    // プロフィール画像のアップロード
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
            } else {
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print(error.localizedDescription)
                        completion(nil)
                    }
                    completion(url)
                }
            }
        }
    }
    
    // Firestoreにユーザー情報を保存
    private func saveUserData(userId: String, imageUrl: String? = nil) {
        var data: [String: Any] = [
            "name": self.name,
            "age": Int(self.age) ?? 0,
            "country": self.country,
            "gender": self.gender // 性別のデータを追加
        ]
        
        if let imageUrl = imageUrl {
            data["profileImageUrl"] = imageUrl
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).setData(data, merge: true) { err in
            if let err = err {
                showAlertWith(message: "Error updating Profile: \(err)")
            } else {
                showAlertWith(message: "Profile successfully updated")
            }
        }
    }
    
    // アラート表示用ヘルパー
    private func showAlertWith(message: String) {
        alertMessage = message
        showAlert = true
    }
    
    // 位置情報設定プロンプト
    private func promptLocationSettingsIfNeeded(isEnabled: Bool) {
        if isEnabled, let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

// ImagePicker定義は変更なし
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

// プレビュープロバイダーは変更なし
struct UserInformationView_Previews: PreviewProvider {
    static var previews: some View {
        UserInformationView()
    }
}

