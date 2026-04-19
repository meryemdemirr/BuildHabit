//
//  HabitDetailOverlay.swift
//  HabitTracker
//
//  Created by Meryem Demir on 18.04.2026.
//

import SwiftUI

/// Ortalanmış karartmalı arka plan üzerinde alışkanlık başlığı ve açıklaması.
struct HabitDetailOverlay: View {
    let habit: Habit
    let onDismiss: () -> Void
    
    @State private var presented = false
    
    private var descriptionText: String {
        let trimmed = habit.notes?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? "Henüz açıklama eklenmedi." : trimmed
    }
    
    private var descriptionIsPlaceholder: Bool {
        (habit.notes?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "").isEmpty
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    Spacer(minLength: 0)
                    Button(action: dismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Kapat")
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(habit.title)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(.label))
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(descriptionText)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundStyle(descriptionIsPlaceholder ? Color(.tertiaryLabel) : Color(.secondaryLabel))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 4)
                
                Button(action: dismiss) {
                    Text("Kapat")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(habit.swiftUIColor.opacity(0.22))
                        )
                        .foregroundStyle(habit.swiftUIColor)
                }
                .buttonStyle(.plain)
                .padding(.top, 20)
            }
            .padding(22)
            .frame(maxWidth: 340)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color(.separator).opacity(0.35), lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.18), radius: 24, x: 0, y: 12)
            .scaleEffect(presented ? 1 : 0.88)
            .opacity(presented ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.42, dampingFraction: 0.78)) {
                    presented = true
                }
            }
        }
    }
    
    private func dismiss() {
        withAnimation(.easeOut(duration: 0.18)) {
            presented = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            onDismiss()
        }
    }
}

#Preview {
    ZStack {
        Color(.systemGroupedBackground)
        HabitDetailOverlay(
            habit: Habit(title: "Örnek", icon: "star.fill", color: .orange, notes: "Her sabah 10 dk."),
            onDismiss: {}
        )
    }
}
