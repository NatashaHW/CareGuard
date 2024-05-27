import SwiftUI

struct OxyMeterView: View {
    var body: some View {
        NavigationView {
            MeasureView(
                icon: "MeasuringOxy",
                color: .blue,
                colorUnit: .white,
                measurementType: "oxygenLevel",
                unit: "%",
                measureManager: MeasureManager()
            )
        }
    }
}

struct OxyMeterView_Previews: PreviewProvider {
    static var previews: some View {
        OxyMeterView()
    }
}
