//
//  SignUpView.swift
//  HabitTracker
//
//  Created by Meryem Demir on 14.02.2026.
//

import SwiftUI

struct SignUpView: View {
    @ObservedObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, email, password, confirmPassword
    }
    
    var passwordsMatch: Bool {
        !password.isEmpty && password == confirmPassword
    }

    var isEmailValid: Bool {
        authManager.isValidEmail(email)
    }
    
    var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty && isEmailValid && !password.isEmpty && passwordsMatch && password.count >= 6
    }
    
    var body: some View {
        ZStack {
            // Sistem arka plan rengi
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(.label))
                                .frame(width: 36, height: 36)
                                .background(
                                    Circle()
                                        .fill(Color(.secondarySystemGroupedBackground))
                                )
                        }
                        
                        Spacer()
                        
                        Text("Kayıt Ol")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(Color(.label))
                        
                        Spacer()
                        
                        // Invisible button for centering
                        Color.clear
                            .frame(width: 36, height: 36)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    
                    // Form
                    VStack(spacing: 20) {
                        // Name Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ad Soyad")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(.label))
                            
                            TextField("Adınız ve soyadınız", text: $name)
                                .textContentType(.name)
                                .font(.system(size: 16, design: .rounded))
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.secondarySystemGroupedBackground))
                                )
                                .focused($focusedField, equals: .name)
                        }
                        
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
                                Text("Geçerli bir e-posta girin (örn. gmail.com, hotmail.com, outlook.com)")
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(Color(red: 1.0, green: 0.3, blue: 0.3))
                            }
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Şifre")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(.label))
                            
                            SecureField("En az 6 karakter", text: $password)
                                .textContentType(.newPassword)
                                .font(.system(size: 16, design: .rounded))
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.secondarySystemGroupedBackground))
                                )
                                .focused($focusedField, equals: .password)
                            
                            if !password.isEmpty && password.count < 6 {
                                Text("Şifre en az 6 karakter olmalıdır")
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(Color(red: 1.0, green: 0.3, blue: 0.3))
                            }
                        }
                        
                        // Confirm Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Şifre Tekrar")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(.label))
                            
                            SecureField("Şifrenizi tekrar girin", text: $confirmPassword)
                                .textContentType(.newPassword)
                                .font(.system(size: 16, design: .rounded))
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.secondarySystemGroupedBackground))
                                )
                                .focused($focusedField, equals: .confirmPassword)
                            
                            if !confirmPassword.isEmpty && !passwordsMatch {
                                Text("Şifreler eşleşmiyor")
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(Color(red: 1.0, green: 0.3, blue: 0.3))
                            }
                        }
                        
                        
                        Button(action: {
                            focusedField = nil
                            authManager.signUp(name: name, email: email, password: password) { success in
                                if success {
                                    dismiss()
                                }
                            }
                        }) {
                            Text("Kayıt Ol")
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
                        .disabled(!isFormValid)
                        .opacity(isFormValid ? 1.0 : 0.6)
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
            }
        }
        .alert("Hata", isPresented: $authManager.showError) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(authManager.errorMessage ?? "Bir hata oluştu")
        }
    }
}

#Preview {
    SignUpView(authManager: AuthManager())
}
