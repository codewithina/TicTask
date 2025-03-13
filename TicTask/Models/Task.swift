//
//  Task.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-03.
//

import Foundation

struct Task: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let deadline: Date?
    let xpReward: Int
    var status: String // "pending" or "completed"
    let assignedTo: String // Child ID
    let createdBy: String // Created by child or parent
    let iconName: String // SF Symbol-name (ex: "star.fill")
    let colorHex: String // Color in hex (ex: "#FF5733")

    // Return if task is done or not
    var isCompleted: Bool {
        return status == "completed"
    }
}

