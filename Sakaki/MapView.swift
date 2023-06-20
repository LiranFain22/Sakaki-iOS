import SwiftUI
import MapKit
import CoreLocationUI

struct MapView: View {
    @Binding var selectedBin: Bin?
    @EnvironmentObject var dataManager: DataManager
    @StateObject var locationManager: LocationManager

    var body: some View {
        ZStack {
            Map(coordinateRegion: $locationManager.region, showsUserLocation: true)
                .padding(10)

            VStack {
                Spacer()

                HStack {
                    Spacer()

                    LocationButton(.currentLocation) {
                        locationManager.checkIfLocationServicesIsEnable()
                    }
                    
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .labelStyle(.titleAndIcon)
                    .symbolVariant(.fill)
                    
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}
