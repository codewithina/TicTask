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
        
        // Deadline bonus - two days before deadline
        if let deadline = task.deadline,
           Calendar.current.dateComponents([.day], from: completedAt, to: deadline).day ?? 0 >= 2 {
            let extraXP = Int(Double(task.xpReward) * 0.2)
            let event = XPEvent(
                title: "Läxan klar före deadline ⏳",
                xp: extraXP,
                date: completedAt,
                type: .deadlineEarly
            )
            bonusEvents.append(event)
        }
        
        // Daily combo - two tasks on one day
        let sameDay = allCompletedTasks.filter {
            Calendar.current.isDate($0.completedDate ?? .distantPast, inSameDayAs: completedAt)
        }
        
        if sameDay.count >= 2 {
            let event = XPEvent(
                title: "Dagscombo: Två tasks samma dag ⚡",
                xp: 10,
                date: completedAt,
                type: .dailyCombo
            )
            bonusEvents.append(event)
        }
        
        // Streak bonus - 3 days in a row
        let calendar = Calendar.current
        let last3Days = (0..<3).map { calendar.date(byAdding: .day, value: -$0, to: completedAt)! }
        
        let streakOK = last3Days.allSatisfy { day in
            allCompletedTasks.contains(where: {
                guard let completed = $0.completedDate else { return false }
                return calendar.isDate(completed, inSameDayAs: day)
            })
        }
        
        if streakOK {
            let event = XPEvent(
                title: "🔥 Streak! 3 dagar i rad 🏆",
                xp: 10,
                date: completedAt,
                type: .streak
            )
            bonusEvents.append(event)
        }
        
        // Save and log bonuses
        for event in bonusEvents {
            TaskService.shared.updateUserXP(userID: userID, xpReward: event.xp) { result in
                switch result {
                case .success:
                    print("✅ Bonus XP: \(event.title) +\(event.xp) XP")
                    XPLogService.shared.logXPEvent(userID: userID, event: event)
                case .failure(let error):
                    print("🔴 Kunde inte uppdatera XP: \(error.localizedDescription)")
                }
            }
        }
    }
}
