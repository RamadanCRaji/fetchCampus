//
//  VerificationRequiredView.swift
//  Fetch
//

import SwiftUI

struct VerificationRequiredView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    let userEmail: String
    
    @State private var isResending = false
    @State private var showSuccess = false
    @State private var errorMessage: String?
    @State private var cooldownSeconds = 0
    @State private var timer: Timer?
    @State private var checkTimer: Timer?
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Email Icon
                Text("📧")
                    .font(.system(size: 80))
                
                // Headline
                Text("Verify Your Email")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                
                // Description
                VStack(spacing: 8) {
                    Text("We sent a verification link to")
                        .font(.system(size: 17))
                        .foregroundColor(Color(hex: "8E8E93"))
                    
                    Text(userEmail)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                }
                
                // Instruction
                Text("Click the link in the email to verify your account")
                    .font(.system(size: 15))
                    .foregroundColor(Color(hex: "8E8E93"))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
                
                // Important Notice Card
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Text("ℹ️")
                            .font(.system(size: 20))
                        Text("Important")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "007AFF"))
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top, spacing: 8) {
                            Text("1.")
                                .font(.system(size: 13, weight: .semibold))
                            Text("Click the verification link in your email")
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "3C3C43"))
                        }
                        
                        HStack(alignment: .top, spacing: 8) {
                            Text("2.")
                                .font(.system(size: 13, weight: .semibold))
                            Text("If you see an error page, that's normal! Close it and come back here")
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "3C3C43"))
                        }
                        
                        HStack(alignment: .top, spacing: 8) {
                            Text("3.")
                                .font(.system(size: 13, weight: .semibold))
                            Text("Tap 'I've Verified My Email' below")
                                .font(.system(size: 13))
                                .foregroundColor(Color(hex: "3C3C43"))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(16)
                .background(Color(hex: "F0F9FF"))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: "007AFF").opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal, 24)
                .padding(.top, 12)
                
                // Success Message
                if showSuccess {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Verification email sent!")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Error Message
                if let error = errorMessage {
                    Text(error)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "FF3B30"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
                
                // Buttons
                VStack(spacing: 12) {
                    // Resend Button
                    Button(action: resendVerification) {
                        if isResending {
                            ProgressView()
                                .tint(.white)
                        } else if cooldownSeconds > 0 {
                            Text("Resend in 0:\(String(format: "%02d", cooldownSeconds))")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                        } else {
                            Text("Resend Verification Email")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(cooldownSeconds > 0 ? Color.gray : Color(hex: "007AFF"))
                    .cornerRadius(12)
                    .shadow(color: .blue.opacity(0.2), radius: 8, y: 2)
                    .disabled(isResending || cooldownSeconds > 0)
                    
                    // I've Verified My Email Button
                    Button(action: {
                        Task {
                            await authManager.checkEmailVerificationStatus()
                        }
                    }) {
                        Text("I've Verified My Email")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color(hex: "007AFF"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "007AFF"), lineWidth: 2)
                            )
                            .cornerRadius(12)
                    }
                    
                    // Use Different Email Button
                    Button(action: {
                        try? authManager.logout()
                    }) {
                        Text("Use Different Email")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color(hex: "007AFF"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(hex: "F2F2F7"))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            // Check verification status every 3 seconds
            checkTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                Task {
                    await authManager.checkEmailVerificationStatus()
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
            checkTimer?.invalidate()
        }
    }
    
    func resendVerification() {
        guard cooldownSeconds == 0 else { return }
        
        isResending = true
        errorMessage = nil
        
        Task {
            do {
                try await authManager.resendVerificationEmail()
                
                await MainActor.run {
                    isResending = false
                    withAnimation {
                        showSuccess = true
                    }
                    
                    // Start cooldown
                    cooldownSeconds = 60
                    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                        if cooldownSeconds > 0 {
                            cooldownSeconds -= 1
                        } else {
                            timer?.invalidate()
                        }
                    }
                    
                    // Hide success message after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            showSuccess = false
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    isResending = false
                    errorMessage = authManager.errorMessage ?? "Failed to send verification email"
                }
            }
        }
    }
}

#Preview {
    VerificationRequiredView(userEmail: "test@wisc.edu")
        .environmentObject(AuthenticationManager())
}

