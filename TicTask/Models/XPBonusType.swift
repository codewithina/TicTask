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
    case earlyBird
    
    var priority: Int {
        switch self {
        case .baseTask: return 0
        case .streak: return 1
        case .deadlineEarly: return 2
        case .dailyCombo: return 3
        case .surprise: return 4
        case .levelUp: return 5
        case .earlyBird: return 6
        }
    }
}

struct XPEvent: Identifiable, Codable {
    @DocumentID var id: String?
    let title: String
    let xp: Int
    let date: Date
    let type: XPBonusType
}
