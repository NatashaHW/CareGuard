import SwiftUI

struct EmergencyHeartView: View {
    var body: some View {
        EmergencyView(measureManager: MeasureManager(), measurementTypes: "heartRate")
    }
}

struct EmergencyHeartView_Previews: PreviewProvider {
    static var previews: some View {
        EmergencyHeartView()
    }
}
