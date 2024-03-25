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
        NavigationView { // ここでNavigationViewを追加
            VStack(spacing: 20) {
                Image("Trip Collector Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2)
                    .clipped()
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
                
                NavigationLink(destination: SignupView()) { // NavigationLinkを使用してSignupViewへ遷移
                    Text("Sign up with E-mail and Password")
                        .foregroundColor(.white)
                        .frame(width: UIScreen.main.bounds.width - 40, height: 50)
                        .background(Color.gray)
                        .cornerRadius(10)
                }
            }
            .padding(.top, -50)
        }
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

