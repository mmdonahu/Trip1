//
//  ContentView.swift
//  Trip Collector
//
//  Created by 香川隼也 on 2024/03/04.
//

import SwiftUI

struct ContentView: View {
    @State private var fadeInAnimation = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image("Trip Collector Logo")
                .resizable()
                .aspectRatio(contentMode: .fill) // 画面幅に合わせて画像を拡大し、アスペクト比を維持します。
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2)
                .clipped() // 画像がVStackの高さを超える場合、超えた部分をクリップします。
                .opacity(fadeInAnimation ? 1 : 0)
                .animation(.easeIn(duration: 1.5), value: fadeInAnimation)
                .onAppear {
                    fadeInAnimation = true
                }
            
            Button(action: {
                // Google認証の処理
            }) {
                Text("Sign up with Google")
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 40, height: 50)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            
            Button(action: {
                // Facebook認証の処理
            }) {
                Text("Sign up with Facebook")
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 40, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Button(action: {
                // メールとパスワード認証の処理
            }) {
                Text("Sign up with E-mail and Password")
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 40, height: 50)
                    .background(Color.gray)
                    .cornerRadius(10)
            }
        }
        .padding(.top, -50) // VStackの上部に余白を調整します。
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

