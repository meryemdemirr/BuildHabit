//
//  IconSelectionView.swift
//  HabitTracker
//
//  Created by Meryem Demir on 14.02.2026.
//

import SwiftUI

struct IconSelectionView: View {
    let icons: [String]
    @Binding var selectedIcon: String
    let selectedColor: Color
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(icons, id: \.self) { icon in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedIcon = icon
                        }
                    }) {
                        ZStack {
                            
                            Circle()
                                .fill(
                                    selectedIcon == icon ?
                                    selectedColor.opacity(0.2) :
                                    Color(.systemGray6)
                                )
                                .frame(width: 48, height: 48)
                            
                            // İkon - seçili renkte
                            Image(systemName: icon)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(
                                    selectedIcon == icon ?
                                    selectedColor :
                                    Color(.secondaryLabel)
                                )
                        }
                        .overlay(
                            // Seçili ikon için vurgu
                            Circle()
                                .stroke(
                                    selectedIcon == icon ?
                                    selectedColor :
                                    Color.clear,
                                    lineWidth: 2.5
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    IconSelectionView(
        icons: ["book.fill", "figure.run", "leaf.fill", "cup.and.saucer.fill", "pills.fill", "bed.double.fill"],
        selectedIcon: .constant("book.fill"),
        selectedColor: Color(red: 0.6, green: 0.8, blue: 1.0)
    )
    .padding()
}
