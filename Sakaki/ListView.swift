import SwiftUI
import URLImage
import MapKit
import Firebase

struct ListView: View {
    @EnvironmentObject var dataManager: DataManager
    @StateObject private var locationManager = LocationManager()
    @Binding var userIsLoggedIn: Bool
    
    @State private var showBinDetails = false
    @State private var selectedBin: Bin?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var currentLocation: CLLocation?
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Stations")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                        .foregroundColor(.white)
                    
                    Spacer()

                    Button {
                        do {
                            try Auth.auth().signOut()
                            showAlert(title: "Bye 👋🏻", message: "Hope to see you again ☺️") {
                                // Return to LoginView
                                userIsLoggedIn = false
                            }
                        } catch let signOutError as NSError {
                            showAlert = true
                            alertMessage = "Error signing out: \(signOutError.localizedDescription)"
                        }
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Sign Out Error"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    
                }
                
                MapView(selectedBin: $selectedBin)
                
                List(dataManager.bins, id: \.id) { bin in
                    HStack {
                        Text(bin.binName)
                            .onTapGesture {
                                selectedBin = bin
                            }
                        
                        Spacer()
                        
                        Button(action: {
                            showBinDetails = true
                        }) {
                            Image(systemName: "info.circle")
                        }
                        .foregroundColor(.blue)
                        .padding(.all)
                    }
                }
//                .foregroundColor(.green)
            }
            .background(Color(0x7FB77E))
            .sheet(isPresented: $showBinDetails) {
                if let bin = selectedBin {
                    BinDetailsView(bin: bin)
                } else {
                    Text("No bin selected") // Show a default view or message
                }
            }
        }
    }
    
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let topWindow = windowScene.windows.first else {
            return
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?() // Execute the completion closure if provided
        })

        topWindow.rootViewController?.present(alert, animated: true, completion: nil)
    }
}

struct BinDetailsView: View {
    var bin: Bin
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            
            HStack {
                Text(bin.binName)
                    .font(.title)
                    .padding()
                
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.red)
                }
                .padding()
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Status: \(bin.status)")
                Text("Last Update: \(formattedDate(bin.lastUpdate))")
                URLImage(URL(string: bin.imageURL)!) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            .padding()
            
            Spacer()
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(userIsLoggedIn: .constant(true))
            .environmentObject(DataManager())
    }
}

