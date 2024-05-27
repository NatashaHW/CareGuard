import SwiftUI

@main
struct OxyGuard_Watch_AppApp: App {
    @StateObject var measureManager = MeasureManager()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                StartView()
            }
                .environmentObject(measureManager)
        }
    }
}
