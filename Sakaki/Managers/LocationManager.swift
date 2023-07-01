import CoreLocation
import MapKit

enum MapDetails {
    static let startingLocation = CLLocationCoordinate2D(latitude: 32.113235, longitude: 34.818031)
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    static let zooming = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager?
    
    @Published var location: CLLocation?
    @Published var region = MKCoordinateRegion(center: MapDetails.startingLocation, span: MapDetails.defaultSpan)
    
    var userLocation: CLLocation?
    
    func checkIfLocationServicesIsEnable() {
        DispatchQueue.global(qos: .background).async {
            if CLLocationManager.locationServicesEnabled() {
                DispatchQueue.main.async {
                    self.locationManager = CLLocationManager()
                    self.locationManager?.delegate = self
                }
            } else {
                DispatchQueue.main.async {
                    Helper.showAlert(title: "Error", message: "Your location services are off. Please turn them on to use the application correctly.")
                }
            }
        }
    }

    
    func requestAllowOnceLocationPermission() {
        locationManager?.requestLocation()
    }
    
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else { return }
        
        switch locationManager.authorizationStatus {
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .restricted:
            Helper.showAlert(title: "Error ", message: "Your location is restricted likely due to parental controls.")
            
        case .denied:
            Helper.showAlert(title: "Error ", message: "You have denied this app location permission. Go into settings to change it.")
            
        case .authorizedAlways, .authorizedWhenInUse:
            region = MKCoordinateRegion(center: locationManager.location!.coordinate, span: MapDetails.defaultSpan)
            // Save the user's current location
            self.userLocation = locationManager.location
            
        @unknown default:
            Helper.showAlert(title: "Error ", message: "Error.. something went wrong.")
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else {
            Helper.showAlert(title: "Error ", message: "Error.. something went wrong.")
            return
        }
        
        DispatchQueue.main.async {
            let updatedRegion = MKCoordinateRegion(center: latestLocation.coordinate, span: MapDetails.zooming)
            self.location = latestLocation
            self.region = updatedRegion
            
            // Save the user's current location
            self.userLocation = latestLocation
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Helper.showAlert(title: "Error ", message: "Can't get current location")
        print("Location manager error: \(error.localizedDescription)")
    }
}
