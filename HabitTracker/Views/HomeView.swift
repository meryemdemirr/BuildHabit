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
    
    private var isPastDate: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selected = calendar.startOfDay(for: selectedDate)
        return selected < today
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
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
    
    var body: some View {
        ZStack {
                // Sistem arka plan rengi (Light/Dark mode uyumlu)
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Section
                        VStack(spacing: 0) {
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
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 24)
                            
                            // Summary Cards
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
                            .padding(.horizontal, 20)
                        }
                        
                        // Weekly Calendar
                        WeeklyCalendarView(selectedDate: $selectedDate)
                            .padding(.top, 8)
                        
                        // Habits Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Alışkanlıklarım")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(.label))
                                
                                Spacer()
                                
                                // Yeni alışkanlık ekle butonu - geçmiş günlerde devre dışı
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
                            
                            if filteredHabits.isEmpty {
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
                                .padding(.vertical, 60)
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(filteredHabits) { habit in
                                        HabitCard(
                                            habit: habit,
                                            selectedDate: selectedDate,
                                            onTap: {
                                                if let updatedHabit = habitManager.toggleCompletion(for: habit, on: selectedDate) {
                                                    // Habit güncellendi
                                                }
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(.bottom, 100)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showAddHabitSheet) {
                AddHabitSheet()
                    .environmentObject(habitManager)
            }
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
