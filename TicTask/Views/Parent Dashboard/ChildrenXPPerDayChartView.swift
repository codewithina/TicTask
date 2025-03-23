import SwiftUI
import Charts

struct ChildrenXPPerDayChartView: View {
    @ObservedObject var viewModel: XPViewModel
    var children: [User]

    struct XPPerDay: Identifiable {
        let id = UUID()
        let date: Date
        let xp: Int
        let childName: String
    }

    var body: some View {
        VStack {
            if children.isEmpty {
                Text("Inga barn hittades.")
            } else if viewModel.allXPEvents.isEmpty {
                Text("Ingen XP registrerad än.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                Chart(groupedAndFilledXP()) { item in
                    BarMark(
                        x: .value("Datum", item.date, unit: .day),
                        y: .value("XP", item.xp)
                    )
                    .foregroundStyle(by: .value("Barn", item.childName))
                }
                .frame(height: 250)
            }
        }
        .onAppear {
            viewModel.startListening(for: children)
        }
        .onDisappear {
            viewModel.stopListening()
        }
    }

    /// Returnerar XP per dag per barn – fyller i tomma dagar med 0
    private func groupedAndFilledXP() -> [XPPerDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -6, to: today) else { return [] }

        var results: [XPPerDay] = []

        // Skapa lista på alla dagar vi ska visa
        let last7Days: [Date] = (0...6).compactMap {
            calendar.date(byAdding: .day, value: -$0, to: today)
        }.sorted()

        for child in children {
            let childID = child.id ?? ""
            let childName = child.name
            let childEvents = viewModel.allXPEvents.filter { $0.userID == childID }

            // Gruppera barnets events per dag
            let grouped = Dictionary(grouping: childEvents) {
                calendar.startOfDay(for: $0.date)
            }

            for day in last7Days {
                let eventsForDay = grouped[day] ?? []
                let totalXP = eventsForDay.reduce(0) { $0 + $1.xp }

                results.append(
                    XPPerDay(date: day, xp: totalXP, childName: childName)
                )
            }
        }

        return results.sorted { $0.date < $1.date }
    }
}
