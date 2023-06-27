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
    @State private var showStopButton = false
    @State private var removeRoute = false
    @State private var selectedBin: Bin?
    @State private var selectedBinBTN: Bin?
    @State private var selectedBinAnnotation: Bin?
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
                    .sheet(isPresented: $showUserDetails) {
                        UserDetailsView()
                    }
                    
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
                            selectedBinAnnotation: $selectedBinAnnotation,
                            isBinSelectedToRoute: $isBinSelectedToRoute,
                            isCurrentLocationPressed:$isCurrentLocationPressed,
                            showBinDetails: $showBinDetails,
                            showStopButton: $showStopButton,
                            removeRoute: $removeRoute)
                        .environmentObject(dataManager)
                        .padding(10)
                        .sheet(item: $selectedBinAnnotation) { bin in
                            BinDetailsView(bin: bin, isBinSelectedToRoute: $isBinSelectedToRoute)
                        }

                    
                    VStack {
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            Button {
                                removeRoute = true
                                showStopButton = false
                            } label: {
                                Image(systemName: "stop.fill")
                                    .foregroundColor(.red)
                                    .font(.largeTitle)
                            }
                            .cornerRadius(8)
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                            .opacity(showStopButton ? 1.0 : 0.0) // Hide the button if not shown
                            
                            LocationButton(.currentLocation) {
                                locationManager.checkIfLocationServicesIsEnable()
                                isCurrentLocationPressed = true
                                isBinSelectedToRoute = false
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
                                selectedBinBTN = bin
                                isCurrentLocationPressed = false
                                showBinDetails = true
                            }) {
                                Image(systemName: "info.circle")
                            }
                            .foregroundColor(.blue)
                            .padding(.all)
                            .sheet(item: $selectedBinBTN) { bin in
                                BinDetailsView(bin: bin, isBinSelectedToRoute: $isBinSelectedToRoute)
                            }
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
                                selectedBinBTN = bin
                                isCurrentLocationPressed = false
                                showBinDetails = true
                            }) {
                                Image(systemName: "info.circle")
                            }
                            .foregroundColor(.blue)
                            .padding(.all)
                            .sheet(item: $selectedBinBTN) { bin in
                                BinDetailsView(bin: bin, isBinSelectedToRoute: $isBinSelectedToRoute)
                            }
                        }
                    }
                }
            }
            .background(Color(0x7FB77E))
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
