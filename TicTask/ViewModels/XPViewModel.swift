//
//  XPViewModel.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-22.
//

import SwiftUI
import FirebaseFirestore

class XPViewModel: ObservableObject {
    @Published var xpLog: [XPEvent] = []
    @Published var xpPerDay: [XPPerDayItem] = []
    private var perDayListeners: [ListenerRegistration] = []
    
    
    func startListening(for userID: String) {
        XPLogService.shared.listenToXPLog(for: userID) { [weak self] events in
            DispatchQueue.main.async {
                self?.xpLog = events
            }
        }
    }
    
    func stopListening() {
        XPLogService.shared.stopListening()
    }
    
    func startListeningForXPPerDay(for children: [User]) {
        stopListeningForXPPerDay()
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let last7Days = (0...6).compactMap {
            calendar.date(byAdding: .day, value: -$0, to: today)
        }.sorted()
        
        for child in children {
            guard let childID = child.id else { continue }
            
            let listener = Firestore.firestore()
                .collection("users")
                .document(childID)
                .collection("xpLog")
                .whereField("date", isGreaterThanOrEqualTo: last7Days.first!)
                .addSnapshotListener { [weak self] snapshot, error in
                    guard let self = self else { return }
                    guard let documents = snapshot?.documents else {
                        print("❌ Inga dokument för \(child.name)")
                        return
                    }
                    
                    print("📡 Hämtade \(documents.count) dokument för barn: \(child.name)")
                    
                    var groupedXP: [Date: Int] = [:]
                    var events: [(Date, Int)] = []
                    
                    for doc in documents {
                        let data = doc.data()
                        guard let xp = data["xp"] as? Int,
                              let timestamp = data["date"] as? Timestamp else {
                            print("⚠️ Ogiltig data i dokument: \(doc.data())")
                            continue
                        }
                        
                        let eventDate = calendar.startOfDay(for: timestamp.dateValue())
                        events.append((eventDate, xp))
                        groupedXP[eventDate, default: 0] += xp
                    }
                    
                    print("🧩 Events för \(child.name):", events)
                    print("📊 groupedXP för \(child.name):", groupedXP)
                    
                    let items = last7Days.map { date in
                        XPPerDayItem(
                            date: date,
                            xp: groupedXP[date] ?? 0,
                            childName: child.name
                        )
                    }
                    
                    print("✅ Skickar \(items.count) dagar till xpPerDay för \(child.name)")
                    
                    DispatchQueue.main.async {
                        self.xpPerDay.removeAll { $0.childName == child.name }
                        self.xpPerDay.append(contentsOf: items)
                        print("🟢 xpPerDay innehåller nu \(self.xpPerDay.count) rader")
                    }
                }
            
            perDayListeners.append(listener)
        }
    }
    
    func stopListeningForXPPerDay() {
        perDayListeners.forEach { $0.remove() }
        perDayListeners.removeAll()
        xpPerDay.removeAll()
    }
}

struct XPPerDayItem: Identifiable {
    let id = UUID()
    let date: Date
    let xp: Int
    let childName: String
}

