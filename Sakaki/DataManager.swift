import SwiftUI
import Firebase

class DataManager: ObservableObject {
    @Published var bins: [Bin] = []
    
    init() {
        fetchBins()
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
            "status": status
        ]) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}
