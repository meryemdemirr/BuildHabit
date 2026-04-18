//
//  StatsView.swift
//  HabitTracker
//
//  Created by Meryem Demir on 14.02.2026.
//

import SwiftUI
import UIKit

// MARK: - Ana istatistik görünümü (aylık kompakt ızgara)

struct StatsView: View {
    let habits: [Habit]
    
    @State private var monthDisplayed: Date = Calendar.current.date(
        from: Calendar.current.dateComponents([.year, .month], from: Date())
    )!
    @State private var selectedHabitDay: HabitDaySelection?
    
    private static let weekdaySymbols = ["Pt", "Sa", "Ça", "Pe", "Cu", "Ct", "Pz"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        headerSection
                        
                        if habits.isEmpty {
                            emptyState
                        } else {
                            monthNavigationBar
                            
                            LazyVStack(alignment: .leading, spacing: 20) {
                                ForEach(habits) { habit in
                                    MonthlyHabitContributionCard(
                                        habit: habit,
                                        monthStart: monthDisplayed,
                                        weekdaySymbols: Self.weekdaySymbols
                                    ) { date in
                                        guard habit.isTracked(on: date) else { return }
                                        selectedHabitDay = HabitDaySelection(habit: habit, date: date)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(item: $selectedHabitDay) { selection in
            HabitDayDetailSheet(selection: selection)
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("İstatistikler")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(Color(.label))
            
            Text("Aylık tamamlanma özeti — GitHub katkı grafiği tarzı")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(Color(.secondaryLabel))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private var monthNavigationBar: some View {
        let calendar = Calendar.current
        let title = monthNavigationTitle(for: monthDisplayed)
        
        return HStack(spacing: 16) {
            Button {
                shiftMonth(by: -1, calendar: calendar)
            } label: {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.system(size: 28))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color(.secondaryLabel))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Önceki ay")
            
            Spacer(minLength: 0)
            
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color(.label))
                .multilineTextAlignment(.center)
            
            Spacer(minLength: 0)
            
            Button {
                shiftMonth(by: 1, calendar: calendar)
            } label: {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 28))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color(.secondaryLabel))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Sonraki ay")
        }
        .padding(.horizontal, 20)
    }
    
    private func monthNavigationTitle(for monthStart: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "LLLL yyyy"
        return f.string(from: monthStart).capitalized(with: f.locale)
    }
    
    private func shiftMonth(by delta: Int, calendar: Calendar) {
        guard let next = calendar.date(byAdding: .month, value: delta, to: monthDisplayed) else { return }
        let comps = calendar.dateComponents([.year, .month], from: next)
        if let start = calendar.date(from: comps) {
            monthDisplayed = start
        }
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

// MARK: - Aylık ızgara kartı (LazyVGrid)

private struct MonthlyHabitContributionCard: View {
    let habit: Habit
    let monthStart: Date
    let weekdaySymbols: [String]
    let onCellTap: (Date) -> Void
    
    private let calendar = Calendar.current
    private let columnSpacing: CGFloat = 3
    private let cellCorner: CGFloat = 6
    
    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: columnSpacing), count: 7)
    }
    
    private var daysInMonth: Int {
        calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30
    }
    
    /// Ayın 1. günü Pazartesi tabanlı ızgarada kaç boş hücre (Pzt öncesi).
    private var leadingEmptyCells: Int {
        let first = calendar.date(from: calendar.dateComponents([.year, .month], from: monthStart))!
        let weekday = calendar.component(.weekday, from: first)
        return (weekday + 5) % 7
    }
    
    private var gridCellCount: Int {
        let used = leadingEmptyCells + daysInMonth
        let remainder = used % 7
        return remainder == 0 ? used : used + (7 - remainder)
    }
    
    private func dateForDayNumber(_ day: Int) -> Date? {
        var comps = calendar.dateComponents([.year, .month], from: monthStart)
        comps.day = day
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        return calendar.date(from: comps)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(habit.swiftUIColor.opacity(0.22))
                        .frame(width: 34, height: 34)
                    Image(systemName: habit.icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(habit.swiftUIColor)
                }
                
                Text(habit.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(.label))
                    .lineLimit(2)
                
                Spacer(minLength: 0)
            }
            
            LazyVGrid(columns: gridColumns, spacing: columnSpacing) {
                ForEach(0..<7, id: \.self) { i in
                    Text(weekdaySymbols[i])
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(.tertiaryLabel))
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 2)
                }
            }
            
            LazyVGrid(columns: gridColumns, spacing: columnSpacing) {
                ForEach(0..<gridCellCount, id: \.self) { index in
                    monthCell(at: index)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
    
    @ViewBuilder
    private func monthCell(at index: Int) -> some View {
        if index < leadingEmptyCells || index >= leadingEmptyCells + daysInMonth {
            Color.clear
                .aspectRatio(1, contentMode: .fit)
        } else {
            let day = index - leadingEmptyCells + 1
            if let date = dateForDayNumber(day) {
                let tracked = habit.isTracked(on: date)
                let done = habit.isCompleted(on: date)
                ContributionDayCell(
                    dayNumber: day,
                    tracked: tracked,
                    completed: done,
                    habitColor: habit.swiftUIColor,
                    cornerRadius: cellCorner
                )
                .aspectRatio(1, contentMode: .fit)
                .contentShape(Rectangle())
                .onTapGesture {
                    if tracked {
                        onCellTap(date)
                    }
                }
            } else {
                Color.clear.aspectRatio(1, contentMode: .fit)
            }
        }
    }
}

// MARK: - Tek gün kutusu

private struct ContributionDayCell: View {
    let dayNumber: Int
    let tracked: Bool
    let completed: Bool
    let habitColor: Color
    let cornerRadius: CGFloat
    
    var body: some View {
        ZStack {
            if !tracked {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color(.tertiarySystemFill).opacity(0.45))
            } else if completed {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(habitColor.opacity(0.92))
            } else {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color(.systemGray5))
            }
            
            Text("\(dayNumber)")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(foregroundForLabel)
        }
    }
    
    private var foregroundForLabel: Color {
        if !tracked { return Color(.tertiaryLabel) }
        if completed { return Color.white.opacity(0.95) }
        return Color(.secondaryLabel)
    }
}

// MARK: - Gün detayı (bonus)

struct HabitDaySelection: Identifiable {
    let habit: Habit
    let date: Date
    var id: String { "\(habit.id.uuidString)-\(Calendar.current.startOfDay(for: date).timeIntervalSince1970)" }
}

private struct HabitDayDetailSheet: View {
    let selection: HabitDaySelection
    @Environment(\.dismiss) private var dismiss
    
    private var dateText: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateStyle = .full
        f.timeStyle = .none
        return f.string(from: selection.date)
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(selection.habit.swiftUIColor.opacity(0.25))
                            .frame(width: 44, height: 44)
                        Image(systemName: selection.habit.icon)
                            .foregroundStyle(selection.habit.swiftUIColor)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selection.habit.title)
                            .font(.headline)
                        Text(dateText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Label(
                    selection.habit.isCompleted(on: selection.date) ? "Bu gün tamamlandı" : "Bu gün tamamlanmadı",
                    systemImage: selection.habit.isCompleted(on: selection.date) ? "checkmark.circle.fill" : "circle"
                )
                .font(.body.weight(.medium))
                .foregroundStyle(selection.habit.isCompleted(on: selection.date) ? Color.green : Color.secondary)
                
                Spacer(minLength: 0)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .navigationTitle("Gün özeti")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Tamam") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Özet kutusu (eski tasarım; istenirse kullanılır)

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
    habits[0].scheduledDates = (0..<20).compactMap { calendar.date(byAdding: .day, value: $0 - 10, to: today) }
    habits[1].completionDates = [today, calendar.date(byAdding: .day, value: -1, to: today)!]
    return StatsView(habits: habits)
}
