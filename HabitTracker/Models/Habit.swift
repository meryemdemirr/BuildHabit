//
//  Habit.swift
//  HabitTracker
//
//  Created by Meryem Demir on 14.02.2026.
//

import SwiftUI
import UIKit

enum HabitFrequency: String, Codable, CaseIterable {
    case none = "Sıklık Yok"
    case daily = "Günlük"
    case weekly = "Haftalık"
    case monthly = "Aylık"
}

struct Habit: Identifiable, Codable {
    var id: UUID
    var userId: String
    var title: String
    /// Kullanıcının eklediği açıklama metni (eski kayıtlarda olmayabilir).
    var notes: String?
    var icon: String
    var color: CodableColor
    var streak: Int
    var createdAt: Date?
    var completionDates: [Date] = []
    var frequency: HabitFrequency = .daily
    var scheduledDates: [Date] = [] // Sıklığa göre otomatik eklenen günler
    
    init(title: String, icon: String, color: Color, streak: Int = 0, createdAt: Date? = nil, frequency: HabitFrequency = .daily, notes: String? = nil, userId: String = "") {
        self.id = UUID()
        self.userId = userId
        self.title = title
        self.notes = notes
        self.icon = icon
        self.color = CodableColor(color: color)
        self.streak = streak
        self.createdAt = createdAt ?? Date()
        self.frequency = frequency
        self.scheduledDates = []
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case title
        case notes
        case icon
        case color
        case streak
        case createdAt
        case completionDates
        case frequency
        case scheduledDates
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        userId = try container.decodeIfPresent(String.self, forKey: .userId) ?? ""
        title = try container.decode(String.self, forKey: .title)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        icon = try container.decode(String.self, forKey: .icon)
        color = try container.decode(CodableColor.self, forKey: .color)
        streak = try container.decode(Int.self, forKey: .streak)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        completionDates = try container.decodeIfPresent([Date].self, forKey: .completionDates) ?? []
        frequency = try container.decodeIfPresent(HabitFrequency.self, forKey: .frequency) ?? .daily
        scheduledDates = try container.decodeIfPresent([Date].self, forKey: .scheduledDates) ?? []
    }
    
    var swiftUIColor: Color {
        color.color
    }
    
    // Belirli bir tarihte tamamlanmış mı?
    func isCompleted(on date: Date) -> Bool {
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        
        return completionDates.contains { completionDate in
            calendar.isDate(completionDate, inSameDayAs: normalizedDate)
        }
    }
    
    /// `HabitManager.habitsForDate` ile aynı kurallar: o gün bu alışkanlık takvimde yer alıyor mu.
    func isTracked(on date: Date) -> Bool {
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        let habitStart = calendar.startOfDay(for: createdAt ?? Date())
        guard habitStart <= normalizedDate else { return false }
        if frequency == .daily {
            return calendar.isDate(habitStart, inSameDayAs: normalizedDate)
        }
        return scheduledDates.contains { scheduledDate in
            calendar.isDate(scheduledDate, inSameDayAs: normalizedDate)
        }
    }
}

// Color'ı Codable yapmak için wrapper
struct CodableColor: Codable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double
    
    init(color: Color) {
        #if os(iOS)
        let uiColor = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        if uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) {
            self.red = Double(r)
            self.green = Double(g)
            self.blue = Double(b)
            self.alpha = Double(a)
        } else {
            // Fallback to default color if conversion fails
            self.red = 0.95
            self.green = 0.7
            self.blue = 0.5
            self.alpha = 1.0
        }
        #else
        // For macOS or other platforms
        self.red = 0.95
        self.green = 0.7
        self.blue = 0.5
        self.alpha = 1.0
        #endif
    }
    
    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }
}
