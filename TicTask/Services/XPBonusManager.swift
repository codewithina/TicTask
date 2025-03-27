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
                XPEvent(title: "Läxan klar 2 dagar före deadline ⏳", xp: extraXP, date: completedAt, type: .deadlineEarly)
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

        // Sort completed unique days
        var uniqueDays: [Date] = []

        for task in allCompletedTasks.sorted(by: { ($0.completedDate ?? Date.distantPast) < ($1.completedDate ?? Date.distantPast) }) {
            guard let completedDate = task.completedDate else { continue }
            let day = calendar.startOfDay(for: completedDate)

            if uniqueDays.last != day {
                uniqueDays.append(day)
            }
        }

        // Count streak
        var streak = 1
        for i in stride(from: uniqueDays.count - 2, through: 0, by: -1) {
            let prevDay = uniqueDays[i]
            let nextDay = uniqueDays[i + 1]
            
            if let expectedNextDay = calendar.date(byAdding: .day, value: 1, to: prevDay),
               calendar.isDate(expectedNextDay, inSameDayAs: nextDay) {
                streak += 1
            } else {
                break
            }
        }

        // Check if bonus (3, 6, 9...)
        if streak > 0, streak % 3 == 0 {
            bonusEvents.append(
                XPEvent(title: "🔥 \(streak) dagar i rad! 🏆", xp: 10, date: completedAt, type: .streak)
            )
        }
        
        // Early bird bonus – läxa klar före kl. 18
        let deadlineHour = 18
        if let earlyDeadline = calendar.date(bySettingHour: deadlineHour, minute: 0, second: 0, of: completedAt),
           completedAt < earlyDeadline {
            bonusEvents.append(
                XPEvent(title: "⏰ Tidig läxa! Bra jobbat 💪", xp: 5, date: completedAt, type: .earlyBird)
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
    
    func checkForLevelUp(userID: String, oldTotalXP: Int, newTotalXP: Int, isTriggeredByLevelUp: Bool = false) {
        if isTriggeredByLevelUp { return }

        let oldLevel = oldTotalXP / 1000 + 1
        let newLevel = newTotalXP / 1000 + 1

        if newLevel > oldLevel {
            let event = XPEvent(
                title: "Du gick upp till nivå \(newLevel)! 🎉",
                xp: 50,
                date: Date(),
                type: .levelUp
            )

            XPLogService.shared.logXPEvent(userID: userID, event: event)

            TaskService.shared.updateUserXP(userID: userID, xpReward: event.xp) { _ in
                print("🚀 Extra XP för level-up till \(newLevel)!")
                
                XPBonusManager.shared.checkForLevelUp(
                    userID: userID,
                    oldTotalXP: newTotalXP,
                    newTotalXP: newTotalXP + event.xp,
                    isTriggeredByLevelUp: true
                )
            }
        }
    }
}

