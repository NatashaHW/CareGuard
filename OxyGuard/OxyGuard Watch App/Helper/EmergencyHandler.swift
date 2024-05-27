import WatchKit
import CoreLocation

class EmergencyHandler {
    let measureManager: MeasureManager
    let locationManagerDelegate: LocationManagerDelegate
    
    init(measureManager: MeasureManager, locationManagerDelegate: LocationManagerDelegate) {
        self.measureManager = measureManager
        self.locationManagerDelegate = locationManagerDelegate
    }
    
    func sendEmergencyMessageAndCall() {
        sendEmergencyMessage {
            self.callEmergency()
        }
    }
    
    func sendEmergencyMessage(completion: @escaping () -> Void) {
        guard let location = locationManagerDelegate.userLocation else {
            print("Location not available")
            return
        }
        
        let phoneNumber = "123"
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        let url = "http://maps.apple.com/%3Fll=\(latitude),\(longitude)"
        
        let message = "Jane Doe's heart rate is critically low (\(measureManager.latestHeartRate) BPM). Jane Doe needs emergency assistance immediately. Location: \(url)"
        
        if let messageURL = URL(string: "sms:imessage:\(phoneNumber)&body=\(message)") {
            print("message sent")
            let wkExtension = WKExtension.shared()
            wkExtension.openSystemURL(messageURL)
            
            // Simulate delay for sending the message before making the call
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                completion()
            }
        }
    }
    
    func callEmergency() {
        let phoneNumber = "123"
        if let telURL = URL(string: "tel:\(phoneNumber)") {
            print("calling emergency")
            let wkExtension = WKExtension.shared()
            wkExtension.openSystemURL(telURL)
        }
    }
}
