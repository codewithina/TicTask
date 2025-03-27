//
//  XPProgressView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-14.
//
import SwiftUI

struct XPProgressView: View {
    let allTimeXP: Int
    let spendableXP: Int
    let maxXPPerLevel: Int
    
    var currentLevel: Int {
        return (allTimeXP / maxXPPerLevel) + 1
    }
    
    var progress: CGFloat {
        let xpInCurrentLevel = allTimeXP % maxXPPerLevel
        return CGFloat(xpInCurrentLevel) / CGFloat(maxXPPerLevel)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .trim(from: 0.0, to: progress / 2)
                    .stroke(
                        AngularGradient(gradient: Gradient(colors: [
                            Color.purple.opacity(0.8),
                            Color.blue.opacity(0.8),
                            Color.purple.opacity(0.8)
                        ]), center: .center),
                        style: StrokeStyle(lineWidth: 30, lineCap: .round)
                    )
                    .frame(width: 220, height: 160)
                    .rotationEffect(.degrees(180))
                    .offset(y:30)
                
                Text("\(currentLevel)")
                    .font(.system(size: 50, weight: .bold))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .offset(y: 25)
            }
            
            HStack {
                Image(systemName: "star.circle.fill")
                    .foregroundColor(.yellow)
                    .font(.title2)
                
                Text(" \(spendableXP)")
                    .font(.title)
            }
            .padding(.top, -20)
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



