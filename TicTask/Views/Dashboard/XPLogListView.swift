//
//  XPLogListView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-22.
//
import SwiftUI

struct XPLogListView: View {
    @StateObject private var viewModel = XPViewModel()
    let userID: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if viewModel.xpLog.isEmpty {
                Text("Inga XP-händelser ännu.")
                    .foregroundColor(.gray)
            } else {
                ForEach(
                    viewModel.xpLog
                        .sorted {
                            $0.date == $1.date
                                ? $0.type.priority < $1.type.priority
                                : $0.date > $1.date
                        }
                        .prefix(5)
                ) { event in
                    HStack {
                        Text(event.title)
                        Spacer()
                        Text("+\(event.xp) XP")
                            .foregroundColor(.green)
                    }
                    .font(.subheadline)
                }
            }
        }
        .onAppear {
            viewModel.startListening(for: userID)
        }
        .onDisappear {
            viewModel.stopListening()
        }
    }
}

