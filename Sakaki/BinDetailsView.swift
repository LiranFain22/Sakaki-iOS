import SwiftUI
import FirebaseStorage
import URLImage
import FirebaseAuth
import UIKit

enum ActionSheetType: Identifiable {
    case status
    case camera
    
    var id: ActionSheetType { self }
}

struct BinDetailsView: View {
    @State var bin: Bin
    
    @Binding var isBinSelectedToRoute: Bool
    
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isUsingCamera = false
    @State private var isImageFullScreen = false
    @State private var isShowingImagePicker = false
    @State private var uploadProgress: Double = 0.0
    @State private var selectedImage: UIImage?
    @State private var actionSheetType: ActionSheetType?
    
    var body: some View {
        VStack {
            
            Text(bin.binName)
                .font(.largeTitle)
                .padding()
            
            VStack(spacing: 10) {
                URLImage(URL(string: bin.imageURL)!) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .onTapGesture {
                    // Activate full screen image view
                    isImageFullScreen = true
                }
                .fullScreenCover(isPresented: $isImageFullScreen) {
                    // Full screen image view
                    ImageView(url: bin.imageURL, isImageFullScreen: $isImageFullScreen)
                }
                
                if uploadProgress > 0.0 && uploadProgress < 100.0 {
                    ProgressView(value: uploadProgress, total: 100.0)
                        .progressViewStyle(LinearProgressViewStyle())
                        .padding(.horizontal)
                }
                
                Divider()
                
                HStack {
                    Text("Status: ")
                        .bold()
                    Spacer()
                    Text(bin.status)
                }
                Divider()
                HStack {
                    Text("Last Update: ")
                        .bold()
                    Spacer()
                    Text(Helper.formattedDate(bin.lastUpdate))
                }
                Divider()
                VStack {
                    
                    HStack {
                        
                        Spacer()
                        
                        Button {
                            actionSheetType = ActionSheetType.status
                        } label: {
                            Image(systemName: "newspaper")
                                .font(.title2)
                                .padding()
                        }
                        .foregroundColor(.white)
                        .background(.green)
                        .cornerRadius(20)
                        .onChange(of: bin.status) { newStatus in
                            updateBinStatus(status: newStatus)
                        }
                        
                        Spacer()
                        
                        Button {
                            isBinSelectedToRoute.toggle()
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "arrow.triangle.turn.up.right.diamond")
                                .font(.title2)
                                .padding()
                        }
                        .foregroundColor(.white)
                        .background(.blue)
                        .cornerRadius(20)
                        
                        Spacer()
                        
                        Button {
                            actionSheetType = ActionSheetType.camera
                        } label: {
                            Image(systemName: "camera")
                                .font(.title2)
                                .padding()
                        }
                        .foregroundColor(.white)
                        .background(.purple)
                        .cornerRadius(20)
                        
                        Spacer()
                    }
                    
                    Divider()
                    
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Return")
                            .font(.title2)
                            .padding()
                        Image(systemName: "return")
                            .font(.title2)
                            .padding()
                    }
                    .foregroundColor(.white)
                    .background(.gray)
                    .cornerRadius(20)
                    .padding()
                }
            }
            .padding()
            
            Spacer()
        }
        .actionSheet(item: $actionSheetType) { type in
            switch type {
            case .status:
                return ActionSheet(title: Text("Select Status"), buttons: [
                    .default(Text("Full")) {
                        updateBinStatus(status: "Full")
                        updateUserData()
                    },
                    .default(Text("Half Full")) {
                        updateBinStatus(status: "Half Full")
                        updateUserData()
                    },
                    .default(Text("Empty")) {
                        updateBinStatus(status: "Empty")
                        updateUserData()
                    },
                    .cancel()
                ])
            case .camera:
                return ActionSheet(title: Text("Select Option"), buttons: [
                    .default(Text("Camera")) {
                        isUsingCamera = true
                        isShowingImagePicker = true
                    },
                    .default(Text("From Gallery")) {
                        isUsingCamera = false
                        isShowingImagePicker = true
                    },
                    .cancel()
                ])
            }
        }
    }
    
    private func updateBinStatus(status: String) {
        dataManager.updateBinStatus(bin: bin, status: status)
        
        // Update the local bin object with the new status and last update
        bin.status = status
        bin.lastUpdate = Date.now
    }
    
    private func updateUserData() {
        if let user = Auth.auth().currentUser {
            if let userData = dataManager.userData {
                dataManager.updateUserReportCount(user: user, userData: userData)
            } else {
                print("Error - Can't get userData (updateUserData function)")
                Helper.showAlert(title: "Error", message: "Something went wrong...")
            }
        } else {
            print("Error - Can't get user from FirebaseAuth (updateUserData function)")
            Helper.showAlert(title: "Error", message: "Something went wrong...")
        }
    }
    
    private func loadImage() {
        guard let selectedImage = selectedImage else { return }
        
        // Convert the selected image to data
        guard let imageData = selectedImage.jpegData(compressionQuality: 0.8) else {
            print("Error converting image to data")
            Helper.showAlert(title: "Error", message: "Something went wrong...")
            return
        }
        
        // Create a unique filename for the image using a timestamp
        let filename = "\(UUID().uuidString).jpg"
        
        let storage = Storage.storage()
        let storageRef = storage.reference().child("images").child(filename)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // Upload the image data to Firebase Storage
        let uploadTask = storageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                print("Error uploading image to Firebase Storage: \(error.localizedDescription)")
                Helper.showAlert(title: "Error", message: "Something went wrong...")
            } else {
                // Image uploaded successfully, retrieve the download URL of the uploaded image
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error retrieving download URL: \(error.localizedDescription)")
                        Helper.showAlert(title: "Error", message: "Something went wrong...")
                    } else {
                        if let downloadURL = url {
                            // The download URL of the uploaded image
                            let imageURL = downloadURL.absoluteString
                            // Update bin with the imageURL
                            dataManager.updateBinPhoto(bin: bin, imageURL: imageURL)
                        }
                    }
                }
            }
        }
        
        // You can also observe the upload progress if needed
        uploadTask.observe(.progress) { snapshot in
            guard let progress = snapshot.progress else { return }
            let percentComplete = Double(progress.completedUnitCount) / Double(progress.totalUnitCount) * 100.0
            
            // Update the progress bar value
            uploadProgress = percentComplete
        }
    }
}

struct ImageView: View {
    let url: String
    @Binding var isImageFullScreen: Bool
    
    var body: some View {
        VStack {
            URLImage(URL(string: url)!) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .ignoresSafeArea()
            .onTapGesture {
                // Close full screen image view
                isImageFullScreen = false
            }
        }
    }
}
