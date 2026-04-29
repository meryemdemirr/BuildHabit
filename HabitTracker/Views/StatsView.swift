//
//  StatsView.swift
//  HabitTracker
//
//  Created by Meryem Demir on 14.02.2026.
//

import SwiftUI
import UIKit

// MARK: - İstatistik (haftalık habit × gün matrisi)

struct StatsView: View {
    let habits: [Habit]
    let selectedDate: Date
    private let calendar = Calendar.current
    private let columnGap: CGFloat = 5
    private let rowGap: CGFloat = 5
    private let nameToGridSpacing: CGFloat = 12
    private let cellCorner: CGFloat = 2
    private let minHabitColumnWidth: CGFloat = 72
    private let maxHabitColumnWidth: CGFloat = 112
    private let accentGradient = LinearGradient(
        colors: [
            Color(red: 1.0, green: 0.62, blue: 0.45),
            Color(red: 0.97, green: 0.46, blue: 0.68)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    private static let shortWeekdayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = .autoupdatingCurrent
        f.setLocalizedDateFormatFromTemplate("EEE")
        return f
    }()
    
    private var monthStart: Date {
        let comps = calendar.dateComponents([.year, .month], from: Date())
        return calendar.date(from: comps)!
    }
    
    private var daysInMonth: Int {
        calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30
    }

    private var matrixStats: (targets: Int, completed: Int, dailyAvgPercent: Int, completionRatio: Double) {
        Self.computeMatrixStats(habits: habits, monthStart: monthStart, daysInMonth: daysInMonth, calendar: calendar)
    }

    private var bestStreak: Int {
        habits.map { $0.streak }.max() ?? 0
    }

    private var topHabitsByStreak: [Habit] {
        habits.sorted { lhs, rhs in
            if lhs.streak == rhs.streak {
                return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
            }
            return lhs.streak > rhs.streak
        }
    }

    private var topThreeHabits: [Habit] {
        Array(topHabitsByStreak.filter { $0.streak > 0 }.prefix(3))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
               
    ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        topOverviewSection
                        
                        if habits.isEmpty {
                            emptyState
                        } else {
                            habitDayMatrix

                            HStack(alignment: .top, spacing: 16) {
                                summaryBlock(stats: matrixStats)
                                Spacer(minLength: 0)
                                MonthlyProgressRing(ratio: matrixStats.completionRatio)
                            }
                            .padding(.top, 44)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private var topOverviewSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("stats_caps_habits")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(.secondaryLabel))

                    (
                        Text("\(habits.count) ")
                            .foregroundStyle(Color(.label))
                    )
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    
                    +
                    Text("stats_habit_suffix")
                        .foregroundStyle(Color(.secondaryLabel))
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.secondarySystemGroupedBackground))
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text("stats_caps_best_streak")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(.secondaryLabel))

                    (
                        Text("\(bestStreak) ")
                            .foregroundStyle(Color(.label))
                    )
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    
                    +
                    Text("stats_days")
                        .foregroundStyle(Color(.secondaryLabel))
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
                .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("stats_top_habits")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(.secondaryLabel))

                    Spacer()

                }

                if topThreeHabits.isEmpty {
                    Text("stats_no_habits_yet")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(.secondaryLabel))
                        .padding(.vertical, 8)
                } else {
                    ForEach(topThreeHabits) { habit in
                        HStack(spacing: 10) {
                            Text(habit.title)
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundStyle(Color(.label))
                                .lineLimit(1)
                                .truncationMode(.tail)

                            Spacer(minLength: 8)

                            Text(String(format: NSLocalizedString("stats_streak_fire", comment: ""), habit.streak))
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color(.secondaryLabel))
                                .monospacedDigit()
                        }
                        .padding(.vertical, 3)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
        }
        .padding(.top, 20)
    }
    
    /// Sütunlar = haftanın günleri, satırlar = habit; tek yatay kaydırma.
    private var habitDayMatrix: some View {
        GeometryReader { geo in
            let availableWidth = max(0, geo.size.width)
            let longestTitleCount = habits.map { $0.title.count }.max() ?? 0
            let estimatedTitleWidth = CGFloat(longestTitleCount) * 7.2
            let dayColumnWidth: CGFloat = 20
            let dynamicCellSide: CGFloat = 20
            let rowHeight: CGFloat = 20
            let fixedGridWidth = (dayColumnWidth * 7) + (columnGap * 6)
            let maxHabitWidthByLayout = max(0, availableWidth - fixedGridWidth - nameToGridSpacing)
            let desiredHabitWidth = min(maxHabitColumnWidth, max(minHabitColumnWidth, estimatedTitleWidth + 8))
            let habitColumnWidth = min(desiredHabitWidth, maxHabitWidthByLayout)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center, spacing: nameToGridSpacing) {
                    Color.clear
                        .frame(width: habitColumnWidth, height: 16)

                    HStack(spacing: columnGap) {
                        ForEach(Array(weekDates.enumerated()), id: \.offset) { idx, _ in
                            Text(Self.shortWeekdayFormatter.string(from: weekDates[idx]))
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color(.secondaryLabel))
                                .frame(width: dayColumnWidth, height: 16)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: rowGap) {
                    ForEach(habits) { habit in
                        HStack(alignment: .center, spacing: nameToGridSpacing) {
                            Text(habit.title)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(Color(.secondaryLabel))
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .multilineTextAlignment(.center)
                                .frame(width: habitColumnWidth, height: rowHeight, alignment: .center)

                            HStack(spacing: columnGap) {
                                ForEach(weekDates, id: \.self) { date in
                                    MatrixDayCell(
                                        completed: habit.isCompleted(on: date),
                                        side: dynamicCellSide,
                                        corner: cellCorner
                                    )
                                    .frame(width: dayColumnWidth, height: rowHeight)
                                }
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: CGFloat(habits.count) * (20 + rowGap) + 38)
        .frame(maxWidth: .infinity)
    }
    
    private var weekDates: [Date] {
        let normalizedSelectedDate = calendar.startOfDay(for: selectedDate)
        let weekday = calendar.component(.weekday, from: normalizedSelectedDate)
        let mondayOffset = (weekday + 5) % 7
        guard let monday = calendar.date(byAdding: .day, value: -mondayOffset, to: normalizedSelectedDate) else { return [] }
        return (0..<7).compactMap { index in
            calendar.date(byAdding: .day, value: index, to: monday)
        }
    }

    private func summaryBlock(stats: (targets: Int, completed: Int, dailyAvgPercent: Int, completionRatio: Double)) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("stats_daily_average")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(.label))
                Text(String(format: NSLocalizedString("stats_percent_complete", comment: ""), stats.dailyAvgPercent))
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(accentGradient)
            }
            .padding(.bottom, 2)
            
            Text(String(format: NSLocalizedString("stats_month_summary", comment: ""), stats.targets, stats.completed))
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(Color(.secondaryLabel))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 56))
                .foregroundStyle(Color(.tertiaryLabel))
            Text("stats_empty_title")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
            Text("stats_empty_subtitle")
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
    ) -> (targets: Int, completed: Int, dailyAvgPercent: Int, completionRatio: Double) { var targets = 0
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
    @Environment(\.colorScheme) private var colorScheme

    let completed: Bool
    let side: CGFloat
    let corner: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: corner, style: .continuous)
            .fill(cellColor)
            .overlay(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .stroke(borderColor, lineWidth: 0.6)
            )
        .frame(width: side, height: side)
    }

    private var cellColor: Color {
        if completed {
            return colorScheme == .dark
                ? Color.accentColor.opacity(0.95)
                : Color.accentColor.opacity(0.9)
        }
        return colorScheme == .dark
            ? Color(red: 0.42, green: 0.44, blue: 0.5).opacity(0.4)
            : Color(red: 0.9, green: 0.91, blue: 0.94)
    }

    private var borderColor: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.08)
            : Color.black.opacity(0.05)
    }
}

// MARK: - Aylık dairesel ilerleme

private struct MonthlyProgressRing: View {
    let ratio: Double
    private let accentGradient = LinearGradient(
        colors: [
            Color(red: 1.0, green: 0.62, blue: 0.45),
            Color(red: 0.97, green: 0.46, blue: 0.68)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    private var percentText: String {
        "\(Int((ratio * 100).rounded()))%"
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 6)
                .frame(width: 78, height: 78)

            Circle()
                .trim(from: 0, to: CGFloat(min(1, max(0, ratio))))
                .stroke(
                    accentGradient,
                    style: StrokeStyle(lineWidth: 7, lineCap: .round)
                )
                .frame(width: 78, height: 78)
                .rotationEffect(.degrees(-90))

            Text(percentText)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(accentGradient)
        }
        .frame(width: 78, height: 78)
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
    StatsView(habits: makePreviewHabits(), selectedDate: Date())
}

private func makePreviewHabits() -> [Habit] {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    var sampleHabits: [Habit] = [
        Habit(title: "Sabah Egzersizi", icon: "figure.run", color: Color(red: 1.0, green: 0.7, blue: 0.5), streak: 5, frequency: .weekly),
        Habit(title: "Kitap Okuma", icon: "book.fill", color: Color(red: 0.7, green: 0.5, blue: 1.0), streak: 3, frequency: .daily)
    ]
    sampleHabits[0].scheduledDates = (0..<18).compactMap { calendar.date(byAdding: .day, value: $0 - 8, to: today) }
    sampleHabits[1].completionDates = [today, calendar.date(byAdding: .day, value: -2, to: today)!]
    return sampleHabits
}
 
