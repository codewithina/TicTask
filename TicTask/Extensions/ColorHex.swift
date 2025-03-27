//
//  ColorHex.swift
//  TicTask
//
//  Created by Ina Burström on 2025-03-12.
//
import SwiftUI

extension Color {
    static let lilac = Color(hex: "#D7C2D8")
    static let polarsky = Color(hex: "#B3D9E1")
    static let pistachio = Color(hex: "#B1CFB7")
    static let vanilla = Color(hex: "#EFD9AA")
    static let apricot = Color(hex: "#EFBA93")
    
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized
        
        let scanner = Scanner(string: hexSanitized)
        var rgb: UInt64 = 0
        
        if scanner.scanHexInt64(&rgb) {
            let red = Double((rgb >> 16) & 0xFF) / 255.0
            let green = Double((rgb >> 8) & 0xFF) / 255.0
            let blue = Double(rgb & 0xFF) / 255.0
            self.init(red: red, green: green, blue: blue)
        } else {
            self.init(red: 0, green: 0, blue: 0)
        }
    }
}
