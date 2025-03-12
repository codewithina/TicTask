//
//  User.swift
//  TicTask
//
//  Created by Ina Burström on 2025-02-28.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let name: String
    let email: String
    let role: String  // "child" or "parent"
    let xp: Int?
    let parentIDs: [String]?  // List of parents ID if child
    let children: [String]?  // List of childrens ID if parent
}
