import SwiftUI
import MapKit
import CoreLocationUI

struct MapView: View {
    @Binding var selectedBin: Bin?
    @EnvironmentObject var dataManager: DataManager
    @State private var userLocation: CLLocation?
    @State private var showUserLocation = false
    @State private var isRequestingLocationPermission = false

    @StateObject private var locationManager = LocationManager()

    var body: some View {
        ZStack {
            MapContainer(bins: dataManager.bins, selectedBin: $selectedBin, userLocation: userLocation, showUserLocation: $showUserLocation)
                .padding(10)

            VStack {
                Spacer()

                HStack {
                    Spacer()

                    LocationButton(.currentLocation) {
                        showUserLocation = true
                        locationManager.requestAllowOnceLocationPermission()
                    }
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .labelStyle(.titleAndIcon)
                    .symbolVariant(.fill)
                    .onChange(of: locationManager.location) { newLocation in
                        userLocation = newLocation
                        if showUserLocation {
                            let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
                            let region = MKCoordinateRegion(center: userLocation!.coordinate, span: span)
                            DispatchQueue.main.async {
                                MapContainer.sharedMapView?.setRegion(region, animated: true)
                            }
                        }
                    }
                    
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .onChange(of: userLocation) { _ in
            withAnimation(.easeInOut) {
                showUserLocation = false
            }
        }
        .onChange(of: selectedBin) { newSelectedBin in
            if newSelectedBin != nil {
                showUserLocation = false
            }
        }
    }
}



struct MapContainer: UIViewRepresentable {
    var bins: [Bin]
    @Binding var selectedBin: Bin?
    var userLocation: CLLocation?
    @Binding var showUserLocation: Bool
    
    static var sharedMapView: MKMapView?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.showsUserLocation = true
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        
        // Add bin annotations to the map
        for bin in bins {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: bin.latitude, longitude: bin.longitude)
            annotation.title = bin.binName
            uiView.addAnnotation(annotation)
        }
        
        if let bin = selectedBin {
            let location = CLLocationCoordinate2D(latitude: bin.latitude, longitude: bin.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
            let region = MKCoordinateRegion(center: location, span: span)
            uiView.setRegion(region, animated: true)
            
            // Select the corresponding annotation on the map
            if let annotation = uiView.annotations.first(where: { $0.coordinate.latitude == bin.latitude && $0.coordinate.longitude == bin.longitude }) {
                uiView.selectAnnotation(annotation, animated: true)
            }
        } else if let userLocation = userLocation, !showUserLocation {
            let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
            let region = MKCoordinateRegion(center: userLocation.coordinate, span: span)
            uiView.setRegion(region, animated: true)
        }
        
        
//        if let userLocation = userLocation {
//            print("showUserLocation = \(showUserLocation)")
//            if !showUserLocation {
//                let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
//                let region = MKCoordinateRegion(center: userLocation.coordinate, span: span)
//                uiView.setRegion(region, animated: true)
//            }
//        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapContainer
        
        init(_ parent: MapContainer) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "userLocation")
                annotationView.image = UIImage(systemName: "location.circle.fill")
                return annotationView
            }
            
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "binAnnotation")
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return annotationView
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            if let annotation = view.annotation as? MKPointAnnotation {
                if let bin = parent.bins.first(where: { $0.binName == annotation.title }) {
                    parent.selectedBin = bin
                }
            }
        }
    }
}
