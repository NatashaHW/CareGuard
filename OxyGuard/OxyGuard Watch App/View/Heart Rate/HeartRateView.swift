import SwiftUI

struct HeartRateView: View {
    var body: some View {
        NavigationView {
            MeasureView(
                icon: "HeartBeat",
                color: .red,
                colorUnit: .red,
                measurementType: "heartRate",
                unit: "BPM",
                measureManager: MeasureManager()
            )
        }
    }
}

struct HeartRateiew_Previews: PreviewProvider {
    static var previews: some View {
        HeartRateView()
    }
}
