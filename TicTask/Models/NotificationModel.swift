//
//  Notification.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-14.
//

import Foundation

struct NotificationModel: Identifiable, Codable {
    var id: String = UUID().uuidString
    let message: String
    let timestamp: Date

    enum CodingKeys: String, CodingKey {
        case id
        case message
        case timestamp
    }
}


