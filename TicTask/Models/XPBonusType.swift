//
//  XPBonusType.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-22.
//

import Foundation
import FirebaseFirestore

enum XPBonusType: String, Codable {
    case baseTask
    case streak
    case deadlineEarly
    case dailyCombo
    case surprise
    case levelUp
}

struct XPEvent: Identifiable, Codable {
    @DocumentID var id: String?
    let title: String
    let xp: Int
    let date: Date
    let type: XPBonusType
}
