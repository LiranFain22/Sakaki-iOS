import SwiftUI

class Helper {
    static func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
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
    
    static func greetingsBaseTimeOfDay() -> String {
        let currentTime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        let hour = Int(dateFormatter.string(from: currentTime)) ?? 0
        
        var greeting = ""
        
        switch hour {
        case 0..<12:
            greeting = "Good morning!"
        case 12..<17:
            greeting = "Good afternoon!"
        case 17..<24:
            greeting = "Good evening!"
        default:
            greeting = "Hello!"
        }
        
        return greeting
    }
    
    static func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
