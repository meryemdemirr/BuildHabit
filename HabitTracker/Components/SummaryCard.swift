//
//  SummaryCard.swift
//  HabitTracker
//
//  Created by Meryem Demir on 14.02.2026.
//

import SwiftUI

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon - Soluk renk arka plan mantığı (Dark Mode uyumlu)
            HStack {
                ZStack {
                    // Seçilen rengin soluk versiyonu (opacity 0.2 - Dark Mode uyumlu)
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    // İkon tam renk
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(color)
                }
                
                Spacer()
            }
            
            // Value
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(Color(.label))
            
            // Title
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Color(.secondaryLabel))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    HStack(spacing: 16) {
        SummaryCard(
            title: "Toplam Alışkanlık",
            value: "4",
            icon: "checkmark.circle.fill",
            color: Color(red: 0.6, green: 0.8, blue: 1.0)
        )
        
        SummaryCard(
            title: "Aktif Seri",
            value: "7",
            icon: "flame.fill",
            color: Color(red: 1.0, green: 0.6, blue: 0.4)
        )
    }
    .padding()
}
