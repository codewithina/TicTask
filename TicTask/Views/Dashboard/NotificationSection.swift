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
    @State private var isExpanded: Bool = false
    
    let title: String
    let icon: String
    let color: String
    
    init(title: String, icon: String, color: String) {
        self.title = title
        self.icon = icon
        self.color = color
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color(hex: color).opacity(0.2))
                        .frame(width: 30, height: 30)
                    
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color(hex: color))
                }
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                if !notificationViewModel.notifications.isEmpty {
                    Text("\(notificationViewModel.notifications.count)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Circle().fill(Color.red))
                }
                
                Button(action: { isExpanded.toggle() }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
            }
            .padding(.bottom, 5)
            
            if isExpanded {
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
                .padding(.top, 5)
                .transition(.opacity)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12)
            .fill(Color(hex: color).opacity(0.1))
            .shadow(radius: 3))
        .padding(.horizontal)
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
    }
}
