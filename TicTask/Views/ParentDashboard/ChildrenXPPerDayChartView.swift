//
//  ChildrenXPPerDayChartView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-23.
//
import SwiftUI
import Charts

struct ChildrenXPPerDayChartView: View {
    @EnvironmentObject var xpViewModel: XPViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedChild: String? = nil

    var body: some View {
        VStack(alignment: .leading) {
            if xpViewModel.xpPerDay.isEmpty {
                Text("Ingen XP insamlad än.")
                    .foregroundColor(.gray)
            } else {
                Picker("Välj barn", selection: $selectedChild) {
                    Text("Alla barn").tag(nil as String?)
                    ForEach(authViewModel.childrenUsers, id: \.id) { child in
                        Text(child.name).tag(child.name as String?)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.bottom, 8)

                let filtered = xpViewModel.xpPerDay.filter {
                    selectedChild == nil || $0.childName == selectedChild
                }

                Chart {
                    ForEach(filtered) { item in
                        BarMark(
                            x: .value("Datum", item.date),
                            y: .value("XP", item.xp)
                        )
                        .foregroundStyle(by: .value("Barn", item.childName))
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                    }
                }
                .frame(height: 250)
            }
        }
        .onDisappear {
            xpViewModel.stopListeningForXPPerDay()
        }
    }
}
