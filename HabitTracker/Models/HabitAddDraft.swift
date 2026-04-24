//
//  HabitAddDraft.swift
//  HabitTracker
//
//  Hazır şablon ve pastel renk — alışkanlık ekleme akışı için.
//

import SwiftUI

enum PastelColor: String, CaseIterable {
    case blue = "Pastel Mavi"
    case green = "Pastel Yeşil"
    case pink = "Pastel Pembe"
    case yellow = "Pastel Sarı"
    case purple = "Pastel Mor"
    case orange = "Pastel Turuncu"
    
    var swiftUIColor: Color {
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

struct PresetHabitTemplate: Identifiable, Hashable {
    let title: String
    let icon: String
    let color: PastelColor
    
    var id: String { title }
    
    /// Ana ekranda gösterilen hazır alışkanlıklar (sıralı).
    static let library: [PresetHabitTemplate] = [
        PresetHabitTemplate(title: "Kitap Oku", icon: "book.fill", color: .blue),
        PresetHabitTemplate(title: "Yürüyüşe Çık", icon: "figure.walk", color: .green),
        PresetHabitTemplate(title: "Spor Yap", icon: "figure.run", color: .orange),
        PresetHabitTemplate(title: "Su İç", icon: "drop.fill", color: .blue),
        PresetHabitTemplate(title: "Erken Uyan", icon: "sun.max.fill", color: .yellow),
        PresetHabitTemplate(title: "Kişisel Bakım", icon: "sparkles", color: .pink),
        PresetHabitTemplate(title: "Meditasyon Yap", icon: "leaf.fill", color: .purple),
        PresetHabitTemplate(title: "Ders Çalış", icon: "books.vertical.fill", color: .purple)
    ]
}

enum AddHabitEntryMode: Hashable {
    case custom
    case preset(PresetHabitTemplate)
}
