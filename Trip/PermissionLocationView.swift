//
//  Register Membership.swift
//  Trip Collector
//
//  Created by 香川隼也 on 2024/03/05.
//

import SwiftUI
import CoreLocation // 位置情報サービスを使用するために必要

struct PermissionLocationView: View {
    // 位置情報サービスの状態を管理するための変数
    @State private var locationPermissionGranted = false
    
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "location.circle.fill") // システム提供の位置情報アイコン
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
                // ここに位置情報の許可を求める処理を挿入
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
    }
    
    private func requestLocationPermission() {
        // CLLocationManagerのインスタンスを作成
        let locationManager = CLLocationManager()
        // 位置情報サービスの使用許可をリクエスト
        locationManager.requestWhenInUseAuthorization()
        
        // ここで、位置情報の許可状態に基づいて、必要な処理を行う
        // 例: ユーザーの現在地を取得する、位置情報許可の状態を確認する、など
    }
}

// Preview
struct PermissionLocationView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionLocationView()
    }
}


