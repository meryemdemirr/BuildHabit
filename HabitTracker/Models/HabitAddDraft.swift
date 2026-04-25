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
    let id: String
    let categoryKey: String
    let titleKey: String
    let icon: String
    let color: PastelColor

    var localizedTitle: String {
        NSLocalizedString(titleKey, comment: "")
    }

    var localizedCategory: String {
        NSLocalizedString(categoryKey, comment: "")
    }
    
    /// Ana ekranda gösterilen hazır alışkanlıklar (sıralı).
    static let library: [PresetHabitTemplate] = [
        PresetHabitTemplate(id: "shower", categoryKey: "preset_category_self_care", titleKey: "preset_title_shower", icon: "shower.fill", color: .blue),
        PresetHabitTemplate(id: "skincare", categoryKey: "preset_category_self_care", titleKey: "preset_title_skincare", icon: "sparkles", color: .pink),
        PresetHabitTemplate(id: "haircare", categoryKey: "preset_category_self_care", titleKey: "preset_title_haircare", icon: "heart.fill", color: .purple),
        PresetHabitTemplate(id: "run", categoryKey: "preset_category_active", titleKey: "preset_title_run", icon: "figure.run", color: .orange),
        PresetHabitTemplate(id: "walk", categoryKey: "preset_category_active", titleKey: "preset_title_walk", icon: "figure.walk", color: .green),
        PresetHabitTemplate(id: "dance", categoryKey: "preset_category_active", titleKey: "preset_title_dance", icon: "music.note", color: .pink),
        PresetHabitTemplate(id: "pilates", categoryKey: "preset_category_active", titleKey: "preset_title_pilates", icon: "figure.cooldown", color: .purple),
        PresetHabitTemplate(id: "water", categoryKey: "preset_category_healthier", titleKey: "preset_title_water", icon: "drop.fill", color: .blue),
        PresetHabitTemplate(id: "fruit", categoryKey: "preset_category_healthier", titleKey: "preset_title_fruit", icon: "apple.logo", color: .green),
        PresetHabitTemplate(id: "meal", categoryKey: "preset_category_healthier", titleKey: "preset_title_healthy_meal", icon: "fork.knife", color: .green),
        PresetHabitTemplate(id: "supplements", categoryKey: "preset_category_healthier", titleKey: "preset_title_supplements", icon: "pills.fill", color: .orange),
        PresetHabitTemplate(id: "sleep", categoryKey: "preset_category_healthier", titleKey: "preset_title_sleep_early", icon: "bed.double.fill", color: .purple),
        PresetHabitTemplate(id: "wake", categoryKey: "preset_category_healthier", titleKey: "preset_title_wake_early", icon: "sun.max.fill", color: .yellow),
        PresetHabitTemplate(id: "read", categoryKey: "preset_category_learn", titleKey: "preset_title_read_book", icon: "book.fill", color: .blue),
        PresetHabitTemplate(id: "study", categoryKey: "preset_category_learn", titleKey: "preset_title_study", icon: "books.vertical.fill", color: .purple),
        PresetHabitTemplate(id: "podcast", categoryKey: "preset_category_learn", titleKey: "preset_title_podcast", icon: "headphones", color: .orange)
    ]
}

enum AddHabitEntryMode: Hashable {
    case custom
    case preset(PresetHabitTemplate)
}
