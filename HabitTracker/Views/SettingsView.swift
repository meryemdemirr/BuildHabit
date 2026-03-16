//
//  SettingsView.swift
//  HabitTracker
//
//  Created by Meryem Demir on 14.02.2026.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showProfile = false
    @State private var showSignOutAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Sistem arka plan rengi
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                List {
                    // Profil Bölümü
                    Section {
                        HStack(spacing: 16) {
                            // Profil Avatar - Kullanıcı baş harfleri
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
                                    .frame(width: 60, height: 60)
                                
                                Text(authManager.userInitials)
                                    .foregroundColor(.white)
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(authManager.displayName)
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(.label))
                                
                                Text(authManager.userEmail)
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundColor(Color(.secondaryLabel))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(.tertiaryLabel))
                        }
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showProfile = true
                        }
                    } header: {
                        Text("Profil")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(.secondaryLabel))
                    }
                    
                    // Uygulama Ayarları
                    Section {
                        SettingsRow(
                            icon: "bell.fill",
                            iconColor: Color(red: 1.0, green: 0.6, blue: 0.4),
                            title: "Bildirimler",
                            subtitle: "Hatırlatmaları yönet"
                        )
                        
                        // Tema Seçici
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(red: 0.5, green: 0.5, blue: 1.0).paleBackground)
                                        .frame(width: 36, height: 36)
                                    
                                    Image(systemName: "moon.fill")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 1.0))
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Tema")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(Color(.label))
                                    
                                    Text("Görünüm tercihinizi seçin")
                                        .font(.system(size: 13, weight: .regular, design: .rounded))
                                        .foregroundColor(Color(.secondaryLabel))
                                }
                                
                                Spacer()
                            }
                            
                            Picker("Tema", selection: $themeManager.selectedTheme) {
                                ForEach(AppTheme.allCases, id: \.self) { theme in
                                    Text(theme.rawValue).tag(theme)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.top, 8)
                        }
                        .padding(.vertical, 4)
                        
                        SettingsRow(
                            icon: "chart.bar.fill",
                            iconColor: Color(red: 0.5, green: 0.9, blue: 0.6),
                            title: "Veri Yönetimi",
                            subtitle: "Yedekleme ve geri yükleme"
                        )
                    } header: {
                        Text("Ayarlar")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(.secondaryLabel))
                    }
                    
                    // Hakkında
                    Section {
                        SettingsRow(
                            icon: "info.circle.fill",
                            iconColor: Color(red: 0.6, green: 0.8, blue: 1.0),
                            title: "Uygulama Hakkında",
                            subtitle: "Sürüm 1.0"
                        )
                        
                        SettingsRow(
                            icon: "star.fill",
                            iconColor: Color(red: 1.0, green: 0.9, blue: 0.4),
                            title: "Uygulamayı Değerlendir",
                            subtitle: "App Store'da puan ver"
                        )
                    } header: {
                        Text("Hakkında")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(.secondaryLabel))
                    }
                    
                    // Çıkış Yap
                    Section {
                        Button(action: {
                            showSignOutAlert = true
                        }) {
                            HStack {
                                Spacer()
                                Text("Çıkış Yap")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(red: 1.0, green: 0.3, blue: 0.3))
                                Spacer()
                            }
                        }
                    }
                    
                    // Onboarding (Test için)
                    Section {
                        Button(action: {
                            // Onboarding'i sıfırla
                            appState.isOnboardingComplete = false
                            UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                        }) {
                            HStack {
                                Spacer()
                                Text("Onboarding'i Tekrar Göster")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(.secondaryLabel))
                                Spacer()
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showProfile) {
                ProfileView()
                    .environmentObject(authManager)
            }
            .alert("Çıkış Yap", isPresented: $showSignOutAlert) {
                Button("İptal", role: .cancel) { }
                Button("Çıkış Yap", role: .destructive) {
                    authManager.signOut()
                }
            } message: {
                Text("Hesabınızdan çıkmak istediğinize emin misiniz?")
            }
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(iconColor.paleBackground)
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color(.label))
                
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(Color(.secondaryLabel))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(.tertiaryLabel))
        }
        .padding(.vertical, 4)
    }
}

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Profil Avatar - Kullanıcı baş harfleri
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
                            .frame(width: 120, height: 120)
                        
                        Text(authManager.userInitials)
                            .foregroundColor(.white)
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                    }
                    .padding(.top, 40)
                    
                    VStack(spacing: 8) {
                        Text(authManager.displayName)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(Color(.label))
                        
                        Text(authManager.userEmail)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(Color(.secondaryLabel))
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundColor(Color(.label))
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppStateManager())
        .environmentObject(AuthManager())
        .environmentObject(ThemeManager())
}
