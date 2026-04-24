//
//  LoginView.swift
//  HabitTracker
//
//  Created by Meryem Demir on 14.02.2026.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }

    var isEmailValid: Bool {
        authManager.isValidEmail(email)
    }
    
    var body: some View {
        ZStack {
            // Sistem arka plan rengi
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    Spacer()
                        .frame(height: 60)
                    
                    // Logo/Header
                    VStack(spacing: 16) {
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
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        }
                        
                        Text("HabitTracker")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Color(.label))
                        
                        Text("Alışkanlıklarınızı takip edin")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(Color(.secondaryLabel))
                    }
                    
                    // Form
                    VStack(spacing: 20) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("E-posta")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(.label))
                            
                            TextField("ornek@email.com", text: $email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .font(.system(size: 16, design: .rounded))
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.secondarySystemGroupedBackground))
                                )
                                .focused($focusedField, equals: .email)

                            if !email.isEmpty && !isEmailValid {
                                Text("Geçerli bir e-posta adresi girin")
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(Color(red: 1.0, green: 0.3, blue: 0.3))
                            }
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Şifre")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(.label))
                            
                            SecureField("Şifrenizi girin", text: $password)
                                .textContentType(.password)
                                .font(.system(size: 16, design: .rounded))
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.secondarySystemGroupedBackground))
                                )
                                .focused($focusedField, equals: .password)
                        }
                        
                        // Login Button
                        Button(action: {
                            focusedField = nil
                            authManager.signIn(email: email, password: password) { success in
                                if success {
                                    // Login successful, handled by AuthManager
                                }
                            }
                        }) {
                            Text("Giriş Yap")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(16)
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
                        .disabled(email.isEmpty || !isEmailValid || password.isEmpty)
                        .opacity(email.isEmpty || !isEmailValid || password.isEmpty ? 0.6 : 1.0)
                    }
                    .padding(.horizontal, 24)
                    
                    // Sign Up Link
                    HStack {
                        Text("Hesabınız yok mu?")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(Color(.secondaryLabel))
                        
                        Button(action: {
                            showSignUp = true
                        }) {
                            Text("Kayıt Ol")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0.95, green: 0.7, blue: 0.5))
                        }
                    }
                    .padding(.top, 8)
                    
                    Spacer()
                }
            }
        }
        .alert("Hata", isPresented: $authManager.showError) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(authManager.errorMessage ?? "Bir hata oluştu")
        }
        .fullScreenCover(isPresented: $showSignUp) {
            SignUpView(authManager: authManager)
        }
    }
}

#Preview {
    LoginView(authManager: AuthManager())
}
