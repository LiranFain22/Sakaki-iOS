import SwiftUI
import Firebase

class DataManager: ObservableObject {
    @Published var bins: [Bin] = []
    
    @Published var userData: UserData?
    
    init() {
        fetchBins()
        fetchUserData()
    }
    
    func fetchBins() {
        bins.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("Bins")
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    
                    let id = data["id"] as? String ?? ""
                    let binName = data["binName"] as? String ?? ""
                    let imageURL = data["imageURL"] as? String ?? ""
                    let lastUpdate = data["lastUpdate"] as? Date ?? Date.now
                    var latitude : Double = 0.0
                    var longitude : Double = 0.0
                    if let geopoint = data["location"] as? GeoPoint {
                        latitude = geopoint.latitude
                        longitude = geopoint.longitude
                    }
                    let status = data["status"] as? String ?? ""
                    
                    let bin = Bin(id: id, binName: binName, imageURL: imageURL, lastUpdate: lastUpdate, latitude: latitude, longitude: longitude, status: status)
                    self.bins.append(bin)
                }
            }
        }
    }
    
    func addBin(binName: String, imageURL: String, latitude: Double, longitude: Double, status: String) {
        let db = Firestore.firestore()
        let ref = db.collection("Bins").document()
        ref.setData([
            "id": ref.documentID,
            "binName": binName,
            "imageURL": imageURL,
            "latitude": latitude,
            "longitude": longitude,
            "status": status,
            "lastUpdate": Timestamp(date: Date.now)
        ]) { error in
            if let error = error {
                Helper.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    func updateBin(bin: Bin, status: String) {
        let db = Firestore.firestore()
        let ref = db.collection("Bins").document(bin.id)
        ref.updateData([
            "status": status,
            "lastUpdate": Timestamp(date: Date.now)
        ]) { error in
            if let error = error {
                Helper.showAlert(title: "Error", message: error.localizedDescription)
            } else {
                // Update the bin's status in the local array
                if let index = self.bins.firstIndex(where: { $0.id == bin.id }) {
                    self.bins[index].status = status
                    self.bins[index].lastUpdate = Date.now
                }
                
                // Publish the changes to trigger view update
                self.objectWillChange.send()
            }
        }
    }
    
    //MARK: - User Requests Functions
    
    
    func createUserDocument(user: User) {
        let db = Firestore.firestore()
        let userDocument = db.collection("Users").document(user.uid)
        userDocument.setData([
            "email": user.email!,
            "level": "Beginner",
            "reportCount": 0,
            "username": user.displayName!
        ])
    }
    
    func fetchUserData() {
        let db = Firestore.firestore()
        let userDocument = db.collection("Users").document(Auth.auth().currentUser!.uid)

        userDocument.getDocument { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }

            if let snapshot = snapshot, snapshot.exists {
                let data = snapshot.data()

                let email = data!["email"] as? String ?? ""
                let username = data!["username"] as? String ?? ""
                let level = data!["level"] as? String ?? ""
                let reportCount = data!["reportCount"] as? Int ?? 0

                let userData = UserData(email: email, username: username, level: level, reportCount: reportCount)

                DispatchQueue.main.async {
                    self.userData = userData
                }
            }
        }
    }
}
