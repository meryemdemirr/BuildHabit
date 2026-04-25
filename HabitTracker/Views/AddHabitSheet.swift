//
//  AddHabitSheet.swift
//  HabitTracker
//
//  Created by Meryem Demir on 14.02.2026.
//

import SwiftUI

struct AddHabitSheet: View {
    @EnvironmentObject var habitManager: HabitManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dismissEntireAddFlow) private var dismissEntireAddFlow
    
    @State private var habitTitle: String
    @State private var habitDescription: String
    @State private var selectedColor: PastelColor
    @State private var selectedIcon: String
    @State private var selectedFrequency: HabitFrequency
    @State private var selectedStartDate: Date
    
    init(entryMode: AddHabitEntryMode = .custom, initialStartDate: Date = Date()) {
        let normalizedInitialDate = Calendar.current.startOfDay(for: initialStartDate)
        switch entryMode {
        case .custom:
            _habitTitle = State(initialValue: "")
            _habitDescription = State(initialValue: "")
            _selectedColor = State(initialValue: .blue)
            _selectedIcon = State(initialValue: "book.fill")
            _selectedFrequency = State(initialValue: .daily)
            _selectedStartDate = State(initialValue: normalizedInitialDate)
        case .preset(let template):
            _habitTitle = State(initialValue: template.localizedTitle)
            _habitDescription = State(initialValue: "")
            _selectedColor = State(initialValue: template.color)
            _selectedIcon = State(initialValue: template.icon)
            _selectedFrequency = State(initialValue: .daily)
            _selectedStartDate = State(initialValue: normalizedInitialDate)
        }
    }
    
    /// İkon seçicide gösterilen SF Symbols (şablon ikonları dahil).
    private let availableIcons = [
        "book.fill", "books.vertical.fill", "figure.run", "figure.walk", "leaf.fill",
        "drop.fill", "sun.max.fill", "alarm.fill", "sparkles", "moon.fill",
        "star.fill", "heart.fill", "flame.fill", "cup.and.saucer.fill",
        "pills.fill", "bed.double.fill", "music.note", "figure.cooldown",
        "headphones", "shower.fill", "fork.knife"
    ]
    
    var body: some View {
        ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                Form {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("habit_name_label")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(.label))
                            
                            TextField("habit_name_placeholder", text: $habitTitle)
                                .font(.system(size: 16, design: .rounded))
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.secondarySystemGroupedBackground))
                                )
                        }
                        .padding(.vertical, 8)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("habit_description_label")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(.label))
                            
                            TextEditor(text: $habitDescription)
                                .font(.system(size: 16, design: .rounded))
                                .frame(minHeight: 100)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.secondarySystemGroupedBackground))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.separator), lineWidth: 0.5)
                                )
                        }
                        .padding(.vertical, 8)
                    } header: {
                        Text("add_section_info")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(.secondaryLabel))
                    }
                    
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("color_pick_label")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(.label))
                            
                            HStack(spacing: 16) {
                                ForEach(PastelColor.allCases, id: \.self) { pastelColor in
                                    ColorCircleView(
                                        color: pastelColor.swiftUIColor,
                                        isSelected: selectedColor == pastelColor
                                    ) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedColor = pastelColor
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.vertical, 8)
                    } header: {
                        Text("add_section_appearance")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(.secondaryLabel))
                    }
                    
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("icon_pick_label")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(.label))
                            
                            IconSelectionView(
                                icons: availableIcons,
                                selectedIcon: $selectedIcon,
                                selectedColor: selectedColor.swiftUIColor
                            )
                        }
                        .padding(.vertical, 8)
                    } header: {
                        Text("add_section_icon")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(.secondaryLabel))
                    }
                    
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("start_date_label")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(.label))
                            
                            DatePicker("", selection: $selectedStartDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                        }
                        .padding(.vertical, 8)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("frequency_label")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(.label))
                            
                            Picker("frequency_picker_a11y", selection: $selectedFrequency) {
                                ForEach(HabitFrequency.allCases, id: \.self) { frequency in
                                    Text(frequency.localizedTitle).tag(frequency)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(.vertical, 8)
                    } header: {
                        Text("add_section_calendar")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(.secondaryLabel))
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color(.systemGroupedBackground))
        }
        .navigationTitle("add_habit_title")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color(.label))
                    }
                    .accessibilityLabel("toolbar_back_a11y")
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("save") {
                        saveHabit()
                    }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(
                        habitTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                        Color(.secondaryLabel) :
                            selectedColor.swiftUIColor
                    )
                    .disabled(habitTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
        }
    }
    
    private func saveHabit() {
        let title = habitTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: selectedStartDate)
        
        let trimmedDescription = habitDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        var newHabit = Habit(
            title: title,
            icon: selectedIcon,
            color: selectedColor.swiftUIColor,
            streak: 0,
            createdAt: startDate,
            frequency: selectedFrequency,
            notes: trimmedDescription.isEmpty ? nil : trimmedDescription
        )
        
        var scheduledDates: [Date] = []
        
        switch selectedFrequency {
        case .none:
            break
        case .daily:
            scheduledDates.append(startDate)
        case .weekly:
            for i in 0..<7 {
                if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                    scheduledDates.append(date)
                }
            }
        case .monthly:
            for i in 0..<30 {
                if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                    scheduledDates.append(date)
                }
            }
        }
        
        newHabit.scheduledDates = scheduledDates
        
        withAnimation {
            habitManager.addHabit(newHabit)
        }
        
        dismissEntireAddFlow()
    }
}

#Preview("Özel") {
    NavigationStack {
        AddHabitSheet(entryMode: .custom)
    }
    .environmentObject(HabitManager())
}

#Preview("Şablon") {
    NavigationStack {
        AddHabitSheet(entryMode: .preset(PresetHabitTemplate.library[0]))
    }
    .environmentObject(HabitManager())
}
