import MapKit

class BinAnnotation: NSObject, MKAnnotation {
    let bin: Bin
    
    var title: String? {
        return bin.binName
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: bin.latitude, longitude: bin.longitude)
    }
    
    init(bin: Bin) {
        self.bin = bin
    }
}
