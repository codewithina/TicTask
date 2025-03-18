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
            VStack(spacing: 8) {
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
            }
    }
}
