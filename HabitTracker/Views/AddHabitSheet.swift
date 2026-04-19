//
//  AddHabitSheet.swift
//  HabitTracker
//
//  Created by Meryem Demir on 14.02.2026.
//

import SwiftUI

struct AddHabitSheet: View {
    @EnvironmentObject var habitManager: HabitManager
    @Environment(\.dismiss) var dismiss
    
    @State private var habitTitle = ""
    @State private var habitDescription = ""
    @State private var selectedColor: PastelColor = .blue
    @State private var selectedIcon = "book.fill"
    @State private var selectedFrequency: HabitFrequency = .daily
    @State private var selectedStartDate = Date()
    
    // Pastel renkler
    enum PastelColor: String, CaseIterable {
        case blue = "Pastel Mavi"
        case green = "Pastel Yeşil"
        case pink = "Pastel Pembe"
        case yellow = "Pastel Sarı"
        case purple = "Pastel Mor"
        case orange = "Pastel Turuncu"
        
        var color: Color {
            switch self {
            case .blue:
                return Color(red: 0.6, green: 0.8, blue: 1.0)
            case .green:
                return Color(red: 0.5, green: 0.9, blue: 0.6)
            case .pink:
                return Color(red: 1.0, green: 0.7, blue: 0.8)
            case .yellow:
                return Color(red: 1.0, green: 0.95, blue: 0.6)
            case .purple:
                return Color(red: 0.8, green: 0.7, blue: 1.0)
            case .orange:
                return Color(red: 1.0, green: 0.8, blue: 0.6)
            }
        }
    }
    
    // Popüler SF Symbols ikonları
    let availableIcons = [
        "book.fill", "figure.run", "leaf.fill", "cup.and.saucer.fill",
        "pills.fill", "bed.double.fill", "drop.fill", "flame.fill",
        "heart.fill", "star.fill", "moon.fill", "sun.max.fill"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Sistem arka plan rengi (Light/Dark mode uyumlu)
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                Form {
                    Section {
                        // Alışkanlık İsmi
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Alışkanlık İsmi")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(.label))
                            
                            TextField("Örn: Sabah Egzersizi", text: $habitTitle)
                                .font(.system(size: 16, design: .rounded))
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.secondarySystemGroupedBackground))
                                )
                        }
                        .padding(.vertical, 8)
                        
                        // Açıklama
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Açıklama")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(.label))
                            
                            TextEditor(text: $habitDescription)
                                .font(.system(size: 16, design: .rounded))
                                .frame(minHeight: 100)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.secondarySystemGroupedBackground))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.separator), lineWidth: 0.5)
                                )
                        }
                        .padding(.vertical, 8)
                    } header: {
                        Text("Bilgiler")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(.secondaryLabel))
                    }
                    
                    Section {
                        // Renk Seçimi - 6 Pastel Renk (Küçük)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Renk Seçimi")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(.label))
                            
                            HStack(spacing: 16) {
                                ForEach(PastelColor.allCases, id: \.self) { pastelColor in
                                    ColorCircleView(
                                        color: pastelColor.color,
                                        isSelected: selectedColor == pastelColor
                                    ) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedColor = pastelColor
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.vertical, 8)
                    } header: {
                        Text("Görünüm")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(.secondaryLabel))
                    }
                    
                    Section {
                        // İkon Seçimi - Sadece Horizontal Scroll (Önizleme yok)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("İkon Seçimi")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(.label))
                            
                            // İkon Horizontal Scroll
                            IconSelectionView(
                                icons: availableIcons,
                                selectedIcon: $selectedIcon,
                                selectedColor: selectedColor.color
                            )
                        }
                        .padding(.vertical, 8)
                    } header: {
                        Text("İkon")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(.secondaryLabel))
                    }
                    
                    Section {
                        // Başlangıç Tarihi
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Başlangıç Tarihi")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(.label))
                            
                            DatePicker("", selection: $selectedStartDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                        }
                        .padding(.vertical, 8)
                        
                        // Sıklık Seçimi
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Sıklık")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(.label))
                            
                            Picker("Sıklık", selection: $selectedFrequency) {
                                ForEach(HabitFrequency.allCases, id: \.self) { frequency in
                                    Text(frequency.rawValue).tag(frequency)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(.vertical, 8)
                    } header: {
                        Text("Takvim")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(.secondaryLabel))
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color(.systemGroupedBackground))
            }
            .navigationTitle("Yeni Alışkanlık")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Vazgeç") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color(.label))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        saveHabit()
                    }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(
                        habitTitle.isEmpty ?
                        Color(.secondaryLabel) :
                        selectedColor.color
                    )
                    .disabled(habitTitle.isEmpty)
                }
            }
        }
    }
    
    private func saveHabit() {
        guard !habitTitle.isEmpty else { return }
        
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: selectedStartDate)
        
        let trimmedDescription = habitDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        var newHabit = Habit(
            title: habitTitle,
            icon: selectedIcon,
            color: selectedColor.color,
            streak: 0,
            createdAt: startDate,
            frequency: selectedFrequency,
            notes: trimmedDescription.isEmpty ? nil : trimmedDescription
        )
        
        var scheduledDates: [Date] = []
        
        switch selectedFrequency {
        case .none:
            // Sıklık yok: Sadece manuel işaretlenen günler
            break
            
        case .daily:
            // Sadece seçili gün
            scheduledDates.append(startDate)
            
        case .weekly:
            // Seçili günden itibaren 7 gün
            for i in 0..<7 {
                if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                    scheduledDates.append(date)
                }
            }
            
        case .monthly:
            // Seçili günden itibaren 30 gün
            for i in 0..<30 {
                if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                    scheduledDates.append(date)
                }
            }
        }
        
        newHabit.scheduledDates = scheduledDates
        
        withAnimation {
            habitManager.addHabit(newHabit)
        }
        
        dismiss()
    }
}

#Preview {
    AddHabitSheet()
        .environmentObject(HabitManager())
}
