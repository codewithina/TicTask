//
//  RewardsSummaryView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-14.
//

import SwiftUI

struct RewardsSummaryView: View {
    var rewardCount: Int

    var body: some View {
        SectionBox(title: "Belöningar tillgängliga") {
            Text("\(rewardCount) belöningar att köpa")
                .font(.headline)
                .foregroundColor(.blue)
                .padding()
        }
    }
}
