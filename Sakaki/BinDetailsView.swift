//
//  BinDetailsView.swift
//  Sakaki
//
//  Created by Liran Fainshtein on 22/06/2023.
//

import SwiftUI
import URLImage

struct BinDetailsView: View {
    @State var bin: Bin
    
    @Binding var isBinSelected: Bool
    
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isActionSheetPresented = false
    
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
                    Button {
                        isActionSheetPresented = true
                    } label: {
                        Text("Update Station")
                            .font(.title2)
                            .padding()
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
                    
                    
                    Divider()
                    
                    HStack {
                        Button {
                            isBinSelected.toggle()
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Route")
                                .font(.title2)
                                .padding()
                            Image(systemName: "arrow.triangle.turn.up.right.diamond")
                                .font(.title2)
                                .padding()
                        }
                        .foregroundColor(.white)
                        .background(.blue)
                        .cornerRadius(20)
                        
                        Spacer()
                        
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
                        .background(.red)
                        .cornerRadius(20)
                    }
                }
            }
            .padding()
            
            Spacer()
        }
        .actionSheet(isPresented: $isActionSheetPresented) {
            ActionSheet(title: Text("Select Status"), buttons: [
                .default(Text("Full")) {
                    updateBinStatus(status: "Full")
                    
                },
                .default(Text("Half Full")) {
                    updateBinStatus(status: "Half Full")
                },
                .default(Text("Empty")) {
                    updateBinStatus(status: "Empty")
                },
                .cancel()
            ])
        }
    }
    
    private func updateBinStatus(status: String) {
        dataManager.updateBin(bin: bin, status: status)
        
        // Update the local bin object with the new status and last update
        bin.status = status
        bin.lastUpdate = Date.now
    }
}
