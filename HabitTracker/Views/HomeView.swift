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
    
    @EnvironmentObject var habitManager: HabitManager
    @State private var showAddHabitSheet = false
    @State private var selectedDate = Date()
    @State private var selectedHabit: Habit?
    @State private var showDetail = false
    @State private var habitPendingDelete: Habit?
    @State private var showDeleteConfirmation = false
    
    private var isPastDate: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selected = calendar.startOfDay(for: selectedDate)
        return selected < today
    }
    
    private var filteredHabits: [Habit] {
        habitManager.habitsForDate(selectedDate)
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
                    .foregroundColor(
                        isPastDate ?
                        Color(.tertiaryLabel) :
                        Color(red: 0.95, green: 0.7, blue: 0.5)
                    )
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(
                                isPastDate ?
                                Color(.systemGray5) :
                                Color(red: 0.95, green: 0.7, blue: 0.5).paleBackground
                            )
                    )
            }
            .disabled(isPastDate)
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
                                .accessibilityLabel("Open settings")
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
                                
                                Text(isPastDate ? "Bu tarihte alışkanlık yok" : "Henüz alışkanlık eklenmedi")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(.secondaryLabel))
                                
                                if !isPastDate {
                                    Button(action: {
                                        showAddHabitSheet = true
                                    }) {
                                        Text("İlk Alışkanlığını Ekle")
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
                                    onCompletionToggle: {
                                        _ = habitManager.toggleCompletion(for: habit, on: selectedDate)
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
                .padding(.bottom, 88)
                
                if showDetail, let habit = selectedHabit {
                    HabitDetailOverlay(habit: habit) {
                        showDetail = false
                        selectedHabit = nil
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
            .animation(.easeOut(duration: 0.2), value: showDetail)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showAddHabitSheet) {
                AddHabitSheet()
                    .environmentObject(habitManager)
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
}

#Preview {
    @Previewable @State var selectedTab = 0
    @Previewable @State var openedFromHome = false
    
    NavigationStack {
        HomeView(selectedTab: $selectedTab, openedFromHome: $openedFromHome)
            .environmentObject(HabitManager())
    }
}
