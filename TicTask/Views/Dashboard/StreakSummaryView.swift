struct StreakSummaryView: View {
    @State private var streakDays: Int = 0
    let userID: String

    var body: some View {
        VStack {
            Text("🔥 \(streakDays) dagar utan missade deadlines!")
                .font(.headline)
                .foregroundColor(streakDays >= 3 ? .orange : .gray)
        }
        .onAppear {
            XPStreakService.shared.getCurrentStreak(for: userID) { days in
                self.streakDays = days
            }
        }
    }
}
