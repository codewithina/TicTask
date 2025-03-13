//
//  Reward.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-12.
//

import SwiftUI
import FirebaseFirestore

struct Reward: Identifiable, Codable {
    var id: String? 
    var title: String
    let description: String
    let xpCost: Int
    let createdBy: String
    let assignedTo: [String]
    let redeemedBy: [String]
    let iconName: String      // SF Symbol-name (ex: "star.fill")
    let colorHex: String      // Color in hex (ex: "#FF5733")

    // Convert hex to SwiftUI Color
    func color() -> Color {
        return Color(hex: colorHex)
    }
}
