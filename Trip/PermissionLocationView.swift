import SwiftUI
import CoreLocation

// ObservableObjectプロトコルに準拠したLocationManagerクラス
class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    @Published var locationPermissionGranted = false // 位置情報の許可状態
    private let manager: CLLocationManager
    
    override init() {
        manager = CLLocationManager()
        super.init()
        manager.delegate = self
    }
    
    func requestLocationPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // 位置情報の許可状態を更新する必要がある場合は、ここで処理しますが、
        // 次の画面に遷移する条件は変更しないため、このメソッドの中身は現時点では変更不要です。
    }
}

struct PermissionLocationView: View {
    @ObservedObject private var locationManager = LocationManager()
    @State private var showRuleDescriptionView = false // 遷移制御用の状態変数
    
    var body: some View {
        VStack {
            // UIコンポーネントの配置...
            Spacer()
            Image(systemName: "location.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            Text("Allow us to use your location")
                .font(.title)
                .padding()
            Text("Location services must be enabled. Without your location, our journey together cannot begin")
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: {
                self.locationManager.requestLocationPermission()
                self.showRuleDescriptionView = true // ここで直接次の画面に遷移するフラグをtrueにする
            }) {
                Text("Allow the use of location information")
                    .foregroundColor(.white)
                    .frame(width: 320, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            Spacer()
        }
        .fullScreenCover(isPresented: $showRuleDescriptionView) {
            RuleDescriptionView() // ここで既存のRuleDescriptionViewへ遷移
        }
    }
}

struct PermissionLocationView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionLocationView()
    }
}

