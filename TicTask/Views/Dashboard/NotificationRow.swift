//
//  NotificationRow.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-14.
//

import SwiftUI

struct NotificationRow: View {
    let notification: NotificationModel
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        HStack {
            Image(systemName: "sparkles")
                .font(.system(size: 30))
                .foregroundColor(.yellow)

            Text(notification.message)
                .font(.subheadline)

            Spacer()

            Button(action: {
                if let userID = authViewModel.user?.id {
                    notificationViewModel.deleteNotification(for: userID, notificationID: notification.id ?? "")
                }
            }) {
                Text("OK")
            }
        }
        .padding()
    }
}
