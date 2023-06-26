import SwiftUI
import URLImage
import MapKit
import Firebase
import CoreLocationUI

struct ListView: View {
    @StateObject private var locationManager = LocationManager()
    @EnvironmentObject var dataManager: DataManager
    
    @Binding var userIsLoggedIn: Bool
    
    @State private var showBinDetails = false
    @State private var showUserDetails = false
    @State private var currentLocation: CLLocation?
    @State private var selectedBin: Bin?
    @State private var isBinSelectedToRoute = false
    @State private var isCurrentLocationPressed = false
    @State private var userName = Firebase.Auth.auth().currentUser?.displayName
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    
                    VStack(alignment: .leading) {
                        Text("Stations")
                            .font(.largeTitle)
                            .bold()
                            .padding()
                            .foregroundColor(.white)
                        
                        Text("\(Helper.greetingsBaseTimeOfDay()) \(userName ?? "Friend")")
                            .font(.title3)
                            .bold()
                            .padding()
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button {
                        showUserDetails.toggle()
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.white)
                    }
                    .offset(y: -30)
                    
                    Button {
                        showAlertBeforeSignOut()
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .offset(y: -30)
                }
                
                ZStack {
                    MapView(locationManager: locationManager,
                            selectedBin: $selectedBin,
                            isBinSelectedToRoute: $isBinSelectedToRoute,
                            isCurrentLocationPressed:$isCurrentLocationPressed)
                        .environmentObject(dataManager)
                        .padding(10)

                    
                    VStack {
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            LocationButton(.currentLocation) {
                                locationManager.checkIfLocationServicesIsEnable()
                                isCurrentLocationPressed = true
                            }
                            
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .labelStyle(.iconOnly)
                            .symbolVariant(.fill)
                            
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                        }
                    }
                }
                
                if let userLocation = locationManager.userLocation {
                    List(dataManager.fetchNearbyBins(userLocation: userLocation , radius: 500), id: \.id) { bin in
                        HStack {
                            Text(bin.binName)
                                .onTapGesture {
                                    selectedBin = bin
                                    isCurrentLocationPressed = false
                                }
                            
                            Spacer()
                            
                            Button(action: {
                                selectedBin = bin
                                showBinDetails = true
                                isCurrentLocationPressed = false
                            }) {
                                Image(systemName: "info.circle")
                            }
                            .foregroundColor(.blue)
                            .padding(.all)
                        }
                    }
                } else {
                    List(dataManager.bins, id: \.id) { bin in
                        HStack {
                            Text(bin.binName)
                                .onTapGesture {
                                    selectedBin = bin
                                    isCurrentLocationPressed = false
                                }
                            
                            Spacer()
                            
                            Button(action: {
                                selectedBin = bin
                                showBinDetails = true
                                isCurrentLocationPressed = false
                            }) {
                                Image(systemName: "info.circle")
                            }
                            .foregroundColor(.blue)
                            .padding(.all)
                        }
                    }
                }
            }
            .background(Color(0x7FB77E))
            .sheet(isPresented: $showBinDetails) {
                if let bin = selectedBin {
                    BinDetailsView(bin: bin, isBinSelected: $isBinSelectedToRoute)
                } else {
                    BinDetailsView(bin: dataManager.bins.first!, isBinSelected: $isBinSelectedToRoute)
                }
            }
        }
        .sheet(isPresented: $showUserDetails) {
            UserDetailsView()
        }
    }
    
    private func showAlertBeforeSignOut() {
        let alert = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            performSignOut()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let viewController = windowScene.windows.first?.rootViewController {
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    private func performSignOut() {
        do {
            try Auth.auth().signOut()
            Helper.showAlert(title: "Bye 👋🏻", message: "Hope to see you again ☺️") {
                // Return to LoginView
                userIsLoggedIn = false
            }
        } catch let signOutError as NSError {
            Helper.showAlert(title: "Error", message: signOutError.localizedDescription)
        }
    }
}
