//
//  ChildSelectionRow.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-15.
//
import SwiftUI

struct ChildSelectionRow: View {
    let child: User
    @Binding var selectedChildren: [String]

    var body: some View {
        HStack {
            Text(child.name)
            Spacer()
            if let childID = child.id, selectedChildren.contains(childID) {
                Image(systemName: "checkmark")
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard let childID = child.id else { return }

            if selectedChildren.contains(childID) {
                selectedChildren.removeAll { $0 == childID }
            } else {
                selectedChildren.append(childID)
            }
        }
    }
}
