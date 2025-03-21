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
                .font(.system(size: 24))
                .foregroundColor(.yellow)
            
            Text(notification.message)
                .font(.subheadline)
                .lineLimit(2)
            
            Spacer()
            
            Button(action: {
                if let userID = authViewModel.user?.id {
                    notificationViewModel.deleteNotification(for: userID, notificationID: notification.id ?? "")
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 8)
            .fill(Color(hex: "#FFFFFF").opacity(0.1))
            .shadow(radius: 1))
    }
}

