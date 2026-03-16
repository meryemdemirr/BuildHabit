//
//  WeeklyCalendarView.swift
//  HabitTracker
//
//  Created by Meryem Demir on 14.02.2026.
//

import SwiftUI

struct WeeklyCalendarView: View {
    @Binding var selectedDate: Date
    
    // Bugünü merkeze alan 7 günlük görünüm (önceki 3 gün + bugün + sonraki 3 gün)
    private var weekDates: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return (-3...3).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: today)
        }
    }
    
    private func dayName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }
    
    private func dayNumber(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
    
    private func isSelected(_ date: Date) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(weekDates, id: \.self) { date in
                    CalendarDayButton(
                        date: date,
                        isToday: isToday(date),
                        isSelected: isSelected(date),
                        dayName: dayName(for: date),
                        dayNumber: dayNumber(for: date),
                        onTap: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedDate = date
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
    }
}

struct CalendarDayButton: View {
    let date: Date
    let isToday: Bool
    let isSelected: Bool
    let dayName: String
    let dayNumber: String
    let onTap: () -> Void
    
    private var isHighlighted: Bool {
        isToday || isSelected
    }
    
    private var backgroundStyle: some ShapeStyle {
        if isToday {
            // Bugün için pastel turuncu-pembe gradient
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.85, blue: 0.7),
                        Color(red: 1.0, green: 0.75, blue: 0.85)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        } else if isSelected {
            // Seçili gün için pastel mavi
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        Color(red: 0.7, green: 0.85, blue: 1.0),
                        Color(red: 0.8, green: 0.75, blue: 1.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        } else {
            // Diğer günler için pastel gri
            return AnyShapeStyle(Color(.secondarySystemGroupedBackground))
        }
    }
    
    private var textColor: Color {
        isHighlighted ? Color.white : Color(.label)
    }
    
    private var secondaryTextColor: Color {
        isHighlighted ? Color.white : Color(.secondaryLabel)
    }
    
    private var borderColor: Color {
        if isToday {
            return Color(red: 1.0, green: 0.7, blue: 0.5)
        } else if isSelected {
            return Color(red: 0.6, green: 0.8, blue: 1.0)
        } else {
            return Color.clear
        }
    }
    
    private var shadowColor: Color {
        isHighlighted ? Color.black.opacity(0.15) : Color.black.opacity(0.06)
    }
    
    private var shadowRadius: CGFloat {
        isHighlighted ? 8 : 4
    }
    
    private var shadowY: CGFloat {
        isHighlighted ? 4 : 2
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(dayName)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(secondaryTextColor)
                
                Text(dayNumber)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(textColor)
            }
            .frame(width: 50, height: 70)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(backgroundStyle)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: isHighlighted ? 2.5 : 0)
            )
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: 0,
                y: shadowY
            )
        }
    }
}

#Preview {
    WeeklyCalendarView(selectedDate: .constant(Date()))
        .padding()
}
