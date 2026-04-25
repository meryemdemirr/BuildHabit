//
//  AddHabitEntryView.swift
//  HabitTracker
//
//  Hazır şablonlar ve "kendi alışkanlığın" girişi — başlıksız liste, kart satırlar.
//

import SwiftUI

struct AddHabitEntryView: View {
    let initialStartDate: Date
    
    private let categoryOrderKeys: [String] = [
        "preset_category_self_care",
        "preset_category_active",
        "preset_category_healthier",
        "preset_category_learn"
    ]
    
    init(initialStartDate: Date = Date()) {
        self.initialStartDate = Calendar.current.startOfDay(for: initialStartDate)
    }
    
    private var groupedPresets: [(categoryKey: String, presets: [PresetHabitTemplate])] {
        categoryOrderKeys.compactMap { key in
            let presets = PresetHabitTemplate.library.filter { $0.categoryKey == key }
            return presets.isEmpty ? nil : (key, presets)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                NavigationLink {
                    AddHabitSheet(
                        entryMode: .custom,
                        initialStartDate: initialStartDate
                    )
                } label: {
                    customAddRow
                }
                .buttonStyle(.plain)

                ForEach(groupedPresets, id: \.categoryKey) { group in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(NSLocalizedString(group.categoryKey, comment: ""))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(.secondaryLabel))
                            .padding(.leading, 2)
                        
                        ForEach(group.presets) { preset in
                            NavigationLink {
                                AddHabitSheet(
                                    entryMode: .preset(preset),
                                    initialStartDate: initialStartDate
                                )
                            } label: {
                                presetRow(preset)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 28)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("add_habit_title")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func presetRow(_ preset: PresetHabitTemplate) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(preset.color.swiftUIColor.opacity(0.22))
                    .frame(width: 44, height: 44)
                Image(systemName: preset.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(preset.color.swiftUIColor)
            }
            
            Text(preset.localizedTitle)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(.label))
                .multilineTextAlignment(.leading)
            
            Spacer(minLength: 8)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color(.tertiaryLabel))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color(.separator).opacity(0.35), lineWidth: 0.5)
        )
    }
    
    private var customAddRow: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(red: 0.95, green: 0.7, blue: 0.5).opacity(0.22))
                    .frame(width: 44, height: 44)
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color(red: 0.95, green: 0.7, blue: 0.5))
            }
            
            Text("add_habit_custom")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(.label))
            
            Spacer(minLength: 8)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color(.tertiaryLabel))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color(.separator).opacity(0.45), lineWidth: 0.5)
        )
    }
}

#Preview {
    NavigationStack {
        AddHabitEntryView()
    }
}
