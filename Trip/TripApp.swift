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
            // 環境変数に基づいて特定のビューを直接表示するかを決定
            if let debugView = ProcessInfo.processInfo.environment["DEBUG_VIEW"], !debugView.isEmpty {
                // 'PermissionLocationView'が指定された場合、そのビューを直接表示
                if debugView == "MainTabView" {
                    MainTabView()
                } else {
                    // 指定されたビューが見つからない場合のフォールバック
                    ContentView() // 初期ビューまたはデフォルトビュー
                }
            } else if hasLaunchedOnce {
                // 以前にアプリを起動したことがある場合、直接MainTabViewを表示
                MainTabView() // MainTabViewへの遷移
            } else {
                // 初回起動時はContentViewからスタート
                ContentView() // 初期ビューまたはウェルカムビュー
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Google MapsのAPIキーを提供
        GMSServices.provideAPIKey("AIzaSyC0Qu88Rl9ZctOJU1w5hJ9uLGmi6JDK8Q")
        
        // Firebaseを初期化
        FirebaseApp.configure()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // GoogleSignInの処理
        return GIDSignIn.sharedInstance.handle(url)
    }
}
