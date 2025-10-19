//
//  LoginView.swift
//  Fetch
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showForgotPassword = false
    @State private var resetEmail = ""
    
    var body: some View {
        ZStack {
                Color(hex: "F2F2F7")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Section
                        VStack(spacing: 16) {
                            // FC App Icon
                            ZStack {
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(Color(hex: "007AFF"))
                                    .frame(width: 100, height: 100)
                                    .shadow(color: .blue.opacity(0.3), radius: 12, y: 4)
                                
                                Text("FC")
                                    .font(.system(size: 42, weight: .black))
                                    .foregroundColor(.white)
                            }
                            
                            // Welcome Back Headline
                            Text("Welcome Back")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.black)
                            
                            // Subtitle
                            Text("Enter your credentials to access your account")
                                .font(.system(size: 17))
                                .foregroundColor(Color(hex: "8E8E93"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        .padding(.top, 20)
                        
                        // Login Card
                        VStack(spacing: 0) {
                            // Email Field
                            HStack(spacing: 12) {
                                // Email Icon
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "007AFF").opacity(0.1))
                                        .frame(width: 40, height: 40)
                                    
                                    Text("📧")
                                        .font(.system(size: 20))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Email Address")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color(hex: "8E8E93"))
                                    
                                    TextField("name@wisc.edu", text: $email)
                                        .font(.system(size: 17))
                                        .foregroundColor(.black)
                                        .textContentType(.emailAddress)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                        .keyboardType(.emailAddress)
                                }
                            }
                            .padding(16)
                            
                            Divider()
                                .padding(.leading, 68)
                            
                            // Password Field
                            HStack(spacing: 12) {
                                // Lock Icon
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "8E8E93").opacity(0.1))
                                        .frame(width: 40, height: 40)
                                    
                                    Text("🔒")
                                        .font(.system(size: 20))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Password")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color(hex: "8E8E93"))
                                    
                                    HStack {
                                        if showPassword {
                                            TextField("Enter your password", text: $password)
                                                .font(.system(size: 17))
                                                .foregroundColor(.black)
                                                .textContentType(.password)
                                        } else {
                                            SecureField("Enter your password", text: $password)
                                                .font(.system(size: 17))
                                                .foregroundColor(.black)
                                                .textContentType(.password)
                                        }
                                        
                                        Button(action: {
                                            showPassword.toggle()
                                        }) {
                                            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                                .foregroundColor(Color(hex: "8E8E93"))
                                                .font(.system(size: 16))
                                        }
                                    }
                                }
                            }
                            .padding(16)
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
                        
                        // Forgot Password Link
                        HStack {
                            Spacer()
                            Button(action: {
                                showForgotPassword = true
                            }) {
                                Text("Forgot Password?")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color(hex: "007AFF"))
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // Error Message
                        if showError {
                            Text(errorMessage)
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "FF3B30"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                        }
                        
                        // Log In Button
                        Button(action: handleLogin) {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Log In")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "007AFF"), Color(hex: "007AFF").opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: .blue.opacity(0.3), radius: 12, y: 4)
                        .disabled(email.isEmpty || password.isEmpty || isLoading)
                        .opacity((email.isEmpty || password.isEmpty || isLoading) ? 0.6 : 1.0)
                        
                        // Divider with text
                        HStack(spacing: 16) {
                            Rectangle()
                                .fill(Color(hex: "E5E5EA"))
                                .frame(height: 1)
                            
                            Text("or continue with")
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "8E8E93"))
                            
                            Rectangle()
                                .fill(Color(hex: "E5E5EA"))
                                .frame(height: 1)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        
                        // Social Login Buttons
                        HStack(spacing: 12) {
                            // Apple Button
                            Button(action: {
                                // Handle Apple Sign In
                            }) {
                                HStack(spacing: 8) {
                                    Text("🍎")
                                        .font(.system(size: 20))
                                    Text("Apple")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.black)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(hex: "E5E5EA"), lineWidth: 1)
                                )
                            }
                            
                            // Google Button
                            Button(action: {
                                // Handle Google Sign In
                            }) {
                                HStack(spacing: 8) {
                                    Text("🔍")
                                        .font(.system(size: 20))
                                    Text("Google")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(Color(hex: "8E8E93"))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(hex: "E5E5EA"), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Log In")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Back")
                        }
                        .foregroundColor(Color(hex: "007AFF"))
                    }
                }
            }
            .alert("Reset Password", isPresented: $showForgotPassword) {
                TextField("Email", text: $resetEmail)
                Button("Cancel", role: .cancel) { }
                Button("Send Reset Link") {
                    handleForgotPassword()
                }
            } message: {
                Text("Enter your email address to receive a password reset link")
            }
    }
    
    // MARK: - Actions
    
    func handleLogin() {
        showError = false
        isLoading = true
        
        Task {
            do {
                try await authManager.login(email: email, password: password)
                
                await MainActor.run {
                    isLoading = false
                    // Navigation handled by authManager state change
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    showError = true
                    errorMessage = authManager.errorMessage ?? "Login failed. Please try again."
                }
            }
        }
    }
    
    func handleForgotPassword() {
        guard !resetEmail.isEmpty else { return }
        
        Task {
            do {
                try await authManager.resetPassword(email: resetEmail)
                
                await MainActor.run {
                    errorMessage = "Password reset link sent to \(resetEmail)"
                    showError = true
                    resetEmail = ""
                }
            } catch {
                await MainActor.run {
                    errorMessage = authManager.errorMessage ?? "Failed to send reset link"
                    showError = true
                }
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationManager())
}

