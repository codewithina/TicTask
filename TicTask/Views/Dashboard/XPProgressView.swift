//
//  XPProgressView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-14.
//
import SwiftUI

struct XPProgressView: View {
    let allTimeXP: Int   // Total XP som aldrig minskar
    let spendableXP: Int // XP som kan användas för att köpa belöningar
    let maxXPPerLevel: Int // XP som krävs per nivå

    var currentLevel: Int {
        return (allTimeXP / maxXPPerLevel) + 1
    }

    var progress: CGFloat {
        let xpInCurrentLevel = allTimeXP % maxXPPerLevel
        return CGFloat(xpInCurrentLevel) / CGFloat(maxXPPerLevel)
    }

    var body: some View {
        VStack(spacing: 10) {
            // Progress Bar
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12)
                    .frame(width: 300, height: 20)
                    .foregroundColor(Color.gray.opacity(0.3))
                
                RoundedRectangle(cornerRadius: 12)
                    .frame(width: CGFloat(progress) * 300, height: 20)
                    .foregroundColor(.blue)
            }
            
            // XP & level
            Text("Nivå \(currentLevel) • XP: \(allTimeXP % maxXPPerLevel) / \(maxXPPerLevel)")
                .font(.subheadline)
                .padding(.top, 5)

            HStack {
                Image(systemName: "star.circle.fill")
                    .foregroundColor(.yellow)
                    .font(.title2)
                
                Text("Spenderbar XP: \(spendableXP)")
                    .font(.headline)
            }
            .padding(.top, 5)
        }
        .padding(.vertical)
    }
}

struct XPProgressView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            XPProgressView(allTimeXP: 3200, spendableXP: 500, maxXPPerLevel: 1000)
            XPProgressView(allTimeXP: 1500, spendableXP: 200, maxXPPerLevel: 1000)
            XPProgressView(allTimeXP: 800, spendableXP: 100, maxXPPerLevel: 1000)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}



