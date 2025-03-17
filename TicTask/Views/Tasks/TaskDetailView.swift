//
//  TaskDetailView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-04.
//

import SwiftUI

struct TaskDetailView: View {
    var task: Task
    @EnvironmentObject var taskViewModel: TaskViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var isCompleted = false
    @State private var showStars = false
    @State private var showXP = false
    @State private var showDeleteConfirm = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 10) {
                VStack {
                    HStack(spacing: 15) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: task.colorHex).opacity(0.3))
                                .frame(width: 70, height: 70)
                            
                            Image(systemName: task.iconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35, height: 35)
                                .foregroundColor(Color(hex: task.colorHex))
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(task.title)
                                .font(.title.bold())
                                .foregroundColor(.primary)
                            
                            Text("Du tjänar \(task.xpReward) XP!")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                    }
                    
                    Text(task.description)
                        .font(.body)
                        .padding()
                    Spacer()
                }
                .padding()
                .frame(maxHeight: .infinity, alignment: .top)
                .background(Color(hex: task.colorHex).opacity(0.15))
                .cornerRadius(10)
                .padding(.horizontal)
                
                Spacer()
                
                VStack {
                    // Deadline
                    if let deadline = task.deadline {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.red)
                            
                            Text("Deadline: \(deadline.formatted(date: .abbreviated, time: .omitted))")
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    
                    if !task.isCompleted {
                        Button(action: {
                            withAnimation {
                                isCompleted = true
                                showStars = true
                                showXP = true
                                taskViewModel.markTaskAsCompleted(task: task)
                            }
                            
                            // XP fade after 1.5 sec
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation {
                                    showXP = false
                                }
                            }
                        }) {
                            Text("KLAR")
                                .padding()
                                .font(.title2)
                                .frame(maxWidth: .infinity)
                                .background(Color.green.opacity(0.2))
                                .foregroundColor(.green)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                    } else {
                        Text("Uppgift slutförd!")
                            .padding()
                            .font(.title2)
                            .frame(maxWidth: .infinity)
                            .background(Color(.lightGray).opacity(0.2))
                            .foregroundColor(.gray)
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .overlay(
                                StarExplosionView()
                                    .opacity(showStars ? 1 : 0)
                                    .scaleEffect(showStars ? 1 : 0.5)
                                    .animation(.easeOut(duration: 0.5), value: showStars)
                            )
                    }
                }
            }
            .padding()
            
            // XP animation
            if showXP {
                Text("+\(task.xpReward) XP")
                    .font(.largeTitle.bold())
                    .foregroundColor(Color(.yellow).opacity(0.7))
                    .transition(.scale.combined(with: .opacity))
                StarExplosionView()
                    .opacity(showStars ? 1 : 0)
                    .scaleEffect(showStars ? 1.5 : 0.5)
                    .animation(.easeOut(duration: 0.5), value: showStars)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    print("Redigera uppgift")
                }) {
                    Image(systemName: "square.and.pencil")
                }
                if taskViewModel.authViewModel?.user?.role == "parent" {
                    Button(action: {
                        showDeleteConfirm = true
                        print("Ta bort uppgift")
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    } }
            }
        }
        .confirmationDialog("Är du säker på att du vill ta bort uppgiften?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Ta bort", role: .destructive) {
                taskViewModel.deleteTask(task: task)
                dismiss()
            }
            Button("Avbryt", role: .cancel) { }
        }
    }
}

struct StarExplosionView: View {
    @State private var starOffsets: [CGSize] = Array(repeating: .zero, count: 8)
    @State private var starScales: [CGFloat] = Array(repeating: 1, count: 8)
    @State private var starOpacities: [Double] = Array(repeating: 1, count: 8)
    
    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                Image(systemName: "star.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 10, height: 10)
                    .foregroundColor(.yellow)
                    .scaleEffect(starScales[index])
                    .offset(starOffsets[index])
                    .opacity(starOpacities[index])
                    .onAppear {
                        withAnimation(.easeOut(duration: 1).delay(Double(index) * 0.05)) {
                            starOffsets[index] = randomOffset()
                            starScales[index] = 1.5
                            starOpacities[index] = 0
                        }
                    }
            }
        }
    }
    
    func randomOffset() -> CGSize {
        let distance = CGFloat.random(in: 40...120)
        let angle = CGFloat.random(in: 0...(2 * .pi))
        
        return CGSize(
            width: cos(angle) * distance,
            height: sin(angle) * distance
        )
    }
}
