//
// UpcomingTaskView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-14.
//

import SwiftUI

struct UpcomingTaskView: View {
    var task: Task
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(task.title)
                Spacer()
                
                if let deadline = task.deadline {
                    let now = Date()
                    let twoDaysFromNow = Calendar.current.date(byAdding: .day, value: 2, to: now)!
                    
                    if deadline < now {
                        Text("Försenad ⚠️")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else if deadline < twoDaysFromNow {
                        Text("Snart ⏳")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
    }
}
