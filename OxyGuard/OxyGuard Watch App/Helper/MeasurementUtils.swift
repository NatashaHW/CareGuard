import SwiftUI

struct MeasurementUtils {
    static func measurementValue(for type: String, from measureManager: MeasureManager) -> String {
        switch type {
        case "heartRate":
            return String(format: "%.0f", measureManager.latestHeartRate)
        case "oxygenLevel":
            return String(format: "%.0f", measureManager.latestOxygenLevel * 100)
        default:
            return "--"
        }
    }
    
    static func measurementDisplayView(measurementValue: String, unit: String, colorUnit: Color, spacing: CGFloat, valueFontSize: CGFloat, unitFontSize: CGFloat) -> some View {
        HStack(alignment: .bottom, spacing: spacing) {
            Text(measurementValue)
                .font(.system(size: valueFontSize, weight: .medium, design: .rounded)
                    .monospacedDigit()
                    .lowercaseSmallCaps()
                )
                .foregroundColor(.white)
                .alignmentGuide(.bottom) { d in d[.lastTextBaseline] }
            
            Text(" \(unit)")
                .font(.system(size: unitFontSize, weight: .medium, design: .rounded)
                    .monospacedDigit()
                )
                .foregroundColor(colorUnit)
                .alignmentGuide(.bottom) { d in d[.lastTextBaseline] }
        }
        .padding(0)
    }
}
