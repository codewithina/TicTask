//
//  User.swift
//  TicTask
//
//  Created by Ina Burström on 2025-02-28.
//

import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    let registeredAt: Date
    var name: String
    let email: String
    let role: String  // "child" or "parent"
    let xp: Int?
    let totalXP: Int?
    let parentIDs: [String]?  // List of parents ID if child
    let children: [String]?  // List of childrens ID if parent
}
