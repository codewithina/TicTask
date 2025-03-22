import Foundation

class XPViewModel: ObservableObject {
    @Published var xpLog: [XPEvent] = []

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
}
