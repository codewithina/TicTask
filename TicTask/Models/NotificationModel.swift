//
//  Notification.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-14.
//

import Foundation
import FirebaseFirestore

struct NotificationModel: Identifiable, Codable {
    @DocumentID var id: String?
    let message: String
    let timestamp: Date

    enum CodingKeys: String, CodingKey {
        case id
        case message
        case timestamp
    }
}


