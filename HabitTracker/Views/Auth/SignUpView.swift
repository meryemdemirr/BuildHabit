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
                        
                        Text("auth_sign_up")
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
                            Text("auth_name")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(.label))
                            
                            TextField("auth_name_placeholder", text: $name)
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
                            Text("auth_email")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(.label))
                            
                            TextField("auth_email_placeholder", text: $email)
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
                                Text("auth_invalid_email_signup")
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(Color(red: 1.0, green: 0.3, blue: 0.3))
                            }
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("auth_password")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(.label))
                            
                            SecureField("auth_password_new_placeholder", text: $password)
                                .textContentType(.newPassword)
                                .font(.system(size: 16, design: .rounded))
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.secondarySystemGroupedBackground))
                                )
                                .focused($focusedField, equals: .password)
                            
                            if !password.isEmpty && password.count < 6 {
                                Text("auth_password_min_length")
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(Color(red: 1.0, green: 0.3, blue: 0.3))
                            }
                        }
                        
                        // Confirm Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("auth_confirm_password_label")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(.label))
                            
                            SecureField("auth_confirm_password_placeholder", text: $confirmPassword)
                                .textContentType(.newPassword)
                                .font(.system(size: 16, design: .rounded))
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.secondarySystemGroupedBackground))
                                )
                                .focused($focusedField, equals: .confirmPassword)
                            
                            if !confirmPassword.isEmpty && !passwordsMatch {
                                Text("auth_password_mismatch")
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
                            Text("auth_sign_up")
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
        .alert("error", isPresented: $authManager.showError) {
            Button("ok", role: .cancel) { }
        } message: {
            Text(authManager.errorMessage ?? NSLocalizedString("auth_error_generic", comment: ""))
        }
    }
}

#Preview {
    SignUpView(authManager: AuthManager())
}
