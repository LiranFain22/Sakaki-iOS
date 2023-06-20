import SwiftUI
import UIKit
import Firebase

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var userIsLoggedIn = false
    @State private var isLoginForm = true
    
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        if userIsLoggedIn {
            ListView(userIsLoggedIn: $userIsLoggedIn)
        } else {
            ListView(userIsLoggedIn: $userIsLoggedIn)
                .onAppear {
                    locationManager.checkIfLocationServicesIsEnable()
                }
//            startScreen
        }
    }
    
    var startScreen: some View {
        ZStack {
            Color(0x7FB77E)
            
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .foregroundStyle(.linearGradient(colors: [Color(0xC58940)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 1000, height: 400)
                .rotationEffect(.degrees(135))
                .offset(y: -350)
            
            VStack {
                Image("pawLogo2")
                    .resizable()
                    .frame(width: 150, height: 150)
                
                Text("Sakaki")
                    .foregroundColor(.white)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
            }
            .offset(y: -200)
            
            VStack(spacing: 20) {
                if isLoginForm {
                    TextField("Email", text: $email)
                        .foregroundColor(.white)
                        .textFieldStyle(.plain)
                        .placeholder(when: email.isEmpty) {
                            Text("Email")
                                .foregroundColor(.white)
                                .bold()
                        }
                    
                    Rectangle()
                        .frame(width: 350, height: 1)
                        .foregroundColor(.white)
                    
                    SecureField("Password", text: $password)
                        .foregroundColor(.white)
                        .textFieldStyle(.plain)
                        .placeholder(when: password.isEmpty) {
                            Text("Password")
                                .foregroundColor(.white)
                                .bold()
                        }
                    
                    Rectangle()
                        .frame(width: 350, height: 1)
                        .foregroundColor(.white)
                    
                    renderLoginButton()
                } else {
                    TextField("Email", text: $email)
                        .foregroundColor(.white)
                        .textFieldStyle(.plain)
                        .placeholder(when: email.isEmpty) {
                            Text("Email")
                                .foregroundColor(.white)
                                .bold()
                        }
                    
                    Rectangle()
                        .frame(width: 350, height: 1)
                        .foregroundColor(.white)
                    
                    SecureField("Password", text: $password)
                        .foregroundColor(.white)
                        .textFieldStyle(.plain)
                        .placeholder(when: password.isEmpty) {
                            Text("Password")
                                .foregroundColor(.white)
                                .bold()
                        }
                    
                    Rectangle()
                        .frame(width: 350, height: 1)
                        .foregroundColor(.white)
                    
                    TextField("Username", text: $username)
                        .foregroundColor(.white)
                        .textFieldStyle(.plain)
                        .placeholder(when: username.isEmpty) {
                            Text("Username")
                                .foregroundColor(.white)
                                .bold()
                        }
                    
                    Rectangle()
                        .frame(width: 350, height: 1)
                        .foregroundColor(.white)
                    
                    renderSignUpButton()
                }
                
                Button {
                    isLoginForm.toggle()
                    resetTextFields()
                } label: {
                    Text(isLoginForm ? "Don't have an account? Sign up" : "Already have an account? Login")
                        .bold()
                        .foregroundColor(.white)
                }
                .padding(.top)
                .offset(y: 110)
                
            }
            .frame(width: 350)
            .offset(y: 100)
        }
        .ignoresSafeArea()
    }
    
    func renderLoginButton() -> some View {
        Button {
            login()
        } label: {
            Text("Login")
                .bold()
                .frame(width: 200, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.linearGradient(colors: [.white], startPoint: .top, endPoint: .bottomTrailing))
                )
                .foregroundColor(.blue)
        }
        .offset(y: 100)
    }
    
    func renderSignUpButton() -> some View {
        Button {
            register()
        } label: {
            Text("Sign up")
                .bold()
                .frame(width: 200, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.linearGradient(colors: [.white], startPoint: .top, endPoint: .bottomTrailing))
                )
                .foregroundColor(.blue)
        }
        .offset(y: 100)
    }
    
    func login() {
        guard isEmailValid(email) else {
            showAlert(title: "Error", message: "Please enter a valid email address")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                let errorMessage = error.localizedDescription
                showAlert(title: "Error", message: errorMessage)
            } else if let user = result?.user {
                // Login successful
                showAlert(title: "Login successful", message: "Welcom \(user.displayName ?? "Friend")!") {
                    resetTextFields()
                    
                    // Store authentication token or session object
                    UserDefaults.standard.set(true, forKey: "IsLoggedIn")
                    UserDefaults.standard.synchronize()
                    
                    userIsLoggedIn = true // trigger navigation
                }
                
            } else {
                // Unknown login error
                showAlert(title: "Error", message: "Unknown registration error")
            }
        }
    }
    
    func register() {
        guard isEmailValid(email) else {
            showAlert(title: "Error", message: "Please enter a valid email address")
            return
        }
        
        // Check if the username field is empty
        guard !username.isEmpty else {
            showAlert(title: "Error", message: "Please enter a username")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                let errorMessage = error.localizedDescription
                showAlert(title: "Error", message: errorMessage)
            } else if let user = result?.user {
                // Registration successful
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = username // Set the display name
                
                changeRequest.commitChanges { error in
                    if let error = error {
                        showAlert(title: "Error", message: error.localizedDescription)
                    } else {
                        showAlert(title: "Success", message: "Registration successful") {
                            isLoginForm = true // Switch back to login form
                            resetTextFields()
                        }
                    }
                }
            } else {
                // Unknown registration error
                showAlert(title: "Error", message: "Unknown registration error")
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
    
    func isEmailValid(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func resetTextFields() {
        email = ""
        password = ""
        username = ""
    }
    
    func checkAuthentication() {
        let isLoggedIn = UserDefaults.standard.bool(forKey: "IsLoggedIn")
        if isLoggedIn {
            // User is already logged in
            userIsLoggedIn = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
