import SwiftUI
import AVFoundation

struct EmergencyView: View {
    @ObservedObject var measureManager: MeasureManager
    @State private var countdown = 30
    @State private var isTimerRunning = false
    @State private var isOn = false
    @State private var countdownOpacity = 1.0
    
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var locationManager = LocationManager()
    
    @State private var alertTimer: DispatchSourceTimer?
    @State private var player: AVAudioPlayer?
    
    @State private var isShowingMedicalInfoView = false
    
    private let measurementName: String
    private let measurementTypes: String
    
    init(measureManager: MeasureManager, measurementTypes: String) {
        self.measureManager = measureManager
        self.measurementTypes = measurementTypes
        self.measurementName = measurementTypes == "heartRate" ? "heart rate" : "oxygen level"
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Your \(measurementName) is \ncritically low (\(measurementValues()) \(measurementTypes == "heartRate" ? "BPM" : "%"))")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white)
                .padding(.top, 20)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .onAppear {
                    startCountdownAndAlertTimer()
                }
            
            VStack(spacing: 13) {
                SliderButton(isOn: $isOn)
                    .frame(width: 180, height: 60)
                
                Text("Calling emergency in \n\(countdown) secs")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Stop", systemImage: "multiply", action: {
                    stopCountdownAndAlertTimer()
                    measureManager.showEmergencyHeart = false
                    measureManager.showEmergencyOxygen = false
                    presentationMode.wrappedValue.dismiss()
                })
                .tint(.gray.opacity(0.24))
                .labelStyle(.iconOnly)
            }
        }
        .navigationBarBackButtonHidden(true)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            if isTimerRunning {
                stopCountdownAndAlertTimer()
                countdown = 30
            }
            locationManager.startUpdatingLocation()
        }
        .navigationTitle("SOS")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func startCountdownAndAlertTimer() {
        alertTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        alertTimer?.schedule(deadline: .now(), repeating: 1.0)
        alertTimer?.setEventHandler {
            WKInterfaceDevice.current().play(.failure)
            self.playAlertSound()
            
            if self.countdown > 0 && !self.isOn {
                self.countdown -= 1
            } else {
                self.alertTimer?.cancel()
                self.isTimerRunning = false
                self.isOn = true
                self.countdownOpacity = 0
                self.stopAlertSound()
                self.emergencyHandler.sendEmergencyMessageAndCall()
            }
        }
        alertTimer?.resume()
    }
    
    func stopCountdownAndAlertTimer() {
        alertTimer?.cancel()
        alertTimer = nil
        stopAlertSound()
    }
    
    private var emergencyHandler: EmergencyHandler {
        EmergencyHandler(measureManager: measureManager, locationManagerDelegate: locationManager.locationManagerDelegate)
    }
    
    func playAlertSound() {
        guard let url = Bundle.main.url(forResource: "EmergencyAlert", withExtension: "mp3") else { return }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
    
    func stopAlertSound() {
        player?.stop()
    }
    
    private func measurementValues() -> String {
        switch measurementTypes {
        case "heartRate":
            return String(format: "%.0f", measureManager.latestHeartRate)
        case "oxygenLevel":
            return String(format: "%.0f", measureManager.latestOxygenLevel * 100)
        default:
            return "--"
        }
    }
}
