//
//  bin.swift
//  Sakaki
//
//  Created by Liran Fainshtein on 09/06/2023.
//

import SwiftUI

struct Bin: Identifiable, Equatable {
    var id: String
    var binName: String
    var imageURL: String
    var lastUpdate: Date
    var latitude: Double
    var longitude: Double
    var status: String
}
