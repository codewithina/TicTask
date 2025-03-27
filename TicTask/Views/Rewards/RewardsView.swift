//
//  RewardsView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-03.
//
import SwiftUI

struct RewardsView: View {
    @EnvironmentObject var rewardViewModel: RewardViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var showConfirmation = false
    @State private var selectedReward: Reward?
    
    @State private var animateXPLoss = false
    @State private var showXPDeductionText = false
    @State private var deductedXP: Int = 0
    @State private var xpShakeAngle: Double = 0
    
    @State private var showFallingCoins = false
    
    var isChild: Bool {
        authViewModel.user?.role == "child"
    }
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    if rewardViewModel.availableRewards.isEmpty {
                        Text("Inga rewards tillgängliga")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        List(rewardViewModel.availableRewards) { reward in
                            HStack(spacing: 15) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: reward.colorHex).opacity(0.2))
                                        .frame(width: 50, height: 50)
                                    
                                    Image(systemName: reward.iconName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(Color(hex: reward.colorHex))
                                }
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(reward.title)
                                        .font(.headline)
                                        .lineLimit(1)
                                    
                                    Text(reward.description)
                                        .font(.subheadline)
                                        .lineLimit(2)
                                    
                                    Text("XP: \(reward.xpCost)")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                    
                                    if isChild {
                                        Text("Tillagd av: \(authViewModel.parentNames[reward.createdBy] ?? "Förälder")")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                let canAfford = (authViewModel.user?.xp ?? 0) >= reward.xpCost
                                
                                Button(action: {
                                    selectedReward = reward
                                    showConfirmation = true
                                }) {
                                    Text("Köp")
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(canAfford ? Color.green : Color.gray)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                                .disabled(!canAfford)
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
                .navigationTitle("Belöningar")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        ZStack(alignment: .bottomTrailing) {
                            HStack(spacing: 5) {
                                Image(systemName: "star.circle.fill")
                                    .foregroundColor(.yellow)
                                
                                Text("\(authViewModel.user?.xp ?? 0) XP")
                                    .font(.headline)
                            }
                            .padding(8)
                            .background(Color.yellow.opacity(0.15))
                            .cornerRadius(10)
                            .rotationEffect(.degrees(xpShakeAngle))
                            .scaleEffect(animateXPLoss ? 1.15 : 1.0)
                            .animation(.default, value: xpShakeAngle)
                            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: animateXPLoss)
                            
                            if showXPDeductionText {
                                Text("-\(deductedXP) XP")
                                    .font(.caption2.bold())
                                    .foregroundColor(.orange)
                                    .offset(y: 28)
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                    }
                }
                .onAppear {
                    if let userID = authViewModel.user?.id {
                        rewardViewModel.startListeningForRewards(for: userID)
                    }
                }
                .confirmationDialog("Är du säker att du vill köpa denna belöning?",
                                    isPresented: $showConfirmation,
                                    titleVisibility: .visible) {
                    Button("Ja, köp", role: .destructive) {
                        if let userID = authViewModel.user?.id, let reward = selectedReward {
                            rewardViewModel.redeemReward(reward: reward, userID: userID)
                            
                            // XP shake + -XP + coins
                            deductedXP = reward.xpCost
                            withAnimation {
                                animateXPLoss = true
                                showXPDeductionText = true
                                showFallingCoins = true
                            }
                            
                            // Shake animation
                            withAnimation(.default.speed(3)) { xpShakeAngle = -20 }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.default.speed(3)) { xpShakeAngle = 20 }
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                withAnimation(.default.speed(3)) { xpShakeAngle = -15 }
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.default.speed(3)) { xpShakeAngle = 10 }
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                withAnimation(.default.speed(3)) { xpShakeAngle = -5 }
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.default.speed(3)) { xpShakeAngle = 0 }
                            }
                            
                            // Close after 1.5 sek
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation {
                                    animateXPLoss = false
                                    showXPDeductionText = false
                                    showFallingCoins = false
                                }
                            }
                        }
                    }
                    Button("Avbryt", role: .cancel) {}
                } message: {
                    if let reward = selectedReward {
                        Text("\(reward.title) kostar \(reward.xpCost) XP.")
                    }
                }
            }
            
            if showFallingCoins {
                FallingCoinsView()
                    .transition(.opacity)
                    .zIndex(50)
            }
        }
    }
}
struct FallingCoinsView: View {
    @State private var coinOffsets: [CGSize] = Array(repeating: .zero, count: 12)
    @State private var opacities: [Double] = Array(repeating: 1.0, count: 12)
    @State private var startX: [CGFloat] = (0..<12).map { _ in CGFloat.random(in: -20...20) }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<12, id: \.self) { index in
                    Image(systemName: "coloncurrencysign.circle.fill")
                        .resizable()
                        .frame(width: 14, height: 14)
                        .foregroundColor(.yellow)
                        .offset(
                            x: geo.size.width - 40 + startX[index],
                            y: coinOffsets[index].height
                        )
                        .opacity(opacities[index])
                        .onAppear {
                            withAnimation(.easeOut(duration: 1.2).delay(Double(index) * 0.05)) {
                                coinOffsets[index] = CGSize(width: 0, height: 250 + CGFloat.random(in: -20...40))
                                opacities[index] = 0
                            }
                        }
                }
            }
        }
        .allowsHitTesting(false)
    }
}
