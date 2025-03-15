//
//  NotificationSection.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-14.
//

import SwiftUI

struct NotificationSection: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    
    var body: some View {
        SectionBox(title: "Senaste händelser") {
            let notifications = notificationViewModel.notifications
            
            if !notifications.isEmpty {
                ForEach(notifications) { notification in
                    NotificationRow(notification: notification)
                }
            } else {
                Text("Inga nya notiser")
                    .foregroundColor(.gray)
                    .padding()
            }
            
           /* if !notifications.isEmpty {
                Button("Rensa alla") {
                    if let userID = authViewModel.user?.id {
                        for notification in notifications {
                            notificationViewModel.deleteNotification(for: userID, notificationID: notification.id ?? "")
                        }
                    }
                }
                .foregroundColor(.red)
                .padding(.top, 5)
            }*/
        }
    }
}

