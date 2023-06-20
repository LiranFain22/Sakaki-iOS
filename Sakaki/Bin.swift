import SwiftUI

struct Bin: Identifiable {
    var id: String
    var binName: String
    var imageURL: String
    var lastUpdate: Date
    var latitude: Double
    var longitude: Double
    var status: String
}
