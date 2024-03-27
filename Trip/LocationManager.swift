//
//  LocationManager.swift
//  Trip
//
//  Created by 香川隼也 on 2024/03/15.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGeofencingForTokyoSkytree()
    }
    
    func setupGeofencingForTokyoSkytree() {
        locationManager.delegate = self
        // 東京スカイツリーの緯度経度
        let geofenceRegionCenter = CLLocationCoordinate2D(latitude: 35.710063, longitude: 139.8107)
        let geofenceRegion = CLCircularRegion(center: geofenceRegionCenter,
                                              radius: 100, // 例として100メートルの半径
                                              identifier: "TokyoSkytreeGeofence")
        geofenceRegion.notifyOnEntry = true
        geofenceRegion.notifyOnExit = true
        locationManager.startMonitoring(for: geofenceRegion)
    }
    
    // CLLocationManagerDelegateメソッド
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("東京スカイツリーのジオフェンス領域に入りました")
        // ここに入域時の処理を記述
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("東京スカイツリーのジオフェンス領域から出ました")
        // ここに退域時の処理を記述
    }
}

