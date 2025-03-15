//
//  NotificationViewModel.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-14.
//

import SwiftUI

class NotificationViewModel: ObservableObject {
    @Published var notifications: [NotificationModel] = []
    
    func startListeningForNotifications(for userID: String) {
        NotificationService.shared.startListeningForNotifications(for: userID) { [weak self] fetchedNotifications in
            DispatchQueue.main.async {
                self?.notifications = fetchedNotifications
            }
        }
    }
    
    func stopListening() {
        NotificationService.shared.stopListening()
    }
    
    func sendNotification(to userID: String, message: String) {
        NotificationService.shared.sendNotification(to: userID, message: message)
    }
    
    func deleteNotification(for userID: String, notificationID: String) {
        NotificationService.shared.deleteNotification(for: userID, notificationID: notificationID)
    }
}


