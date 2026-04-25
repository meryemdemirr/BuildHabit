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
    let category: String
    let title: String
    let icon: String
    let color: PastelColor
    
    var id: String { title }
    
    /// Ana ekranda gösterilen hazır alışkanlıklar (sıralı).
    static let library: [PresetHabitTemplate] = [
        PresetHabitTemplate(category: "Özbakım", title: "Duş al", icon: "shower.fill", color: .blue),
        PresetHabitTemplate(category: "Özbakım", title: "Cilt bakımını yap", icon: "sparkles", color: .pink),
        PresetHabitTemplate(category: "Özbakım", title: "Saç bakımını yap", icon: "heart.fill", color: .purple),
        PresetHabitTemplate(category: "Aktif Ol", title: "Koşuya çık", icon: "figure.run", color: .orange),
        PresetHabitTemplate(category: "Aktif Ol", title: "Yürüyüş yap", icon: "figure.walk", color: .green),
        PresetHabitTemplate(category: "Aktif Ol", title: "Dans et", icon: "music.note", color: .pink),
        PresetHabitTemplate(category: "Aktif Ol", title: "Pilates yap", icon: "figure.cooldown", color: .purple),
        PresetHabitTemplate(category: "Daha Sağlıklı Ol", title: "Su iç", icon: "drop.fill", color: .blue),
        PresetHabitTemplate(category: "Daha Sağlıklı Ol", title: "Meyve ye", icon: "apple.logo", color: .green),
        PresetHabitTemplate(category: "Daha Sağlıklı Ol", title: "Sağlıklı öğün hazırla", icon: "fork.knife", color: .green),
        PresetHabitTemplate(category: "Daha Sağlıklı Ol", title: "Takviye al", icon: "pills.fill", color: .orange),
        PresetHabitTemplate(category: "Daha Sağlıklı Ol", title: "Erken uyu", icon: "bed.double.fill", color: .purple),
        PresetHabitTemplate(category: "Daha Sağlıklı Ol", title: "Erken kalk", icon: "sun.max.fill", color: .yellow),
        PresetHabitTemplate(category: "Öğren", title: "Kitap oku", icon: "book.fill", color: .blue),
        PresetHabitTemplate(category: "Öğren", title: "Ders çalış", icon: "books.vertical.fill", color: .purple),
        PresetHabitTemplate(category: "Öğren", title: "Podcast dinle", icon: "headphones", color: .orange)
    ]
}

enum AddHabitEntryMode: Hashable {
    case custom
    case preset(PresetHabitTemplate)
}
