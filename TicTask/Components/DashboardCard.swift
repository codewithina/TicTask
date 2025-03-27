//
//  DashboardCard.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-18.
//
import SwiftUI

struct DashboardCard<Content: View>: View {
    let title: String
    let icon: String
    let color: String
    let content: Content
    
    init(title: String, icon: String, color: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content()
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
                
                Spacer()
            }
            .padding(.bottom, 5)
            
            content
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12)
            .fill(Color(hex: color).opacity(0.1))
            .shadow(radius: 3))
        .padding(.horizontal)
    }
}
