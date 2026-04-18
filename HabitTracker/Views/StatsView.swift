//
//  StatsView.swift
//  HabitTracker
//
//  Created by Meryem Demir on 14.02.2026.
//

import SwiftUI
import UIKit

// MARK: - İstatistik (aylık habit × gün matrisi)

struct StatsView: View {
    let habits: [Habit]
    
    private let calendar = Calendar.current
    private let cellSide: CGFloat = 12
    private let cellGap: CGFloat = 2
    private let cellCorner: CGFloat = 3.5
    private let habitColumnWidth: CGFloat = 112
    /// Sol etiket (ikon + başlık) ile hücre satırı aynı yükseklikte hizalansın.
    private let habitRowHeight: CGFloat = 28
    
    private var monthStart: Date {
        let comps = calendar.dateComponents([.year, .month], from: Date())
        return calendar.date(from: comps)!
    }
    
    private var daysInMonth: Int {
        calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30
    }
    
    private var monthTitle: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "LLLL yyyy"
        return f.string(from: monthStart).capitalized(with: f.locale)
    }
    
    private var matrixStats: (targets: Int, completed: Int, dailyAvgPercent: Int, completionRatio: Double) {
        Self.computeMatrixStats(habits: habits, monthStart: monthStart, daysInMonth: daysInMonth, calendar: calendar)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        headerBlock
                        
                        if habits.isEmpty {
                            emptyState
                        } else {
                            habitDayMatrix
                            
                            summaryBlock(stats: matrixStats)
                            
                            MonthlyProgressRing(ratio: matrixStats.completionRatio)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private var headerBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("İstatistikler")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(Color(.label))
            
            Text(monthTitle)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(.secondaryLabel))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 20)
    }
    
    /// Sütunlar = günler 1…N, satırlar = habit; tek yatay kaydırma (sol etiket sütunu sabit genişlik).
    private var habitDayMatrix: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: cellGap) {
                VStack(alignment: .leading, spacing: cellGap) {
                    ForEach(habits) { habit in
                        HStack(spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(habit.swiftUIColor.opacity(0.22))
                                    .frame(width: 28, height: 28)
                                Image(systemName: habit.icon)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(habit.swiftUIColor)
                            }
                            Text(habit.title)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(Color(.label))
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(width: habitColumnWidth, height: habitRowHeight, alignment: .leading)
                    }
                }
                
                ForEach(1...daysInMonth, id: \.self) { day in
                    VStack(alignment: .center, spacing: cellGap) {
                        ForEach(habits) { habit in
                            if let date = dateInMonth(day: day) {
                                ZStack {
                                    MatrixDayCell(
                                        tracked: habit.isTracked(on: date),
                                        completed: habit.isCompleted(on: date),
                                        habitColor: habit.swiftUIColor,
                                        side: cellSide,
                                        corner: cellCorner
                                    )
                                }
                                .frame(width: cellSide, height: habitRowHeight)
                            }
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
    
    private func dateInMonth(day: Int) -> Date? {
        var comps = calendar.dateComponents([.year, .month], from: monthStart)
        comps.day = day
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        return calendar.date(from: comps)
    }
    
    private func summaryBlock(stats: (targets: Int, completed: Int, dailyAvgPercent: Int, completionRatio: Double)) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Günlük ortalama %\(stats.dailyAvgPercent) tamamlandı")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Color(.label))
            
            Text("Bu ay \(stats.targets) habitten \(stats.completed)'i tamamlandı")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Color(.secondaryLabel))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 56))
                .foregroundStyle(Color(.tertiaryLabel))
            Text("Henüz veri yok")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
            Text("Alışkanlık eklediğinde aylık matris burada görünecek.")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    /// targets = Σ gün başına (o gün takip edilen habit sayısı), completed = Σ (takip + tamamlandı)
    private static func computeMatrixStats(
        habits: [Habit],
        monthStart: Date,
        daysInMonth: Int,
        calendar: Calendar
    ) -> (targets: Int, completed: Int, dailyAvgPercent: Int, completionRatio: Double) {
        var targets = 0
        var completed = 0
        var dailyPercents: [Double] = []
        
        for day in 1...daysInMonth {
            var comps = calendar.dateComponents([.year, .month], from: monthStart)
            comps.day = day
            comps.hour = 0
            comps.minute = 0
            comps.second = 0
            guard let date = calendar.date(from: comps) else { continue }
            
            let tracked = habits.filter { $0.isTracked(on: date) }
            let done = tracked.filter { $0.isCompleted(on: date) }
            targets += tracked.count
            completed += done.count
            
            if !tracked.isEmpty {
                dailyPercents.append(Double(done.count) / Double(tracked.count) * 100)
            }
        }
        
        let dailyAvg = dailyPercents.isEmpty ? 0.0 : dailyPercents.reduce(0, +) / Double(dailyPercents.count)
        let dailyAvgInt = Int(dailyAvg.rounded())
        let ratio = targets > 0 ? Double(completed) / Double(targets) : 0
        return (targets, completed, dailyAvgInt, ratio)
    }
}

// MARK: - Hücre

private struct MatrixDayCell: View {
    let tracked: Bool
    let completed: Bool
    let habitColor: Color
    let side: CGFloat
    let corner: CGFloat
    
    var body: some View {
        Group {
            if !tracked {
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(Color(.tertiarySystemFill).opacity(0.35))
            } else if completed {
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(habitColor.opacity(0.95))
            } else {
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(Color(.systemGray5).opacity(0.55))
            }
        }
        .frame(width: side, height: side)
    }
}

// MARK: - Aylık dairesel ilerleme

private struct MonthlyProgressRing: View {
    let ratio: Double
    
    private var percentText: String {
        "\(Int((ratio * 100).rounded()))%"
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Aylık tamamlanma")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(.secondaryLabel))
            
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 10)
                    .frame(width: 100, height: 100)
                
                Circle()
                    .trim(from: 0, to: CGFloat(min(1, max(0, ratio))))
                    .stroke(
                        AngularGradient(
                            colors: [
                                Color(red: 0.95, green: 0.7, blue: 0.5),
                                Color(red: 0.22, green: 0.72, blue: 0.48)
                            ],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                
                Text(percentText)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(Color(.label))
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Özet kutusu

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
                    .foregroundStyle(color)
            }
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Color(.label))
            Text(title)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Color(.secondaryLabel))
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
    habits[0].scheduledDates = (0..<18).compactMap { calendar.date(byAdding: .day, value: $0 - 8, to: today) }
    habits[1].completionDates = [today, calendar.date(byAdding: .day, value: -2, to: today)!]
    return StatsView(habits: habits)
}
