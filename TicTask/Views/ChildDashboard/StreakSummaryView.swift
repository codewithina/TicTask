//
//  StreakSummaryView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-22.
import SwiftUI

struct StreakSummaryView: View {
    @EnvironmentObject var taskViewModel: TaskViewModel
    let user: User
    
    @State private var streakDays = 0
    @State private var lastUpdatedDay = Calendar.current.startOfDay(for: Date())
    
    var body: some View {
        VStack {
            if !taskViewModel.isListening {
                ProgressView("Laddar streak...")
            } else {
                Text("\(streakDays) dagar utan missade deadlines!")
                    .font(.headline)
                    .foregroundColor(streakDays >= 3 ? .orange : .gray)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if taskViewModel.isListening && !taskViewModel.tasks.isEmpty {
                    updateStreak()
                }
            }
        }
    }
    
    private func updateStreak() {
        streakDays = taskViewModel.calculateStreakDays(for: user)
        lastUpdatedDay = Calendar.current.startOfDay(for: Date())
    }
}
