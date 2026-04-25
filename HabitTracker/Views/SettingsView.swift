//
//  SettingsView.swift
//  HabitTracker
//
//  Created by Meryem Demir on 14.02.2026.
//

import SwiftUI

struct SettingsView: View {
    @Binding var selectedTab: Int
    @Binding var openedFromHome: Bool
    
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showProfile = false
    @State private var showSignOutAlert = false
    
    var body: some View {
        ZStack {
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
                        Text("settings_section_profile")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(.secondaryLabel))
                    }
                    
                    // Uygulama Ayarları
                    Section {
                        NavigationLink {
                            NotificationsView()
                        } label: {
                            SettingsRow(
                                icon: "bell.fill",
                                iconColor: Color(red: 1.0, green: 0.6, blue: 0.4),
                                title: NSLocalizedString("notifications", comment: ""),
                                subtitle: NSLocalizedString("settings_notifications_subtitle", comment: ""),
                                showsDisclosure: false
                            )
                        }
                        .buttonStyle(.plain)
                        
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
                                    Text("settings_theme")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(Color(.label))
                                    
                                    Text("settings_theme_subtitle")
                                        .font(.system(size: 13, weight: .regular, design: .rounded))
                                        .foregroundColor(Color(.secondaryLabel))
                                }
                                
                                Spacer()
                            }
                            
                            Picker("settings_theme_picker_a11y", selection: $themeManager.selectedTheme) {
                                ForEach(AppTheme.allCases, id: \.self) { theme in
                                    Text(theme.localizedTitle).tag(theme)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.top, 8)
                        }
                        .padding(.vertical, 4)
                        
                        NavigationLink {
                            DataManagementView()
                        } label: {
                            SettingsRow(
                                icon: "chart.bar.fill",
                                iconColor: Color(red: 0.5, green: 0.9, blue: 0.6),
                                title: NSLocalizedString("settings_data", comment: ""),
                                subtitle: NSLocalizedString("settings_data_subtitle", comment: ""),
                                showsDisclosure: false
                            )
                        }
                        .buttonStyle(.plain)
                    } header: {
                        Text("settings_section_settings")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(.secondaryLabel))
                    }
                    
                    // Hakkında
                    Section {
                        SettingsRow(
                            icon: "info.circle.fill",
                            iconColor: Color(red: 0.6, green: 0.8, blue: 1.0),
                            title: NSLocalizedString("settings_about_app", comment: ""),
                            subtitle: NSLocalizedString("settings_version_subtitle", comment: ""),
                            showsDisclosure: false
                        )
                    } header: {
                        Text("settings_section_about")
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
                                Text("settings_sign_out")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(red: 1.0, green: 0.3, blue: 0.3))
                                Spacer()
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
        }
        .navigationTitle("settings")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if openedFromHome {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        selectedTab = 0
                        openedFromHome = false
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 17, weight: .semibold))
                            Text("settings_home")
                                .font(.system(size: 17, weight: .regular))
                        }
                        .foregroundStyle(Color(.label))
                    }
                    .accessibilityLabel("settings_back_to_home_a11y")
                }
            }
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
                .environmentObject(authManager)
        }
        .alert("settings_sign_out_title", isPresented: $showSignOutAlert) {
            Button("cancel", role: .cancel) { }
            Button("settings_sign_out", role: .destructive) {
                authManager.signOut()
            }
        } message: {
            Text("settings_sign_out_message")
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    /// `NavigationLink` kendi okunu gösterir; `false` yaparak çift ok önlenir.
    var showsDisclosure: Bool = true
    
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
            
            Spacer(minLength: 0)
            
            if showsDisclosure {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(.tertiaryLabel))
            }
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
            .navigationTitle("profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("close") {
                        dismiss()
                    }
                    .foregroundColor(Color(.label))
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedTab = 2
    @Previewable @State var openedFromHome = true
    
    NavigationStack {
        SettingsView(selectedTab: $selectedTab, openedFromHome: $openedFromHome)
            .environmentObject(AuthManager())
            .environmentObject(ThemeManager())
            .environmentObject(HabitManager())
            .environmentObject(NotificationManager())
    }
}
