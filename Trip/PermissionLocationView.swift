//
//  Register Membership.swift
//  Trip Collector
//
//  Created by 香川隼也 on 2024/03/05.
//

import SwiftUI
import CoreLocation

struct PermissionLocationView: View {
    @State private var locationPermissionGranted = false
    // CLLocationManagerのインスタンスはここで保持する
    private let locationManager = CLLocationManager()
    
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "location.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            Text("Allow us to use your location")
                .font(.title)
                .padding()
            Text("Please allow us to use your location to better serve you")
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: {
                // 位置情報の許可を求める処理
                requestLocationPermission()
            }) {
                Text("Allow the use of location information")
                    .foregroundColor(.white)
                    .frame(width: 320, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            Spacer()
        }
        .onChange(of: locationPermissionGranted) { newValue in
            if newValue {
                // 位置情報が許可されたらRuleDescriptionViewへ遷移
                // この部分はあなたのアプリのナビゲーションフローに合わせて調整してください
                showRuleDescriptionView()
            }
        }
        .onAppear {
            // ビューが表示されたときに位置情報の許可状態を確認
            checkLocationAuthorizationStatus()
        }
    }
    
    private func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
        checkLocationAuthorizationStatus()
    }
    
    private func checkLocationAuthorizationStatus() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            // 位置情報の使用が許可されている場合
            locationPermissionGranted = true
        default:
            // その他の場合、許可されていない
            locationPermissionGranted = false
        }
    }
    
    private func showRuleDescriptionView() {
        // RuleDescriptionViewへの遷移処理をここに記述
        // 例: NavigationLinkのisActiveをtrueにする、画面遷移のためのカスタムメソッド呼び出し等
    }
}

// Preview
struct PermissionLocationView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionLocationView()
    }
}


