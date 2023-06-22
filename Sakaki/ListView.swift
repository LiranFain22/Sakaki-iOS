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
                        do {
                            try Auth.auth().signOut()
                            Helper.showAlert(title: "Bye 👋🏻", message: "Hope to see you again ☺️") {
                                // Return to LoginView
                                userIsLoggedIn = false
                            }
                        } catch let signOutError as NSError {
                            Helper.showAlert(title: "Error", message: signOutError.localizedDescription)
                        }
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
                
                List(dataManager.bins, id: \.id) { bin in
                    HStack {
                        Text(bin.binName)
                            .onTapGesture {
                                selectedBin = bin
                                isCurrentLocationPressed = false
                            }
                        
                        Spacer()
                        
                        Button(action: {
                            showBinDetails = true
                            selectedBin = bin
                            isCurrentLocationPressed = false
                        }) {
                            Image(systemName: "info.circle")
                        }
                        .foregroundColor(.blue)
                        .padding(.all)
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
    }
}

struct BinDetailsView: View {
    @State var bin: Bin
    
    @Binding var isBinSelected: Bool
    
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isActionSheetPresented = false
    
    var body: some View {
        VStack {
            
            Text(bin.binName)
                .font(.largeTitle)
                .padding()
            
            VStack(spacing: 10) {
                URLImage(URL(string: bin.imageURL)!) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                Divider()
                HStack {
                    Text("Status: ")
                        .bold()
                    Spacer()
                    Text(bin.status)
                }
                Divider()
                HStack {
                    Text("Last Update: ")
                        .bold()
                    Spacer()
                    Text(Helper.formattedDate(bin.lastUpdate))
                }
                Divider()
                VStack {
                    Button {
                        isActionSheetPresented = true
                    } label: {
                        Text("Update Station")
                            .font(.title2)
                            .padding()
                        Image(systemName: "newspaper")
                            .font(.title2)
                            .padding()
                    }
                    .foregroundColor(.white)
                    .background(.green)
                    .cornerRadius(20)
                    
                    
                    Divider()
                    
                    HStack {
                        Button {
                            isBinSelected.toggle()
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Route")
                                .font(.title2)
                                .padding()
                            Image(systemName: "arrow.triangle.turn.up.right.diamond")
                                .font(.title2)
                                .padding()
                        }
                        .foregroundColor(.white)
                        .background(.blue)
                        .cornerRadius(20)
                        
                        Spacer()
                        
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Return")
                                .font(.title2)
                                .padding()
                            Image(systemName: "return")
                                .font(.title2)
                                .padding()
                        }
                        .foregroundColor(.white)
                        .background(.red)
                        .cornerRadius(20)
                    }
                }
            }
            .padding()
            
            Spacer()
        }
        .actionSheet(isPresented: $isActionSheetPresented) {
            ActionSheet(title: Text("Select Status"), buttons: [
                .default(Text("Full")) {
                    updateBinStatus(status: "Full")
                    
                },
                .default(Text("Half Full")) {
                    updateBinStatus(status: "Half Full")
                },
                .default(Text("Empty")) {
                    updateBinStatus(status: "Empty")
                },
                .cancel()
            ])
        }
    }
    
    private func updateBinStatus(status: String) {
        dataManager.updateBin(bin: bin, status: status)
        
        // Update the local bin object with the new status and last update
        bin.status = status
        bin.lastUpdate = Date.now
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(userIsLoggedIn: .constant(true))
            .environmentObject(DataManager())
    }
}
