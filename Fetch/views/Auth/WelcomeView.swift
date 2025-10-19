//
//  WelcomeView.swift
//  Fetch
//

import SwiftUI

struct WelcomeView: View {
    @State private var showContent = false
    @State private var rotationAngle: Double = 0
    @State private var navigateToSignUp = false
    @State private var navigateToLogin = false
    
    var body: some View {
        if navigateToSignUp {
            SignUpView()
        } else if navigateToLogin {
            LoginView()
        } else {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Animated Gift Box
                    Text("🎁")
                        .font(.system(size: 100))
                        .rotationEffect(.degrees(rotationAngle))
                        .offset(y: showContent ? 0 : -300)
                        .onAppear {
                            // Drop animation with spring bounce
                            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                                showContent = true
                            }
                            // Continuous rotation animation
                            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                                rotationAngle = 360
                            }
                        }
                        .padding(.bottom, 40)
                    
                    // Headline
                    Text("Gift Points to Friends")
                        .font(.system(size: 34, weight: .bold))
                        .kerning(-0.5)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 12)
                    
                    // Subtitle
                    Text("Build your social status by being generous")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(Color(hex: "8E8E93"))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 280)
                    
                    Spacer()
                    
                    // Buttons
                    VStack(spacing: 12) {
                        // Get Started button
                        Button(action: {
                            withAnimation {
                                navigateToSignUp = true
                            }
                        }) {
                            Text("Get Started")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(hex: "007AFF"))
                                .cornerRadius(12)
                                .shadow(color: .blue.opacity(0.2), radius: 8, y: 2)
                        }
                        
                        // I Have an Account button
                        Button(action: {
                            withAnimation {
                                navigateToLogin = true
                            }
                        }) {
                            Text("I Have an Account")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(Color(hex: "007AFF"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(hex: "F2F2F7"))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
        }
    }
}

#Preview {
    WelcomeView()
}

