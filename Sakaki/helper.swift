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
}
