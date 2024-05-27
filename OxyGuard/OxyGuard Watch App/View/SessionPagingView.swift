import SwiftUI

struct SessionPagingView: View {
    @EnvironmentObject var measureManager: MeasureManager
    @State private var selection: Tab = .oxyMeter
    
    enum Tab {
        case end, oxyMeter, heartRate
    }
    
    var body: some View {
        TabView(selection: $selection) {
            EndView().tag(Tab.end)
            OxyMeterView().tag(Tab.oxyMeter)
            HeartRateView().tag(Tab.heartRate)
        }
        .navigationBarBackButtonHidden(true)
        .tabViewStyle(PageTabViewStyle())
    }
}

struct SessionPagingView_Previews: PreviewProvider {
    static var previews: some View {
        SessionPagingView()
            .environmentObject(MeasureManager())
    }
}
