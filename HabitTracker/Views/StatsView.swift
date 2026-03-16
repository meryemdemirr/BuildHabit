//
//  StatsView.swift
//  HabitTracker
//
//  Created by Meryem Demir on 14.02.2026.
//

import SwiftUI
import UIKit

// MARK: - Ana İstatistik Görünümü (Matris / Heatmap)

struct StatsView: View {
    let habits: [Habit]
    
    /// Matris için gösterilecek günler: Haftalık/Aylık alışkanlıklar planlanan günleri; Sıklık Yok için tamamlanan günler. Hepsi yoksa son 28 gün.
    private var matrixDays: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var allDays = Set<Date>()
        
        for habit in habits {
            switch habit.frequency {
            case .none:
                for d in habit.completionDates {
                    allDays.insert(calendar.startOfDay(for: d))
                }
            case .daily, .weekly, .monthly:
                for d in habit.scheduledDates {
                    allDays.insert(calendar.startOfDay(for: d))
                }
                let created = calendar.startOfDay(for: habit.createdAt ?? today)
                for offset in 0..<60 {
                    guard let date = calendar.date(byAdding: .day, value: -offset, to: today),
                          date >= created else { continue }
                    allDays.insert(date)
                }
            }
        }
        
        let from = calendar.date(byAdding: .day, value: -60, to: today)!
        let sorted = allDays.filter { $0 >= from && $0 <= today }.sorted()
        if sorted.isEmpty {
            return (0..<28).compactMap { calendar.date(byAdding: .day, value: -27 + $0, to: today) }
        }
        return sorted
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        headerSection
                        
                        if habits.isEmpty {
                            emptyState
                        } else {
                            HabitMatrixHeatmap(habits: habits, matrixDays: matrixDays)
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("İstatistikler")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(Color(.label))
            
            Text("Alışkanlık performansınızı takip edin")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(Color(.secondaryLabel))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 64))
                .foregroundColor(Color(.tertiaryLabel))
            
            Text("Henüz veri yok")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(Color(.label))
            
            Text("Alışkanlık ekleyip takip etmeye başladığınızda istatistikleriniz burada görünecek")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }
}

// MARK: - Matris / Heatmap Bileşeni (Sticky sol sütun + yatay kaydırılabilir günler)

struct HabitMatrixHeatmap: View {
    let habits: [Habit]
    let matrixDays: [Date]
    
    private let rowHeight: CGFloat = 52
    private let cellSize: CGFloat = 36
    private let habitColumnWidth: CGFloat = 140
    private let dayColumnWidth: CGFloat = 40
    private let gridLineWidth: CGFloat = 0.5
    
    private static let dayLabels = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"]
    
    private func dayLabel(for date: Date) -> String {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let idx = (weekday + 5) % 7
        return Self.dayLabels[idx]
    }
    
    private func dayNumber(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Performans Matrisi")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color(.label))
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            
            // Sticky sol sütun (alışkanlık isimleri) + tek yatay ScrollView (günler başlığı ve tüm satırlar birlikte kayar)
            HStack(alignment: .top, spacing: 0) {
                // Sol sabit sütun: başlık boşluğu + her alışkanlık adı/ikonu
                VStack(alignment: .leading, spacing: 0) {
                    Color.clear
                        .frame(width: habitColumnWidth - 20, height: 44)
                    ForEach(habits) { habit in
                        HStack(spacing: 10) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(habit.swiftUIColor.opacity(0.25))
                                    .frame(width: 36, height: 36)
                                Image(systemName: habit.icon)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(habit.swiftUIColor)
                            }
                            Text(habit.title)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(Color(.label))
                                .lineLimit(1)
                        }
                        .frame(width: habitColumnWidth - 20, height: rowHeight, alignment: .leading)
                        .padding(.leading, 20)
                    }
                }
                .frame(width: habitColumnWidth)
                .background(Color(.systemBackground))
                
                // Yatay kaydırılabilir alan: gün başlıkları + tüm satırlar tek ScrollView'da (senkron kaydırma)
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Gün başlıkları
                        HStack(spacing: 4) {
                            ForEach(matrixDays, id: \.self) { date in
                                VStack(spacing: 2) {
                                    Text(dayLabel(for: date))
                                        .font(.system(size: 9, weight: .medium, design: .rounded))
                                        .foregroundColor(Color(.secondaryLabel))
                                    Text(dayNumber(for: date))
                                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(.label))
                                }
                                .frame(width: dayColumnWidth, height: 44)
                            }
                        }
                        .padding(.horizontal, 12)
                        
                        Divider()
                            .background(Color(.separator).opacity(0.6))
                        
                        // Satırlar
                        ForEach(habits) { habit in
                            HStack(spacing: 4) {
                                ForEach(matrixDays, id: \.self) { date in
                                    MatrixCell(
                                        habit: habit,
                                        date: date,
                                        cellSize: cellSize,
                                        isCompleted: habit.isCompleted(on: date)
                                    )
                                }
                            }
                            .padding(.horizontal, 12)
                            .frame(height: rowHeight)
                            
                            Divider()
                                .background(Color(.separator).opacity(0.4))
                        }
                    }
                }
                .background(Color(.systemBackground))
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator).opacity(0.5), lineWidth: gridLineWidth)
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Tek hücre (dolu = alışkanlık rengi, boş = ince gri çerçeve)

struct MatrixCell: View {
    let habit: Habit
    let date: Date
    let cellSize: CGFloat
    let isCompleted: Bool
    
    var body: some View {
        ZStack {
            if isCompleted {
                RoundedRectangle(cornerRadius: 8)
                    .fill(habit.swiftUIColor.opacity(0.85))
                    .frame(width: cellSize, height: cellSize - 4)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray4).opacity(0.6), lineWidth: 0.8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray6).opacity(0.3))
                    )
                    .frame(width: cellSize, height: cellSize - 4)
            }
        }
        .frame(width: cellSize, height: cellSize - 4)
    }
}

// MARK: - Özet kutuları (isteğe bağlı, eski tasarımdan)

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color(.label))
            
            Text(title)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(Color(.secondaryLabel))
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

#Preview {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    var habits: [Habit] = [
        Habit(title: "Sabah Egzersizi", icon: "figure.run", color: Color(red: 1.0, green: 0.7, blue: 0.5), streak: 5, frequency: .weekly),
        Habit(title: "Kitap Okuma", icon: "book.fill", color: Color(red: 0.7, green: 0.5, blue: 1.0), streak: 3, frequency: .daily)
    ]
    habits[0].scheduledDates = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: calendar.date(byAdding: .day, value: -7, to: today)!) }
    habits[1].completionDates = [today, calendar.date(byAdding: .day, value: -1, to: today)!]
    return StatsView(habits: habits)
}
