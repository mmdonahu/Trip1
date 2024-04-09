import SwiftUI
import AVKit

struct ContentView: View {
    var body: some View {
        NavigationView {
            ZStack {
                // 背景に動画を設定
                VideoBackgroundView()
                
                // NavigationLinkを使ってSignupViewへの遷移をトリガー
                NavigationLink(destination: SignupView()) {
                    Text("Your adventure begins here.")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .shadow(radius: 10)
                        .padding()
                        .background(.blue)
                        .cornerRadius(10)
                }
            }
            .edgesIgnoringSafeArea(.all) // セーフエリアを無視して全画面表示
        }
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

