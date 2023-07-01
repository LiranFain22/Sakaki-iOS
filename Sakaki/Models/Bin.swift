import SwiftUI

class Bin: Identifiable, Hashable {
    
    var id: String
    var binName: String
    var imageURL: String
    var lastUpdate: Date
    var latitude: Double
    var longitude: Double
    var status: String

    init(id: String, binName: String, imageURL: String, lastUpdate: Date, latitude: Double, longitude: Double, status: String) {
        self.id = id
        self.binName = binName
        self.imageURL = imageURL
        self.lastUpdate = lastUpdate
        self.latitude = latitude
        self.longitude = longitude
        self.status = status
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Bin, rhs: Bin) -> Bool {
        return lhs.id == rhs.id
    }
}
