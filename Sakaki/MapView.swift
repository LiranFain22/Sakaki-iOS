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
            uiView.addAnnotation(binAnnotation)
        }
        
        if isBinSelectedToRoute {
            setRoute(uiView)
        }
        
        if isCurrentLocationPressed {
            DispatchQueue.main.async {
                let userRegion = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(
                        latitude: locationManager.userLocation?.coordinate.latitude ?? MapDetails.startingLocation.latitude,
                        longitude: locationManager.userLocation?.coordinate.longitude ?? MapDetails.startingLocation.longitude),
                    span: MapDetails.zooming)
                uiView.setRegion(userRegion, animated: true)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func setRoute(_ mapView: MKMapView) {
        let currectLocationPlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(
            latitude: (locationManager.userLocation?.coordinate.latitude) ?? MapDetails.startingLocation.latitude,
            longitude: (locationManager.userLocation?.coordinate.longitude) ?? MapDetails.startingLocation.longitude))

        let targetPlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(
            latitude: (selectedBin?.latitude) ?? MapDetails.startingLocation.latitude,
            longitude: (selectedBin?.longitude) ?? MapDetails.startingLocation.longitude))

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: currectLocationPlaceMark)
        request.destination = MKMapItem(placemark: targetPlaceMark)
        request.transportType = .walking

        let directions = MKDirections(request: request)
        directions.calculate{ response, error in
            guard let route = response?.routes.first else { return }

            mapView.addAnnotations([currectLocationPlaceMark, targetPlaceMark])
            mapView.addOverlay(route.polyline)
            mapView.setVisibleMapRect(route.polyline.boundingMapRect,
                                      edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
                                      animated: true)
        }
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // Customize the appearance of map annotations if needed
            return nil
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 5
            return renderer
        }
    }
}
