//
//  Destination map.swift
//  Trip Collector
//
//  Created by 香川隼也 on 2024/03/08.
//

import SwiftUI
import MapKit

struct DestinationMapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.7100, longitude: 139.8107), // 東京スカイツリーの位置
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01) // 地図のズームレベルを細かくしてスカイツリーの周辺がよく見えるように設定
    )
    
    var body: some View {
        Map(coordinateRegion: $region)
            .edgesIgnoringSafeArea(.all) // 必要に応じて、セーフエリアを無視して全画面で表示
    }
}

// Preview
struct DestinationMapView_Previews: PreviewProvider {
    static var previews: some View {
        DestinationMapView()
    }
}

