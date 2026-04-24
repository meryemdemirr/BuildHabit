//
//  AuthManager.swift
//  HabitTracker
//
//  Created by Meryem Demir on 14.02.2026.
//

import Foundation
import FirebaseAuth
import SwiftUI

class AuthManager: ObservableObject {
    @Published var user: FirebaseAuth.User?
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    init() {
        // Firebase Auth state listener
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user
                self?.isAuthenticated = user != nil
            }
        }
    }
    
    private let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"

    func isValidEmail(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        let lowered = trimmed.lowercased()
        guard NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: lowered) else { return false }

        let commonDomains = ["gmail", "hotmail", "outlook"]
        if let atIndex = lowered.firstIndex(of: "@") {
            let domain = String(lowered[lowered.index(after: atIndex)...])
            for provider in commonDomains where domain.hasPrefix("\(provider).") {
                return domain == "\(provider).com"
            }
        }

        return true
    }

    // Sign Up
    func signUp(name: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard isValidEmail(normalizedEmail) else {
            DispatchQueue.main.async {
                self.errorMessage = "Geçerli bir e-posta adresi girin (ör. adiniz@gmail.com)."
                self.showError = true
                completion(false)
            }
            return
        }

        Auth.auth().createUser(withEmail: normalizedEmail, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                    completion(false)
                    return
                }
                
                // Update user profile with display name
                if let user = result?.user {
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = name
                    changeRequest.commitChanges { error in
                        if let error = error {
                            print("Error updating profile: \(error.localizedDescription)")
                        }
                    }
                }
                
                self?.errorMessage = nil
                completion(true)
            }
        }
    }
    
    // Sign In
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard isValidEmail(normalizedEmail) else {
            DispatchQueue.main.async {
                self.errorMessage = "Geçerli bir e-posta adresi girin."
                self.showError = true
                completion(false)
            }
            return
        }

        Auth.auth().signIn(withEmail: normalizedEmail, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                    completion(false)
                    return
                }
                
                self?.errorMessage = nil
                completion(true)
            }
        }
    }
    
    // Sign Out
    func signOut() {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
            user = nil
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    // Get user display name
    var displayName: String {
        user?.displayName ?? "Kullanıcı"
    }
    
    // Get user email
    var userEmail: String {
        user?.email ?? ""
    }
    
    // Get user initials for avatar
    var userInitials: String {
        if let name = user?.displayName, !name.isEmpty {
            let components = name.components(separatedBy: " ")
            if components.count >= 2 {
                let first = String(components[0].prefix(1))
                let second = String(components[1].prefix(1))
                return (first + second).uppercased()
            } else if let first = components.first, !first.isEmpty {
                return String(first.prefix(1)).uppercased()
            }
        }
        return "K"
    }
}
