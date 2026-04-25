//
//  HomeView.swift
//  HabitTracker
//
//  Created by Meryem Demir on 14.02.2026.
//

import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: Int
    @Binding var openedFromHome: Bool
    @Binding var selectedDate: Date
    
    @EnvironmentObject var habitManager: HabitManager
    @State private var showAddHabitSheet = false
    @State private var selectedHabit: Habit?
    @State private var showDetail = false
    @State private var habitPendingDelete: Habit?
    @State private var showDeleteConfirmation = false
    @State private var showCalendarSheet = false
    @State private var showDateRestrictionToast = false
    
    private var filteredHabits: [Habit] {
        habitManager.habitsForDate(selectedDate)
    }

    private var isPastSelectedDate: Bool {
        Calendar.current.startOfDay(for: selectedDate) < Calendar.current.startOfDay(for: Date())
    }

    private var isSelectedDateToday: Bool {
        Calendar.current.isDate(Calendar.current.startOfDay(for: selectedDate), inSameDayAs: Calendar.current.startOfDay(for: Date()))
    }
    
    var totalHabits: Int {
        filteredHabits.count
    }
    
    var activeStreak: Int {
        filteredHabits.map { $0.streak }.max() ?? 0
    }
    
    private var habitsSectionHeader: some View {
        HStack {
            Text("Alışkanlıklarım")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Color(.label))
            
            Spacer()
            
            Button(action: {
                showAddHabitSheet = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isPastSelectedDate ? Color(.systemGray2) : Color(red: 0.95, green: 0.7, blue: 0.5))
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(isPastSelectedDate ? Color(.systemGray5) : Color(red: 0.95, green: 0.7, blue: 0.5).paleBackground)
                    )
            }
            .disabled(isPastSelectedDate)
        }
        .padding(.horizontal, 20)
        .textCase(nil)
    }
    
    var body: some View {
        ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                List {
                    Section {
                        VStack(spacing: 24) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Merhaba,")
                                        .font(.system(size: 28, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(.label))
                                    
                                    Text("Bugün nasıl gidiyor?")
                                        .font(.system(size: 16, weight: .regular, design: .rounded))
                                        .foregroundColor(Color(.secondaryLabel))
                                }
                                
                                Spacer()

                                Button {
                                    showCalendarSheet = true
                                } label: {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(Color(.label))
                                        .frame(width: 40, height: 40)
                                        .background(
                                            Circle()
                                                .fill(Color(.secondarySystemGroupedBackground))
                                        )
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Takvimden tarih seç")
                                
                                Button {
                                    openedFromHome = true
                                    selectedTab = 2
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color(red: 0.95, green: 0.7, blue: 0.5),
                                                        Color(red: 0.95, green: 0.5, blue: 0.7)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 48, height: 48)
                                        
                                        Image(systemName: "person.crop.circle.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 22, weight: .medium))
                                    }
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Ayarları aç")
                            }
                            .padding(.top, 12)
                            
                            HStack(spacing: 16) {
                                SummaryCard(
                                    title: "Toplam Alışkanlık",
                                    value: "\(totalHabits)",
                                    icon: "checkmark.circle.fill",
                                    color: Color(red: 0.6, green: 0.8, blue: 1.0)
                                )
                                
                                SummaryCard(
                                    title: "Aktif Seri",
                                    value: "\(activeStreak)",
                                    icon: "flame.fill",
                                    color: Color(red: 1.0, green: 0.6, blue: 0.4)
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 4)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    
                    Section {
                        WeeklyCalendarView(selectedDate: $selectedDate)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 4)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    
                    if filteredHabits.isEmpty {
                        Section {
                            VStack(spacing: 16) {
                                Image(systemName: "tray")
                                    .font(.system(size: 48))
                                    .foregroundColor(Color(.tertiaryLabel))
                                
                                Text("Bu tarihte alışkanlık yok")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(.secondaryLabel))
                                
                                if !isPastSelectedDate {
                                    Button(action: {
                                        showAddHabitSheet = true
                                    }) {
                                        Text("İlk alışkanlığını ekle")
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 24)
                                            .padding(.vertical, 12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(
                                                        LinearGradient(
                                                            colors: [
                                                                Color(red: 0.95, green: 0.7, blue: 0.5),
                                                                Color(red: 0.95, green: 0.5, blue: 0.7)
                                                            ],
                                                            startPoint: .leading,
                                                            endPoint: .trailing
                                                        )
                                                    )
                                            )
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } header: {
                            habitsSectionHeader
                        }
                        .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    } else {
                        Section {
                            ForEach(filteredHabits) { habit in
                                HabitCard(
                                    habit: habit,
                                    selectedDate: selectedDate,
                                    isInteractionEnabled: isSelectedDateToday,
                                    onCompletionToggle: {
                                        _ = habitManager.toggleCompletion(for: habit, on: selectedDate)
                                    },
                                    onDisabledCompletionTap: {
                                        showDateRestrictionFeedback()
                                    },
                                    onDetailTap: {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) {
                                            selectedHabit = habit
                                            showDetail = true
                                        }
                                    }
                                )
                                .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        habitPendingDelete = habit
                                        showDeleteConfirmation = true
                                    } label: {
                                        Label("Sil", systemImage: "trash")
                                    }
                                }
                            }
                        } header: {
                            habitsSectionHeader
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                
                if showDetail, let habit = selectedHabit {
                    HabitDetailOverlay(habit: habit) {
                        showDetail = false
                        selectedHabit = nil
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }

                if showDateRestrictionToast {
                    VStack {
                        Spacer()
                        Text("Yalnızca bugünün alışkanlıklarını değiştirebilirsin")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(Color.black.opacity(0.78))
                            )
                            .padding(.bottom, 24)
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .zIndex(2)
                }
            }
            .animation(.easeOut(duration: 0.2), value: showDetail)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showAddHabitSheet) {
                NavigationStack {
                    AddHabitEntryView(initialStartDate: selectedDate)
                }
                .environmentObject(habitManager)
                .environment(\.dismissEntireAddFlow) {
                    showAddHabitSheet = false
                }
            }
            .sheet(isPresented: $showCalendarSheet) {
                CalendarShortcutSheet(selectedDate: $selectedDate)
            }
            .alert("Alışkanlığı sil", isPresented: $showDeleteConfirmation) {
                Button("İptal", role: .cancel) {
                    habitPendingDelete = nil
                }
                Button("Sil", role: .destructive) {
                    performDeletePendingHabit()
                }
            } message: {
                Text("Bu alışkanlığı silmek istediğine emin misin?")
            }
    }
    
    private func performDeletePendingHabit() {
        guard let habit = habitPendingDelete else { return }
        if selectedHabit?.id == habit.id {
            showDetail = false
            selectedHabit = nil
        }
        habitManager.deleteHabit(habit)
        habitPendingDelete = nil
    }

    private func showDateRestrictionFeedback() {
        withAnimation(.easeInOut(duration: 0.2)) {
            showDateRestrictionToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeInOut(duration: 0.2)) {
                showDateRestrictionToast = false
            }
        }
    }
}

private struct CalendarShortcutSheet: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    @State private var pickerDate: Date

    init(selectedDate: Binding<Date>) {
        _selectedDate = selectedDate
        _pickerDate = State(initialValue: Calendar.current.startOfDay(for: selectedDate.wrappedValue))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                DatePicker(
                    "Tarih Seç",
                    selection: $pickerDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.secondarySystemGroupedBackground))
                )

                Text("Bir gün seçtiğinde ana ekrana dönülür.")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(Color(.secondaryLabel))
            }
            .padding(20)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Takvim")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: pickerDate) { _, newDate in
                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                    selectedDate = Calendar.current.startOfDay(for: newDate)
                }
                dismiss()
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    @Previewable @State var selectedTab = 0
    @Previewable @State var openedFromHome = false
    @Previewable @State var selectedDate = Date()
    
    NavigationStack {
        HomeView(selectedTab: $selectedTab, openedFromHome: $openedFromHome, selectedDate: $selectedDate)
            .environmentObject(HabitManager())
    }
}
