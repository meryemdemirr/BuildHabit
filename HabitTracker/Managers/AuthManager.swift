//
//  AuthManager.swift
//  HabitTracker
//
//  Created by Meryem Demir on 14.02.2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

/// Firestore'da kullanıcı profil dokümanı (`users/{uid}`) oluşturma/ensure işlemleri.
/// Not: Bu sınıfı ayrı dosya yerine bu dosyaya almak, Xcode projesine otomatik
/// eklenmeyen yeni dosya yüzünden çıkabilecek derleme hatalarını önler.
final class FirestoreUserService {
    private let db: Firestore

    init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }

    /// `users/{uid}` dokümanı yoksa oluşturur.
    /// İdempotent: doküman zaten varsa tekrar yazmaz (createdAt güncellenmez).
    func createUserDocumentIfNeeded(userId uid: String, email: String?) async throws {
        let ref = db.collection("users").document(uid)
        let snapshot = try await ref.getDocument()
        guard !snapshot.exists else { return }

        try await ref.setData(
            [
                "userId": uid,
                "email": email ?? "",
                "createdAt": FieldValue.serverTimestamp()
            ],
            merge: false
        )
    }
}

class AuthManager: ObservableObject {
    @Published var user: FirebaseAuth.User?
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var showError = false

    private static let onboardingDidCompleteNotification = Notification.Name("com.habittracker.onboardingDidComplete")

    private let onboardingKey = "hasSeenOnboarding"
    private let userService = FirestoreUserService()
    
    init() {
        // Firebase Auth state listener
        _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
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
                self.errorMessage = NSLocalizedString("auth_error_invalid_email_signup", comment: "")
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
                UserDefaults.standard.set(true, forKey: self?.onboardingKey ?? "hasSeenOnboarding")
                NotificationCenter.default.post(name: Self.onboardingDidCompleteNotification, object: nil)
                
                // Ensure Firestore user profile exists.
                if let uid = result?.user.uid {
                    Task { [weak self] in
                        guard let self else {
                            await MainActor.run { completion(false) }
                            return
                        }
                        do {
                            try await self.userService.createUserDocumentIfNeeded(userId: uid, email: result?.user.email)
                            await MainActor.run { completion(true) }
                        } catch {
                            await MainActor.run {
                                self.errorMessage = error.localizedDescription
                                self.showError = true
                                completion(false)
                            }
                        }
                    }
                } else {
                    completion(true)
                }
            }
        }
    }
    
    // Sign In
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard isValidEmail(normalizedEmail) else {
            DispatchQueue.main.async {
                self.errorMessage = NSLocalizedString("auth_error_invalid_email_signin", comment: "")
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
                UserDefaults.standard.set(true, forKey: self?.onboardingKey ?? "hasSeenOnboarding")
                NotificationCenter.default.post(name: Self.onboardingDidCompleteNotification, object: nil)
                
                // Ensure Firestore user profile exists.
                if let uid = result?.user.uid {
                    Task { [weak self] in
                        guard let self else {
                            await MainActor.run { completion(false) }
                            return
                        }
                        do {
                            try await self.userService.createUserDocumentIfNeeded(userId: uid, email: result?.user.email)
                            await MainActor.run { completion(true) }
                        } catch {
                            await MainActor.run {
                                self.errorMessage = error.localizedDescription
                                self.showError = true
                                completion(false)
                            }
                        }
                    }
                } else {
                    completion(true)
                }
            }
        }
    }
    
    // Sign Out
    func signOut() {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.set(false, forKey: onboardingKey)
            isAuthenticated = false
            user = nil
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    // Delete account and associated cloud data
    func deleteAccount(completion: @escaping (Bool) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }

        let userId = currentUser.uid
        UserDefaults.standard.set(false, forKey: onboardingKey)
        isAuthenticated = false
        user = nil
        errorMessage = nil
        completion(true)

        Task {
            do {
                try await deleteFirestoreData(for: userId)
            } catch {
                // Firestore cleanup should not block account deletion.
                print("Firestore cleanup failed during account deletion: \(error.localizedDescription)")
            }

            do {
                try await currentUser.delete()
            } catch {
                await MainActor.run {
                    errorMessage = localizedDeleteAccountError(from: error)
                    showError = true
                }
            }
        }
    }

    private func deleteFirestoreData(for userId: String) async throws {
        let db = Firestore.firestore()

        // Common document-based profile location
        try await db.collection("users").document(userId).delete()

        // Common user-scoped data collection for habits
        let habitsSnapshot = try await db.collection("habits")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()

        if !habitsSnapshot.documents.isEmpty {
            let batch = db.batch()
            habitsSnapshot.documents.forEach { batch.deleteDocument($0.reference) }
            try await batch.commit()
        }
    }

    private func localizedDeleteAccountError(from error: Error) -> String {
        if let authError = error as NSError?,
           authError.domain == AuthErrorDomain,
           authError.code == AuthErrorCode.requiresRecentLogin.rawValue {
            return NSLocalizedString("settings_delete_account_requires_recent_login", comment: "")
        }
        return NSLocalizedString("settings_delete_account_error_generic", comment: "")
    }
    
    // Get user display name
    var displayName: String {
        user?.displayName ?? NSLocalizedString("user_display_fallback", comment: "")
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
        return NSLocalizedString("user_initial_fallback", comment: "")
    }
}
