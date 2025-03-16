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
                        Spacer()

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

                    if !isCompleted {
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
                    .foregroundColor(.yellow)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

struct StarExplosionView: View {
    @State private var starOffsets: [CGSize] = Array(repeating: .zero, count: 6)
    @State private var starOpacities: [Double] = Array(repeating: 1, count: 6)

    var body: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { index in
                Image(systemName: "star.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.yellow)
                    .offset(starOffsets[index])
                    .opacity(starOpacities[index])
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.5).delay(Double(index) * 0.1)) {
                            starOffsets[index] = randomOffset()
                            starOpacities[index] = 0
                        }
                    }
            }
        }
    }

    func randomOffset() -> CGSize {
        return CGSize(width: CGFloat.random(in: -50...50), height: CGFloat.random(in: -50...50))
    }
}
