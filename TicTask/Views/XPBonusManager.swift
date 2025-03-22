import Foundation

class XPBonusManager {
    static let shared = XPBonusManager()

    func applyBonuses(for task: Task, user: User, completedAt: Date, allCompletedTasks: [Task]) {
        let userID = user.id ?? ""
        var bonusEvents: [XPEvent] = []

        // Deadline-bonus
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

        // Dagscombo
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

        // Spara alla bonusar
        for event in bonusEvents {
            TaskService.shared.updateUserXP(userID: userID, xpReward: event.xp)
            XPLogService.shared.logXPEvent(userID: userID, event: event)
        }
    }
}
