//
//  HabitCard.swift
//  HabitTracker
//
//  Created by Meryem Demir on 14.02.2026.
//

import SwiftUI

struct HabitCard: View {
    let habit: Habit
    let selectedDate: Date
    let isInteractionEnabled: Bool
    /// Tamamlama dairesine basılınca.
    let onCompletionToggle: () -> Void
    /// Tamamlama bu tarih için kapalıysa kullanıcıya geri bildirim göstermek için tetiklenir.
    let onDisabledCompletionTap: (() -> Void)?
    /// Kartın sol alanına (başlık/ikon) basılınca — detay.
    let onDetailTap: () -> Void
    @State private var isPressed = false
    
    private var isCompleted: Bool {
        habit.isCompleted(on: selectedDate)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: onDetailTap) {
                HStack(spacing: 16) {
                    // Icon - Dinamik soluk renk arka plan mantığı (Dark Mode uyumlu)
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(habit.swiftUIColor.opacity(0.2))
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: habit.icon)
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(habit.swiftUIColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(habit.title)
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(.label))
                            .multilineTextAlignment(.leading)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.4))
                            
                            Text(String(format: NSLocalizedString("habit_streak_days", comment: ""), habit.streak))
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(Color(.secondaryLabel))
                        }
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            Spacer(minLength: 8)
            
            // Check button - Tarih bazlı tamamlama
            Button(action: {
                guard isInteractionEnabled else {
                    onDisabledCompletionTap?()
                    return
                }

                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = true
                    onCompletionToggle()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isPressed = false
                }
            }) {
                ZStack {
                    // Tamamlanmışsa dolu, değilse sadece çerçeve
                    Circle()
                        .fill(
                            isCompleted ?
                            habit.swiftUIColor :
                            Color.clear
                        )
                        .frame(width: 48, height: 48)
                        .overlay(
                            Circle()
                                .stroke(habit.swiftUIColor, lineWidth: isCompleted ? 0 : 2)
                        )
                    
                    // Tamamlanmışsa check işareti
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .opacity(isInteractionEnabled ? 1.0 : 0.45)
            .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
    }
}

#Preview {
    VStack {
        HabitCard(
            habit: Habit(
                title: "Sabah Egzersizi",
                icon: "figure.run",
                color: Color(red: 1.0, green: 0.7, blue: 0.5),
                streak: 5
            ),
            selectedDate: Date(),
            isInteractionEnabled: true,
            onCompletionToggle: {},
            onDisabledCompletionTap: nil,
            onDetailTap: {}
        )
    }
    .padding()
}
