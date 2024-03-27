//
//  SignupView.swift
//  Trip
//
//  Created by 香川隼也 on 2024/03/21.
//

import SwiftUI
import FirebaseAuth

struct SignupView: View {
    @State private var fadeInAnimation = false
    @State private var email = "" // ユーザーのメールアドレス入力用
    @State private var password = "" // ユーザーのパスワード入力用
    @State private var errorMessage = "" // エラーメッセージ表示用
    @State private var showPermissionLocationView = false // 遷移制御用の変数
    
    var body: some View {
        VStack(spacing: 20) {
            Image("Trip Collector Logo") // ロゴ画像を表示
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2)
                .clipped()
                .opacity(fadeInAnimation ? 1 : 0)
                .animation(.easeIn(duration: 1.5), value: fadeInAnimation)
                .onAppear {
                    fadeInAnimation = true
                }
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 20)
                .keyboardType(.emailAddress) // キーボードタイプをメールアドレス用に設定
                .autocapitalization(.none) // 自動大文字化を無効化
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 20)
            
            Text(errorMessage)
                .foregroundColor(.red)
            
            Button(action: {
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                    } else {
                        self.errorMessage = "Succeed Sign up！🎉"
                        showPermissionLocationView = true
                    }
                }
            }) {
                Text("Sign up with E-mail and Password")
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 40, height: 50)
                    .background(Color.gray)
                    .cornerRadius(10)
            }
        }
        .padding(.top, -50)
        .fullScreenCover(isPresented: $showPermissionLocationView) {
            PermissionLocationView() // 遷移先のビューを指定
        }
        .onTapGesture {
            // 画面外をタップしたときにキーボードを閉じる処理
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
    }
}
