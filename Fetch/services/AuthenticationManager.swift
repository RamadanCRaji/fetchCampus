//
//  AuthenticationManager.swift
//  Fetch
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isEmailVerified = true
    @Published var userEmail: String?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    init() {
        setupAuthListener()
    }
    
    // Listen for auth state changes
    func setupAuthListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.isAuthenticated = user != nil && user?.isEmailVerified == true
                if let user = user, user.isEmailVerified {
                    await self?.fetchUserData(userId: user.uid)
                }
            }
        }
    }
    
    // MARK: - Sign Up
    func signUp(email: String, password: String, userData: [String: Any]) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            // Create auth user
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            
            // Send verification email
            try await authResult.user.sendEmailVerification()
            
            // Create Firestore user document
            var data = userData
            data["createdAt"] = Timestamp()
            data["emailVerified"] = false
            data["points"] = 500  // Starter points
            data["giftsGiven"] = 0
            data["rank"] = 0
            
            try await Firestore.firestore()
                .collection("users")
                .document(authResult.user.uid)
                .setData(data)
        } catch {
            errorMessage = handleAuthError(error)
            throw error
        }
    }
    
    // MARK: - Login
    func login(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            
            // Reload user to get latest verification status
            try await authResult.user.reload()
            
            // Store user email
            userEmail = authResult.user.email
            
            // Verify user document exists in Firestore
            do {
                let _ = try await FirestoreService.shared.getUser(userId: authResult.user.uid)
            } catch {
                // User authenticated but no Firestore document exists
                errorMessage = "User profile not found. Please contact support."
                try? Auth.auth().signOut()
                throw AuthError.userNotFoundInDatabase
            }
            
            // Check email verification
            if !authResult.user.isEmailVerified {
                // Don't throw error - instead set flag to show verification screen
                isEmailVerified = false
                isAuthenticated = false
                currentUser = try await FirestoreService.shared.getUser(userId: authResult.user.uid)
                return
            }
            
            isEmailVerified = true
            
            // Update Firestore to sync emailVerified status
            try await FirestoreService.shared.updateUser(
                userId: authResult.user.uid,
                data: ["emailVerified": true]
            )
            
            await fetchUserData(userId: authResult.user.uid)
        } catch {
            errorMessage = handleAuthError(error)
            throw error
        }
    }
    
    // MARK: - Sign in with Apple
    func signInWithApple(credential: AuthCredential) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let authResult = try await Auth.auth().signIn(with: credential)
            
            // Check if user exists in Firestore
            let userExists = try await checkUserExists(userId: authResult.user.uid)
            
            if !userExists {
                // New user - need to collect additional info
                // This will be handled by the UI
                throw AuthError.additionalInfoRequired
            }
            
            await fetchUserData(userId: authResult.user.uid)
        } catch {
            errorMessage = handleAuthError(error)
            throw error
        }
    }
    
    // MARK: - Sign in with Google
    func signInWithGoogle(credential: AuthCredential) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let authResult = try await Auth.auth().signIn(with: credential)
            
            // Check if user exists in Firestore
            let userExists = try await checkUserExists(userId: authResult.user.uid)
            
            if !userExists {
                throw AuthError.additionalInfoRequired
            }
            
            await fetchUserData(userId: authResult.user.uid)
        } catch {
            errorMessage = handleAuthError(error)
            throw error
        }
    }
    
    // MARK: - Logout
    func logout() throws {
        try Auth.auth().signOut()
        currentUser = nil
        isAuthenticated = false
    }
    
    // MARK: - Fetch User Data
    func fetchUserData(userId: String) async {
        do {
            let document = try await Firestore.firestore()
                .collection("users")
                .document(userId)
                .getDocument()
            
            currentUser = try document.data(as: User.self)
        } catch {
            print("Error fetching user: \(error)")
            errorMessage = "Failed to load user data"
        }
    }
    
    // MARK: - Password Reset
    func resetPassword(email: String) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            errorMessage = handleAuthError(error)
            throw error
        }
    }
    
    // MARK: - Resend Verification Email
    func resendVerificationEmail() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.noUser
        }
        
        // Reload user to get latest verification status
        try await user.reload()
        
        // Check if already verified
        if user.isEmailVerified {
            throw AuthError.alreadyVerified
        }
        
        // Send verification email
        try await user.sendEmailVerification()
    }
    
    // MARK: - Check Email Verification Status
    func checkEmailVerificationStatus() async {
        guard let user = Auth.auth().currentUser else { return }
        
        do {
            // Reload user from Firebase to get latest verification status
            try await user.reload()
            
            // If email is now verified, update Firestore
            if user.isEmailVerified {
                try await FirestoreService.shared.updateUser(
                    userId: user.uid,
                    data: ["emailVerified": true]
                )
            }
            
            // Update verification state
            await MainActor.run {
                self.isEmailVerified = user.isEmailVerified
                
                // If now verified, fetch user data and navigate to home
                if user.isEmailVerified {
                    Task {
                        await self.fetchUserData(userId: user.uid)
                        self.isAuthenticated = true
                    }
                }
            }
        } catch {
            print("Error checking verification status: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Manual Sync Functions
    
    /// Manually sync email verification status from Firebase Auth to Firestore
    /// Call this to fix existing accounts that verified email but Firestore wasn't updated
    func syncEmailVerificationStatus() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.noUser
        }
        
        // Reload to get latest status
        try await user.reload()
        
        // Update Firestore if verified
        if user.isEmailVerified {
            try await FirestoreService.shared.updateUser(
                userId: user.uid,
                data: ["emailVerified": true]
            )
            
            await MainActor.run {
                self.isEmailVerified = true
                print("✅ Firestore emailVerified synced to true")
            }
        }
    }
    
    // MARK: - Helper Functions
    private func checkUserExists(userId: String) async throws -> Bool {
        let document = try await Firestore.firestore()
            .collection("users")
            .document(userId)
            .getDocument()
        return document.exists
    }
    
    private func handleAuthError(_ error: Error) -> String {
        if let authError = error as? AuthError {
            return authError.errorDescription ?? "An error occurred"
        }
        
        let nsError = error as NSError
        switch nsError.code {
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return "This email is already registered"
        case AuthErrorCode.invalidEmail.rawValue:
            return "Please enter a valid email address"
        case AuthErrorCode.weakPassword.rawValue:
            return "Password must be at least 6 characters"
        case AuthErrorCode.userNotFound.rawValue:
            return "No account found with this email"
        case AuthErrorCode.wrongPassword.rawValue:
            return "Incorrect email or password"
        case AuthErrorCode.networkError.rawValue:
            return "Network error. Please check your connection"
        case AuthErrorCode.tooManyRequests.rawValue:
            return "Too many attempts. Please try again later"
        default:
            return "Something went wrong. Please try again"
        }
    }
}

enum AuthError: LocalizedError {
    case emailNotVerified
    case additionalInfoRequired
    case noUser
    case alreadyVerified
    case userNotFoundInDatabase
    
    var errorDescription: String? {
        switch self {
        case .emailNotVerified:
            return "Please verify your email before logging in"
        case .additionalInfoRequired:
            return "Additional information required"
        case .noUser:
            return "No user is currently logged in"
        case .alreadyVerified:
            return "Your email is already verified"
        case .userNotFoundInDatabase:
            return "User profile not found in database"
        }
    }
}

