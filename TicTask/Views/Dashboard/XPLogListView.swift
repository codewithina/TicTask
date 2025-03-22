struct XPLogListView: View {
    @StateObject private var logViewModel = XPLogViewModel()
    let userID: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if logViewModel.events.isEmpty {
                Text("Inga XP-händelser ännu.")
                    .foregroundColor(.gray)
            } else {
                ForEach(logViewModel.events.prefix(5)) { event in
                    HStack {
                        Text(event.title)
                        Spacer()
                        Text("+\(event.xp) XP")
                            .foregroundColor(.green)
                    }
                    .font(.subheadline)
                }
            }
        }
        .onAppear {
            logViewModel.startListening(for: userID)
        }
    }
}
