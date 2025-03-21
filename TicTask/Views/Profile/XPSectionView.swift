//
//  XPSectionView.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-16.
//

import SwiftUI

struct XPSectionView: View {
    let xp: Int
    let totalXP: Int
    
    var body: some View {
        Section {
            Text("\(xp) / \(totalXP) XP")
                .font(.largeTitle)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}
