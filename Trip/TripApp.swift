//
//  TripApp.swift
//  Trip
//
//  Created by 香川隼也 on 2024/03/15.
//

import SwiftUI
import GoogleMaps
import Firebase
import GoogleSignIn

@main
struct TripApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // UserDefaultsから初回起動かどうかを判断するフラグを取得
    var hasLaunchedOnce: Bool {
        UserDefaults.standard.bool(forKey: "HasLaunchedOnce")
    }
    
    var body: some Scene {
        WindowGroup {
            if hasLaunchedOnce {
                // 以前にアプリを起動したことがある場合、直接MainTabViewを表示
                MainTabView() // MainTabViewが未定義なので、実際のプロジェクトに合わせたビューに置き換えてください
            } else {
                // 初回起動時はContentViewからスタート
                ContentView()
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        GMSServices.provideAPIKey("AIzaSyC0Qu88Rl9ZctOJU1w3hEJ9uLGmi6JDK8Q")
        
        // Firebaseを初期化
        FirebaseApp.configure()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
