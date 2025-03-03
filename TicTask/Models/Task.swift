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
    let xpReward: Int
    var status: String // "pending" eller "completed"
    let assignedTo: String // Child ID
    let createdBy: String // Created by child or parent

    // Return if task is done or not
    var isCompleted: Bool {
        return status == "completed"
    }
}

