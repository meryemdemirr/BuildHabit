//
//  ColorCircleView.swift
//  HabitTracker
//
//  Created by Meryem Demir on 14.02.2026.
//

import SwiftUI

struct ColorCircleView: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 36, height: 36)
                
                if isSelected {
                    Circle()
                        .stroke(Color(.label), lineWidth: 2.5)
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HStack {
        ColorCircleView(color: Color(red: 0.6, green: 0.8, blue: 1.0), isSelected: true) {}
        ColorCircleView(color: Color(red: 0.5, green: 0.9, blue: 0.6), isSelected: false) {}
    }
    .padding()
}
