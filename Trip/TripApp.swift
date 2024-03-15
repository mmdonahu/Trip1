//
//  TripApp.swift
//  Trip
//
//  Created by 香川隼也 on 2024/03/15.
//

import SwiftUI
import GoogleMaps // GoogleMapsをインポートする

@main
struct TripApp: App {
    // AppDelegateクラスを使うための設定
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// 新しくAppDelegateクラスを追加する
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // ここでAPIキーを設定する
        GMSServices.provideAPIKey("AIzaSyC0Qu88Rl9ZctOJU1w3hEJ9uLGmi6JDK8Q")
        return true
    }
}
