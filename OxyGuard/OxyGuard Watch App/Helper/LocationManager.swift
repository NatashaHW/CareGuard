import CoreLocation

class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    var userLocation: CLLocation?
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location
        manager.stopUpdatingLocation()
    }
}

class LocationManager: ObservableObject {
    @Published var locationManager = CLLocationManager()
    @Published var locationManagerDelegate = LocationManagerDelegate()
    
    init() {
        locationManager.delegate = locationManagerDelegate
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}
