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
import UserNotifications

@main
struct TripApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // UserDefaultsから初回起動かどうかを判断するフラグを取得
    var hasLaunchedOnce: Bool {
        UserDefaults.standard.bool(forKey: "HasLaunchedOnce")
    }
    
    var body: some Scene {
        WindowGroup {
            if let debugView = ProcessInfo.processInfo.environment["DEBUG_VIEW"], !debugView.isEmpty {
                if debugView == "ContentView" {
                    ContentView().environmentObject(CheckpointManager.shared)
                } else {
                    ContentView().environmentObject(CheckpointManager.shared) // 初期ビューまたはデフォルトビュー
                }
            } else if hasLaunchedOnce {
                MainTabView().environmentObject(CheckpointManager.shared) // MainTabViewへの遷移
            } else {
                ContentView().environmentObject(CheckpointManager.shared) // 初期ビューまたはウェルカムビュー
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
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notificatuon permission granted")
            } else {
                print("Notification permission denied")
            }
        }
        // GeofenceManagerのシングルトンインスタンスを初期化
        _ = GeofenceManager.shared
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // GoogleSignInの処理
        return GIDSignIn.sharedInstance.handle(url)
    }
}
