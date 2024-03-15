//
//  Introduction.swift
//  Trip Collector
//
//  Created by 香川隼也 on 2024/03/06.
//

import SwiftUI
import AVKit

struct IntroductionView: View {
    var body: some View {
        ZStack {
            // 背景に動画を設定
            VideoBackgroundView()
            
            // テキストコンテンツ
            Text("Your adventure begins here.")
                .font(.system(size: 30, weight: .bold, design: .rounded)) // フォントのスタイルを調整
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .shadow(radius: 10) // テキストの影を追加
                .padding()
                .background(.blue)
                .cornerRadius(10)
                .padding()
        }
        .edgesIgnoringSafeArea(.all) // セーフエリアを無視して全画面表示
    }
}

struct VideoBackgroundView: View {
    private let player = AVPlayer(url: Bundle.main.url(forResource: "Sky", withExtension: "mp4")!)
    
    var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                player.play()
                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
                    player.seek(to: .zero)
                    player.play()
                }
            }
            .onDisappear {
                player.pause()
            }
            .scaledToFill()
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .clipped()
    }
}

// プレビュー用
struct IntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        IntroductionView()
    }
}

