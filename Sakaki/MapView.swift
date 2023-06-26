import SwiftUI
import MapKit
import CoreLocationUI

struct MapView: UIViewRepresentable {
    @EnvironmentObject var dataManager: DataManager
    @StateObject var locationManager: LocationManager
    
    @Binding var selectedBin: Bin?
    @Binding var isBinSelectedToRoute: Bool
    @Binding var isCurrentLocationPressed: Bool
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        
        mapView.showsUserLocation = true
        mapView.delegate = context.coordinator
        
        let region = MKCoordinateRegion(center: MapDetails.startingLocation, span: MapDetails.defaultSpan)
        
        mapView.setRegion(region, animated: true)
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        let region = MKCoordinateRegion(center: locationManager.region.center, span: MapDetails.zooming)
        uiView.setRegion(region, animated: true)
        
        if let selectedBin = selectedBin {
            let binRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: selectedBin.latitude, longitude: selectedBin.longitude), span: MapDetails.zooming)
            uiView.setRegion(binRegion, animated: true)
            
            // Remove previous annotations before adding a new one
            uiView.removeAnnotations(uiView.annotations)
            
            // Add a marker for the selected bin
            let binAnnotation = MKPointAnnotation()
            binAnnotation.coordinate = CLLocationCoordinate2D(latitude: selectedBin.latitude, longitude: selectedBin.longitude)
            binAnnotation.title = selectedBin.binName
            uiView.addAnnotation(binAnnotation)
        }
        
        if isCurrentLocationPressed {
            DispatchQueue.main.async {
                let userRegion = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(
                        latitude: locationManager.userLocation?.coordinate.latitude ?? MapDetails.startingLocation.latitude,
                        longitude: locationManager.userLocation?.coordinate.longitude ?? MapDetails.startingLocation.longitude),
                    span: MapDetails.zooming)
                uiView.setRegion(userRegion, animated: true)
                
                // Fetch nearby bins based on user's location
                if let userLocation = locationManager.userLocation {
                    // Specify the desired radius in meters
                    let nearbyBins = dataManager.fetchNearbyBins(userLocation: userLocation, radius: 500)
                    
                    // Remove previous annotations before adding new ones
                    uiView.removeAnnotations(uiView.annotations)
                    
                    // Add markers for nearby bins
                    for bin in nearbyBins {
                        let binAnnotation = MKPointAnnotation()
                        binAnnotation.coordinate = CLLocationCoordinate2D(latitude: bin.latitude, longitude: bin.longitude)
                        binAnnotation.title = bin.binName
                        uiView.addAnnotation(binAnnotation)
                    }
                }
            }
        }
        
        if isBinSelectedToRoute {
            setRoute(uiView)
        }
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func setRoute(_ mapView: MKMapView) {
        // Remove previous annotations and overlays
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        let currentLocationPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(
            latitude: (locationManager.userLocation?.coordinate.latitude) ?? MapDetails.startingLocation.latitude,
            longitude: (locationManager.userLocation?.coordinate.longitude) ?? MapDetails.startingLocation.longitude))
        
        let targetPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(
            latitude: (selectedBin?.latitude) ?? MapDetails.startingLocation.latitude,
            longitude: (selectedBin?.longitude) ?? MapDetails.startingLocation.longitude))
        
        let currentLocationAnnotation = MKPointAnnotation()
        currentLocationAnnotation.coordinate = currentLocationPlacemark.coordinate
        currentLocationAnnotation.title = dataManager.userData?.username
        
        let targetAnnotation = MKPointAnnotation()
        targetAnnotation.coordinate = targetPlacemark.coordinate
        targetAnnotation.title = selectedBin?.binName
        
        let currentLocationMapItem = MKMapItem(placemark: currentLocationPlacemark)
        let targetMapItem = MKMapItem(placemark: targetPlacemark)
        
        let request = MKDirections.Request()
        request.source = currentLocationMapItem
        request.destination = targetMapItem
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else { return }
            
            mapView.addAnnotations([currentLocationAnnotation, targetAnnotation])
            mapView.addOverlay(route.polyline)
            mapView.setVisibleMapRect(route.polyline.boundingMapRect,
                                      edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
                                      animated: true)
        }
        
        isBinSelectedToRoute = false
    }

    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // Customize the appearance of map annotations if needed
            
            // User annotation
            if annotation.title == parent.dataManager.userData?.username {
                let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "CurrentLocationAnnotationView") as? MKMarkerAnnotationView
                if let annotationView = annotationView {
                    annotationView.annotation = annotation
                } else {
                    let newAnnotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "CurrentLocationAnnotationView")
                    newAnnotationView.glyphImage = UIImage(systemName: "person.fill")
                    newAnnotationView.canShowCallout = true
                    return newAnnotationView
                }
            }
            
            return nil
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 5
            return renderer
        }
        
        func findBin(forBin: MKPointAnnotation) -> Bin {
            let binn: Bin = Bin(id: "", binName: "", imageURL: "", lastUpdate: Date.now, latitude: 0.0, longitude: 0.0, status: "")
            for bin in parent.dataManager.bins {
                if bin.latitude == forBin.coordinate.latitude &&
                    bin.longitude == forBin.coordinate.longitude {
                    return bin
                }
            }
            
            // Should not get here
            return binn
        }
    }
}
