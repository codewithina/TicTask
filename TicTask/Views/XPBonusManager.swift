//
//  XPBonusManager.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-22.
//

import Foundation

class XPBonusManager {
    static let shared = XPBonusManager()

    func applyBonuses(for task: Task, user: User, completedAt: Date, allCompletedTasks: [Task]) {
        let userID = user.id ?? ""
        var bonusEvents: [XPEvent] = []

        // Deadline bonus - done two days before deadline
        if let deadline = task.deadline,
           Calendar.current.dateComponents([.day], from: completedAt, to: deadline).day ?? 0 >= 2 {
            let extraXP = Int(Double(task.xpReward) * 0.2)
            bonusEvents.append(
                XPEvent(title: "Läxan klar före deadline ⏳", xp: extraXP, date: completedAt, type: .deadlineEarly)
            )
        }

        // Daily combo - two tasks done same day
        let sameDayTasks = allCompletedTasks.filter {
            Calendar.current.isDate($0.completedDate ?? .distantPast, inSameDayAs: completedAt)
        }

        if sameDayTasks.count >= 2 {
            bonusEvents.append(
                XPEvent(title: "Två tasks samma dag ⚡", xp: 10, date: completedAt, type: .dailyCombo)
            )
        }

        // Streak - done tasks 3 days
        let calendar = Calendar.current
        let last3Days = (0..<3).map { calendar.date(byAdding: .day, value: -$0, to: completedAt)! }

        let streakOK = last3Days.allSatisfy { day in
            allCompletedTasks.contains(where: {
                guard let completed = $0.completedDate else { return false }
                return calendar.isDate(completed, inSameDayAs: day)
            })
        }

        if streakOK {
            bonusEvents.append(
                XPEvent(title: "🔥 Streak! 3 dagar i rad 🏆", xp: 10, date: completedAt, type: .streak)
            )
        }

        // Sum bonus XP & update XP once
        let totalBonusXP = bonusEvents.reduce(0) { $0 + $1.xp }

        if totalBonusXP > 0 {
            TaskService.shared.updateUserXP(userID: userID, xpReward: totalBonusXP) { result in
                switch result {
                case .success:
                    for event in bonusEvents {
                        XPLogService.shared.logXPEvent(userID: userID, event: event)
                    }

                case .failure(let error):
                    print("🔴 Kunde inte uppdatera bonus-XP: \(error.localizedDescription)")
                }
            }
        }
    }
}

