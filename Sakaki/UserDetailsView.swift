import SwiftUI

struct UserDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "arrowshape.left")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("Back")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                }
                .padding(20)
            }
            
            Text("User Profile")
                .foregroundColor(.white)
                .font(.largeTitle)
                .bold()
            
            
            if let userData = dataManager.userData {
                getRowData(title: "Email: ", data: userData.email)
                    .padding()
                
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(.white)
                
                getRowData(title: "Username: ", data: userData.username)
                    .padding()
                
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(.white)
                
                getRowData(title: "Level: ", data: userData.level)
                    .padding()
                
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(.white)
                
                if let beginnerDescription = UserLevelDescription[userData.level] {
                    Text(beginnerDescription)
                        .foregroundColor(.white)
                        .font(.callout)
                        .bold()
                        .italic()
                        .padding()
                    
                    
                    Text("Next Level: \(getUserNextLevel(currentUserLevel: userData.reportCount)), \(getUserLevelRemains(numberOfReports: userData.reportCount)) updates left to level up!")
                        .foregroundColor(.white)
                        .font(.title3)
                        .bold()
                        .padding()
                    
                }
                
                
            }
            
            Spacer()
        }
        .background(Color(0x7FB77E))
    }
    
    func getRowData(title: String, data: String) -> AnyView {
        return AnyView(HStack {
            Text(title)
                .foregroundColor(.white)
                .font(.title3)
                .bold()
            
            Spacer()
            
            Text(data)
                .foregroundColor(.white)
                .font(.title3)
                .bold()
        })
    }
    
    func getUserLevelRemains(numberOfReports: Int) -> Int {
        // Convert UserLevelMap to List
        let userLevelList = Array(UserLevelMap.keys)
        // Sort userLevelList in ascenging order
        let sortedUserLevelList = userLevelList.sorted()
        
        for level in sortedUserLevelList {
            if numberOfReports < level {
                return level - numberOfReports
            }
        }
        
        // Should not get here..
        return -1
    }
    
    func getUserNextLevel(currentUserLevel: Int) -> String {
        // Convert UserLevelMap to List
        let userLevelList = Array(UserLevelMap.keys)
        // Sort userLevelList in ascenging order
        let sortedUserLevelList = userLevelList.sorted()
        
        for level in sortedUserLevelList {
            if currentUserLevel < level {
                return UserLevelMap[level] ?? "X"
            }
        }
        
        // Current Max Level of the Sakaki App
        return "Master"
    }
}
