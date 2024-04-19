//
//  TabView.swift
//  Trip Collector
//
//  Created by 香川隼也 on 2024/03/12.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            DestinationMapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            MomentView()
                .tabItem {
                    Label("Moments", systemImage: "clock")
                }
            RuleDescriptionView()
                .tabItem {
                    Label("Rules", systemImage: "text.book.closed")
                }
        }
        // TabViewに`.frame`や`.background`を設定する必要は通常ありません。
        .edgesIgnoringSafeArea(.bottom) // タブビューが画面の最下部に表示されるようにします。
    }
}


struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView().environmentObject(CheckpointManager.shared)
    }
}

