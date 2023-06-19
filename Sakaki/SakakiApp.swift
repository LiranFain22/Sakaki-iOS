//
//  SakakiApp.swift
//  Sakaki
//
//  Created by Liran Fainshtein on 08/06/2023.
//

import SwiftUI
import Firebase

@main
struct SakakiApp: App {
    @StateObject var dataManager = DataManager()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(DataManager())
        }
    }
}
