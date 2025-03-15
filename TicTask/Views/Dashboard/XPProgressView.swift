//
//  XPProgressView..swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-14.
//

import SwiftUI

struct XPProgressView: View {
    let xp: Int
    var maxXP: Int

    var progress: CGFloat {
        CGFloat(xp) / CGFloat(maxXP)
    }

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.0, to: 0.5)
                .stroke(Color.gray.opacity(0.3), lineWidth: 10)
                .frame(width: 200, height: 100)

            Circle()
                .trim(from: 0.0, to: progress / 2)
                .stroke(Color.green, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .frame(width: 200, height: 100)
                .rotationEffect(.degrees(180))

            VStack {
                Text("\(xp) XP")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Nivå \((xp) / maxXP + 1)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.top)
    }
}

