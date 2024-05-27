import SwiftUI
import HealthKit

struct MeasureView: View {
    @StateObject private var measureManager: MeasureManager
    @State private var countdown = 15
    @ObservedObject var viewModel: LottieViewModel = .init()
    
    let icon: String
    let color: Color
    let colorUnit: Color
    let measurementType: String
    let unit: String
    
    init(icon: String, color: Color, colorUnit: Color, measurementType: String, unit: String, measureManager: MeasureManager) {
        self.icon = icon
        self.color = color
        self.colorUnit = colorUnit
        self.measurementType = measurementType
        self.unit = unit
        _measureManager = StateObject(wrappedValue: measureManager)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                Image(uiImage: viewModel.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .onAppear {
                        self.viewModel.loadAnimationFromFile(filename: icon)
                    }
                
                VStack(alignment: .leading, spacing: -4) {
                    if measureManager.isMeasuring {
                        Text("Measuring...")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                        
                        MeasurementUtils.measurementDisplayView(
                            measurementValue: "--",
                            unit: unit,
                            colorUnit: colorUnit,
                            spacing: 6,
                            valueFontSize: 45,
                            unitFontSize: 25
                        ).onAppear {
                            startCountdown()
                        }
                        
                    } else {
                        Text("Current")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                        
                        MeasurementUtils.measurementDisplayView(
                            measurementValue: MeasurementUtils.measurementValue(for: measurementType, from: measureManager),
                            unit: unit,
                            colorUnit: colorUnit,
                            spacing: 6,
                            valueFontSize: 45,
                            unitFontSize: 25
                        )
                    }
                    
                    Text("\(previousMeasurementValue()), \(measureManager.timeAgo)")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color.gray)
                }
                .padding(.horizontal, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                NavigationLink(destination: EmergencyHeartView(), isActive: $measureManager.showEmergencyHeart) {
                    EmptyView()
                }
                .frame(width: 0, height: 0)
                
                NavigationLink(destination: EmergencyOxyView(), isActive: $measureManager.showEmergencyOxygen) {
                    EmptyView()
                }
                .frame(width: 0, height: 0)
                
            }
            .padding(.top, 20)
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .onAppear {
                measureManager.requestAuthorization()
            }
        }
    }
    
    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            countdown -= 1
            if countdown == 0 {
                timer.invalidate()
            }
        }
    }
    
    private func previousMeasurementValue() -> String {
        switch measurementType {
        case "heartRate":
            return String(format: "%.0f BPM", measureManager.previousHeartRate)
        case "oxygenLevel":
            return String(format: "%.0f%%", measureManager.previousOxygenLevel * 100)
        default:
            return "--"
        }
    }
}
