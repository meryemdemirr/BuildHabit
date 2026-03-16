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
    
    // Sign Up
    func signUp(name: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
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
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
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
