import SwiftUI

struct EmergencyOxyView: View {
    var body: some View {
        EmergencyView(measureManager: MeasureManager(), measurementTypes: "oxygenLevel")
    }
}

struct EmergencyOxyView_Previews: PreviewProvider {
    static var previews: some View {
        EmergencyOxyView()
    }
}
